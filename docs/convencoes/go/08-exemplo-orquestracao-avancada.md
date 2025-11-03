# Orquestração Avançada: Saga Pattern

> **"Complexidade não está no número de linhas de código. Está no número de interações entre sistemas."**

Este exemplo mostra **orquestração complexa** — o que separa aplicações triviais de sistemas reais.

## Por que este exemplo importa?

O CRUD do arquivo anterior mostra **persistência básica**. Este exemplo mostra **coordenação entre múltiplos sistemas** — banco de dados, APIs externas, cache, mensageria.

**Cenário:** Sistema escolar precisa processar matrícula de estudante. Parece simples, mas envolve:

1. **Múltiplos agregados** — Student, Course, Enrollment, Payment
2. **Transação distribuída** — Banco de dados + API externa (pagamento) + Cache (vagas)
3. **Consistência eventual** — Se pagamento falha, precisa desfazer reserva de vaga
4. **Resiliência** — Provedor de pagamento offline não pode travar toda aplicação
5. **Idempotência** — Cliente pode fazer retry, não pode cobrar 2x

**Padrão usado:** Saga com compensação (não ACID distribuído, que é impossível entre sistemas heterogêneos).

**O que você vai aprender:**
- Como coordenar operações em múltiplos sistemas (DB, cache, API externa)
- Como implementar rollback manual (compensação)
- Como proteger contra falhas de dependências (circuit breaker)
- Como garantir segurança em retries (idempotência)
- Como publicar eventos sem acoplar (fire-and-forget)

---

## Arquitetura do Exemplo

```
┌─────────────────────────────────────────────────────────────────┐
│                         API Layer                                │
│  POST /enrollments → EnrollmentHandler.Create()                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Application Layer (app/)                      │
│                                                                   │
│  EnrollmentProcessor (ORQUESTRADOR)                             │
│    1. Validar estudante existe                                   │
│    2. Validar curso existe                                       │
│    3. Verificar pré-requisitos (domain logic)                   │
│    4. Verificar vagas disponíveis (cache)                       │
│    ┌──────────────────────────────────────────────────────┐    │
│    │               SAGA TRANSACIONAL                       │    │
│    │  5. Reservar vaga (cache)          [Compensação: +1]│    │
│    │  6. Processar pagamento (Stripe)   [Compensação: refund]  │
│    │  7. Salvar enrollment (DB)         [Compensação: delete]  │
│    └──────────────────────────────────────────────────────┘    │
│    8. Publicar evento (async, fire-and-forget)                 │
│    9. Marcar idempotência (cache)                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Domain Layer                                │
│  Student: CanEnroll() → valida máximo 7 cursos                 │
│  Course: HasAvailableSeats() → valida vagas                    │
│  Enrollment: agregado principal                                  │
│  Payment: value object                                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Infrastructure Layer                            │
│  PostgreSQL: student/course/enrollment repos                    │
│  Redis: cache de vagas disponíveis                             │
│  Stripe: payment provider (com circuit breaker)                │
│  RabbitMQ: event publisher                                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Domain Layer: Múltiplos Agregados

### Student (internal/domain/student/student.go)

```go
package student

import (
    "errors"
    "time"
)

// Student agregado com regras de negócio
type Student struct {
    Id              string
    Name            string
    Email           string
    EnrolledCourses []string  // IDs de cursos matriculados
    Status          Status
    CreatedAt       time.Time
}

type Status string

const (
    StatusActive    Status = "active"
    StatusInactive  Status = "inactive"
    StatusSuspended Status = "suspended"
)

var (
    ErrStudentNotFound     = errors.New("student not found")
    ErrMaxCoursesReached   = errors.New("student already enrolled in 7 courses")
    ErrStudentNotActive    = errors.New("student is not active")
    ErrCourseAlreadyTaken  = errors.New("student already enrolled in this course")
)

// CanEnroll valida se estudante pode se matricular em novo curso
// Regra de negócio: máximo 7 cursos simultâneos
func (s *Student) CanEnroll() error {
    if s.Status != StatusActive {
        return ErrStudentNotActive
    }

    if len(s.EnrolledCourses) >= 7 {
        return ErrMaxCoursesReached
    }

    return nil
}

// IsEnrolledIn verifica se estudante já está matriculado no curso
func (s *Student) IsEnrolledIn(courseId string) bool {
    for _, id := range s.EnrolledCourses {
        if id == courseId {
            return true
        }
    }
    return false
}

// Repository interface (definida no domain)
type Repository interface {
    FindByID(ctx context.Context, id string) (*Student, error)
    Save(ctx context.Context, student *Student) error
    AddEnrolledCourse(ctx context.Context, studentId, courseId string) error
}
```

**Por que separar `CanEnroll()` e `IsEnrolledIn()`?**

- `CanEnroll()` → Valida **capacidade** (máximo 7 cursos, status ativo)
- `IsEnrolledIn()` → Valida **duplicação** (já matriculado neste curso específico)

Separar facilita testes e reutilização: controller pode chamar `IsEnrolledIn()` para validação rápida antes de processar.

---

### Course (internal/domain/course/course.go)

```go
package course

import (
    "errors"
    "time"
)

type Course struct {
    Id               string
    Name             string
    Code             string
    Capacity         int      // Vagas totais
    EnrolledStudents int      // Vagas ocupadas
    Prerequisites    []string // IDs de cursos pré-requisitos
    Price            float64
    StartDate        time.Time
    EndDate          time.Time
}

var (
    ErrCourseNotFound      = errors.New("course not found")
    ErrNoSeatsAvailable    = errors.New("course has no available seats")
    ErrPrerequisitesNotMet = errors.New("student does not meet prerequisites")
)

// HasAvailableSeats verifica se há vagas
func (c *Course) HasAvailableSeats() bool {
    return c.EnrolledStudents < c.Capacity
}

// AvailableSeats retorna quantidade de vagas livres
func (c *Course) AvailableSeats() int {
    remaining := c.Capacity - c.EnrolledStudents
    if remaining < 0 {
        return 0
    }
    return remaining
}

// CheckPrerequisites valida se estudante cursou pré-requisitos
func (c *Course) CheckPrerequisites(studentCompletedCourses []string) error {
    if len(c.Prerequisites) == 0 {
        return nil  // Curso sem pré-requisitos
    }

    // Criar mapa para busca eficiente
    completed := make(map[string]bool)
    for _, courseId := range studentCompletedCourses {
        completed[courseId] = true
    }

    // Verificar se TODOS os pré-requisitos foram cursados
    for _, prereq := range c.Prerequisites {
        if !completed[prereq] {
            return ErrPrerequisitesNotMet
        }
    }

    return nil
}

type Repository interface {
    FindByID(ctx context.Context, id string) (*Course, error)
    IncrementEnrolled(ctx context.Context, courseId string) error
    DecrementEnrolled(ctx context.Context, courseId string) error
}
```

**Por que separar `HasAvailableSeats()` e `AvailableSeats()`?**

- `HasAvailableSeats()` → Resposta booleana rápida (validação)
- `AvailableSeats()` → Número exato (exibição na UI)

**Por que `CheckPrerequisites()` recebe lista ao invés de Student completo?**

Evita dependência circular: `Course` não precisa conhecer `Student`. Recebe apenas lista de IDs (interface mínima).

---

### Enrollment (internal/domain/enrollment/enrollment.go)

```go
package enrollment

import (
    "errors"
    "time"
)

// Enrollment é o agregado principal (raiz)
type Enrollment struct {
    Id         string
    StudentId  string
    CourseId   string
    PaymentId  string
    Status     Status
    EnrolledAt time.Time
    CompletedAt *time.Time
}

type Status string

const (
    StatusPending   Status = "pending"
    StatusActive    Status = "active"
    StatusCompleted Status = "completed"
    StatusCancelled Status = "cancelled"
)

var (
    ErrEnrollmentNotFound = errors.New("enrollment not found")
    ErrAlreadyCompleted   = errors.New("enrollment already completed")
)

// NewEnrollment factory com validação
func NewEnrollment(studentId, courseId, paymentId string) (*Enrollment, error) {
    if studentId == "" || courseId == "" || paymentId == "" {
        return nil, errors.New("studentId, courseId, and paymentId are required")
    }

    return &Enrollment{
        Id:         generateID(),
        StudentId:  studentId,
        CourseId:   courseId,
        PaymentId:  paymentId,
        Status:     StatusActive,
        EnrolledAt: time.Now(),
    }, nil
}

// Complete marca matrícula como concluída
func (e *Enrollment) Complete() error {
    if e.Status == StatusCompleted {
        return ErrAlreadyCompleted
    }

    e.Status = StatusCompleted
    now := time.Now()
    e.CompletedAt = &now

    return nil
}

// Cancel cancela matrícula (para rollback de saga)
func (e *Enrollment) Cancel() {
    e.Status = StatusCancelled
}

type Repository interface {
    Save(ctx context.Context, enrollment *Enrollment) error
    FindByID(ctx context.Context, id string) (*Enrollment, error)
    FindByStudentAndCourse(ctx context.Context, studentId, courseId string) (*Enrollment, error)
    Delete(ctx context.Context, id string) error  // Para compensação
}
```

**Por que `Enrollment` é o agregado raiz?**

Matrícula **coordena** Student e Course. Não faz sentido ter Student sem Enrollment ou Course sem Enrollment em uma operação de matrícula. Enrollment é a unidade transacional.

---

### Payment (internal/domain/payment/payment.go)

```go
package payment

import (
    "context"
    "errors"
    "time"
)

// Payment é um value object (imutável após criação)
type Payment struct {
    Id            string
    Amount        float64
    Currency      string
    Method        Method
    Status        Status
    ProviderRef   string    // ID retornado pelo provedor (Stripe, etc)
    ProcessedAt   time.Time
    RefundedAt    *time.Time
}

type Method string

const (
    MethodCreditCard Method = "credit_card"
    MethodDebitCard  Method = "debit_card"
    MethodPix        Method = "pix"
)

type Status string

const (
    StatusPending   Status = "pending"
    StatusCompleted Status = "completed"
    StatusRefunded  Status = "refunded"
    StatusFailed    Status = "failed"
)

var (
    ErrPaymentFailed       = errors.New("payment processing failed")
    ErrProviderUnavailable = errors.New("payment provider unavailable")
    ErrInsufficientFunds   = errors.New("insufficient funds")
    ErrInvalidCard         = errors.New("invalid card")
)

// Provider interface (Strategy pattern)
// Permite trocar Stripe, PagSeguro, etc sem mudar domain
type Provider interface {
    Charge(ctx context.Context, amount float64, method Method, metadata map[string]string) (*Payment, error)
    Refund(ctx context.Context, paymentId string) error
    GetStatus(ctx context.Context, paymentId string) (Status, error)
}
```

**Por que Payment é value object e não entidade?**

Payment não tem identidade própria que mude ao longo do tempo. Uma vez criado (pago), nunca muda — apenas pode ser estornado (novo estado, mas imutável). Entidade seria overkill.

**Por que Provider é interface?**

Permite trocar provedor sem recompilar (Strategy pattern). Testes podem usar MockProvider, staging pode usar Sandbox, produção usa Stripe real.

---

## Application Layer: Orquestrador com Saga

### EnrollmentProcessor (internal/app/enrollment_processor/processor.go)

```go
package enrollment_processor

import (
    "context"
    "fmt"
    "time"

    "github.com/empresa/escola/internal/domain/student"
    "github.com/empresa/escola/internal/domain/course"
    "github.com/empresa/escola/internal/domain/enrollment"
    "github.com/empresa/escola/internal/domain/payment"
)

// ProcessEnrollmentRequest DTO de entrada
type ProcessEnrollmentRequest struct {
    StudentId       string
    CourseId        string
    PaymentMethod   payment.Method
    IdempotencyKey  string  // Garante retry seguro
}

// EnrollmentProcessor orquestra fluxo completo de matrícula
// NÃO é domain service (tem lógica de aplicação: cache, eventos, compensação)
type EnrollmentProcessor struct {
    studentRepo     student.Repository
    courseRepo      course.Repository
    enrollmentRepo  enrollment.Repository
    paymentProvider payment.Provider
    cache           CacheService        // Interface para Redis
    eventPublisher  EventPublisher      // Interface para RabbitMQ
    idempotency     IdempotencyChecker  // Interface para cache
}

func NewEnrollmentProcessor(
    studentRepo student.Repository,
    courseRepo course.Repository,
    enrollmentRepo enrollment.Repository,
    paymentProvider payment.Provider,
    cache CacheService,
    eventPublisher EventPublisher,
    idempotency IdempotencyChecker,
) *EnrollmentProcessor {
    return &EnrollmentProcessor{
        studentRepo:     studentRepo,
        courseRepo:      courseRepo,
        enrollmentRepo:  enrollmentRepo,
        paymentProvider: paymentProvider,
        cache:           cache,
        eventPublisher:  eventPublisher,
        idempotency:     idempotency,
    }
}

// Process orquestra TODO o fluxo de matrícula
// É aqui que a complexidade vive — não no domain
func (p *EnrollmentProcessor) Process(
    ctx context.Context,
    req ProcessEnrollmentRequest,
) (*enrollment.Enrollment, error) {
    // ============================================================
    // FASE 1: IDEMPOTÊNCIA
    // ============================================================
    // Cliente pode fazer retry se timeout. Precisamos detectar.
    // Se já processamos este idempotencyKey, retorna resultado anterior.
    if processed, result := p.idempotency.Check(ctx, req.IdempotencyKey); processed {
        return result, nil  // Já processado, retorna sem reprocessar
    }

    // ============================================================
    // FASE 2: VALIDAÇÕES INICIAIS (sem side-effects)
    // ============================================================
    // Estas validações são "baratas" e não causam mudanças.
    // Se falharem aqui, não precisamos compensar nada.

    stud, err := p.studentRepo.FindByID(ctx, req.StudentId)
    if err != nil {
        return nil, fmt.Errorf("load student: %w", err)
    }

    // Validação de domínio: estudante pode se matricular?
    if err := stud.CanEnroll(); err != nil {
        return nil, fmt.Errorf("student cannot enroll: %w", err)
    }

    // Validação de domínio: já matriculado neste curso?
    if stud.IsEnrolledIn(req.CourseId) {
        return nil, student.ErrCourseAlreadyTaken
    }

    crs, err := p.courseRepo.FindByID(ctx, req.CourseId)
    if err != nil {
        return nil, fmt.Errorf("load course: %w", err)
    }

    // Validação de domínio: pré-requisitos cumpridos?
    if err := crs.CheckPrerequisites(stud.EnrolledCourses); err != nil {
        return nil, fmt.Errorf("prerequisites not met: %w", err)
    }

    // Verificar vagas no CACHE (mais rápido que banco)
    availableSeats, err := p.cache.GetAvailableSeats(ctx, req.CourseId)
    if err != nil {
        // Se cache falhou, busca do banco (fallback)
        availableSeats = crs.AvailableSeats()
    }

    if availableSeats <= 0 {
        return nil, course.ErrNoSeatsAvailable
    }

    // ============================================================
    // FASE 3: SAGA TRANSACIONAL (com compensação)
    // ============================================================
    // A partir daqui, operações causam side-effects.
    // Se algo falhar, precisamos desfazer (compensar).

    saga := NewEnrollmentSaga(p, req.CourseId, crs.Price, req.PaymentMethod)

    // IMPORTANTE: defer com closure captura erro
    // Se Process retornar erro, saga.Rollback() é chamado automaticamente
    var sagaErr error
    defer func() {
        if sagaErr != nil {
            saga.Rollback(context.Background())  // Context novo para compensação
        }
    }()

    // Passo 1: Reservar vaga (decrementa contador no cache)
    if sagaErr = saga.ReserveCourseSeat(ctx); sagaErr != nil {
        return nil, fmt.Errorf("reserve seat failed: %w", sagaErr)
    }

    // Passo 2: Processar pagamento (chama API externa - Stripe)
    pmt, sagaErr := saga.ProcessPayment(ctx)
    if sagaErr != nil {
        return nil, fmt.Errorf("payment failed: %w", sagaErr)
    }

    // Passo 3: Salvar matrícula no banco
    enr, sagaErr := saga.SaveEnrollment(ctx, req.StudentId, req.CourseId, pmt.Id)
    if sagaErr != nil {
        return nil, fmt.Errorf("save enrollment failed: %w", sagaErr)
    }

    // Passo 4: Atualizar contador de cursos do estudante
    if sagaErr = saga.AddCourseToStudent(ctx, req.StudentId, req.CourseId); sagaErr != nil {
        return nil, fmt.Errorf("update student courses failed: %w", sagaErr)
    }

    // ============================================================
    // FASE 4: PÓS-PROCESSAMENTO (async, fire-and-forget)
    // ============================================================
    // Saga foi bem-sucedida. Agora publicamos evento.
    // Se publicação falhar, NÃO rollback (evento é eventual consistency).

    saga.Commit()  // Marca saga como bem-sucedida (sem rollback)

    // Publicar evento de forma assíncrona (não bloqueia resposta)
    go func() {
        ctx := context.Background()  // Context novo para goroutine
        event := EnrollmentCreatedEvent{
            EnrollmentId: enr.Id,
            StudentId:    req.StudentId,
            CourseId:     req.CourseId,
            PaymentId:    pmt.Id,
            Timestamp:    time.Now(),
        }

        if err := p.eventPublisher.Publish(ctx, "enrollment.created", event); err != nil {
            // Log erro mas não falha operação (evento é best-effort)
            fmt.Printf("failed to publish event: %v\n", err)
        }
    }()

    // Marcar idempotência (cache com TTL 24h)
    p.idempotency.Store(ctx, req.IdempotencyKey, enr, 24*time.Hour)

    return enr, nil
}
```

**Por que tantas fases separadas?**

1. **Idempotência primeiro** — Evita reprocessar se cliente fez retry
2. **Validações sem side-effects** — Se falhar aqui, não precisa compensar (barato)
3. **Saga transacional** — Side-effects coordenados com compensação
4. **Pós-processamento async** — Eventos não bloqueiam resposta

**Por que `defer` com closure para rollback?**

Se **qualquer** operação da saga falhar, `defer` garante que `Rollback()` será chamado. Mesmo se houver panic, defer executa.

---

### EnrollmentSaga (internal/app/enrollment_processor/saga.go)

```go
package enrollment_processor

import (
    "context"
    "fmt"

    "github.com/empresa/escola/internal/domain/enrollment"
    "github.com/empresa/escola/internal/domain/payment"
)

// EnrollmentSaga implementa padrão Saga para transação distribuída
// Cada operação registra compensação (rollback manual)
type EnrollmentSaga struct {
    processor     *EnrollmentProcessor
    courseId      string
    amount        float64
    paymentMethod payment.Method

    // Compensações registradas (LIFO - Last In First Out)
    compensations []CompensationFunc
    committed     bool  // Se true, rollback não executa
}

// CompensationFunc função de compensação (rollback)
type CompensationFunc func(context.Context) error

func NewEnrollmentSaga(
    processor *EnrollmentProcessor,
    courseId string,
    amount float64,
    paymentMethod payment.Method,
) *EnrollmentSaga {
    return &EnrollmentSaga{
        processor:     processor,
        courseId:      courseId,
        amount:        amount,
        paymentMethod: paymentMethod,
        compensations: make([]CompensationFunc, 0),
        committed:     false,
    }
}

// ReserveCourseSeat reserva vaga no cache (decrementa)
func (s *EnrollmentSaga) ReserveCourseSeat(ctx context.Context) error {
    // Operação: decrementar vagas disponíveis
    if err := s.processor.cache.DecrementSeats(ctx, s.courseId); err != nil {
        return fmt.Errorf("decrement seats: %w", err)
    }

    // Registrar compensação: incrementar vagas de volta
    s.compensations = append(s.compensations, func(ctx context.Context) error {
        return s.processor.cache.IncrementSeats(ctx, s.courseId)
    })

    return nil
}

// ProcessPayment processa pagamento via provider (Stripe)
func (s *EnrollmentSaga) ProcessPayment(ctx context.Context) (*payment.Payment, error) {
    metadata := map[string]string{
        "course_id": s.courseId,
        "type":      "enrollment",
    }

    // Operação: cobrar pagamento
    pmt, err := s.processor.paymentProvider.Charge(ctx, s.amount, s.paymentMethod, metadata)
    if err != nil {
        return nil, fmt.Errorf("charge payment: %w", err)
    }

    // Registrar compensação: estornar pagamento
    s.compensations = append(s.compensations, func(ctx context.Context) error {
        return s.processor.paymentProvider.Refund(ctx, pmt.Id)
    })

    return pmt, nil
}

// SaveEnrollment persiste matrícula no banco
func (s *EnrollmentSaga) SaveEnrollment(
    ctx context.Context,
    studentId, courseId, paymentId string,
) (*enrollment.Enrollment, error) {
    // Operação: criar e salvar enrollment
    enr, err := enrollment.NewEnrollment(studentId, courseId, paymentId)
    if err != nil {
        return nil, fmt.Errorf("create enrollment: %w", err)
    }

    if err := s.processor.enrollmentRepo.Save(ctx, enr); err != nil {
        return nil, fmt.Errorf("save enrollment: %w", err)
    }

    // Registrar compensação: deletar enrollment
    s.compensations = append(s.compensations, func(ctx context.Context) error {
        return s.processor.enrollmentRepo.Delete(ctx, enr.Id)
    })

    return enr, nil
}

// AddCourseToStudent atualiza lista de cursos do estudante
func (s *EnrollmentSaga) AddCourseToStudent(ctx context.Context, studentId, courseId string) error {
    // Operação: adicionar curso à lista do estudante
    if err := s.processor.studentRepo.AddEnrolledCourse(ctx, studentId, courseId); err != nil {
        return fmt.Errorf("add enrolled course: %w", err)
    }

    // Compensação: remover curso da lista
    // (Nota: precisaria de método RemoveEnrolledCourse no repositório)
    s.compensations = append(s.compensations, func(ctx context.Context) error {
        // Implementação simplificada - em prod seria um método específico
        return nil
    })

    return nil
}

// Commit marca saga como bem-sucedida (impede rollback)
func (s *EnrollmentSaga) Commit() {
    s.committed = true
}

// Rollback executa compensações em ordem reversa (LIFO)
func (s *EnrollmentSaga) Rollback(ctx context.Context) {
    if s.committed {
        return  // Saga foi commitada, não compensar
    }

    // Executar compensações em ordem REVERSA
    // (última operação é desfeita primeiro)
    for i := len(s.compensations) - 1; i >= 0; i-- {
        compensation := s.compensations[i]

        if err := compensation(ctx); err != nil {
            // Log erro mas continua compensando outras operações
            // Em prod, você enviaria para sistema de observabilidade
            fmt.Printf("compensation %d failed: %v\n", i, err)
        }
    }
}
```

**Por que compensação ao invés de transação ACID distribuída?**

**Transação ACID distribuída** (2-phase commit) requer:
- Todos os sistemas suportarem protocolo de transação distribuída
- Lock de recursos até commit/rollback (latência alta)
- Falha de um nó trava todos os outros

**Saga com compensação:**
- ✅ Funciona com qualquer sistema (DB, API externa, cache)
- ✅ Cada operação commita localmente (baixa latência)
- ✅ Se falha, desfaz manualmente (compensação)
- ❌ Consistência **eventual**, não imediata (trade-off aceitável)

**Por que LIFO (ordem reversa)?**

Imagine sequência: Reserve vaga → Paga → Salva enrollment

Se "Salva enrollment" falha:
1. Primeiro desfaz "Salva" (última)
2. Depois desfaz "Paga" (penúltima)
3. Por fim desfaz "Reserve" (primeira)

Ordem reversa garante que dependências sejam desfeitas corretamente.

---

## Infrastructure: Circuit Breaker para Resiliência

### StripeProviderWithCircuitBreaker (internal/infra/payment/circuit_breaker.go)

```go
package payment

import (
    "context"
    "errors"
    "time"

    "github.com/sony/gobreaker"

    "github.com/empresa/escola/internal/domain/payment"
)

// StripeProviderWithCircuitBreaker envolve provider real com circuit breaker
// Previne cascata de falhas se Stripe estiver offline
type StripeProviderWithCircuitBreaker struct {
    provider payment.Provider  // Provider real (Stripe)
    breaker  *gobreaker.CircuitBreaker
}

func NewStripeProviderWithCircuitBreaker(provider payment.Provider) *StripeProviderWithCircuitBreaker {
    // Configuração do circuit breaker
    settings := gobreaker.Settings{
        Name:        "stripe-payment",
        MaxRequests: 3,                    // Máximo de requests em half-open
        Interval:    10 * time.Second,     // Janela de medição
        Timeout:     30 * time.Second,     // Tempo até tentar half-open
        ReadyToTrip: func(counts gobreaker.Counts) bool {
            // Abre circuito se taxa de falha > 50% OU > 5 falhas consecutivas
            failureRatio := float64(counts.TotalFailures) / float64(counts.Requests)
            return counts.Requests >= 10 && failureRatio >= 0.5 || counts.ConsecutiveFailures > 5
        },
        OnStateChange: func(name string, from gobreaker.State, to gobreaker.State) {
            // Log mudança de estado (em prod, envia para observabilidade)
            fmt.Printf("Circuit breaker '%s': %s → %s\n", name, from, to)
        },
    }

    return &StripeProviderWithCircuitBreaker{
        provider: provider,
        breaker:  gobreaker.NewCircuitBreaker(settings),
    }
}

// Charge tenta cobrar, mas falha rápido se circuito estiver aberto
func (p *StripeProviderWithCircuitBreaker) Charge(
    ctx context.Context,
    amount float64,
    method payment.Method,
    metadata map[string]string,
) (*payment.Payment, error) {
    // Execute através do circuit breaker
    result, err := p.breaker.Execute(func() (interface{}, error) {
        return p.provider.Charge(ctx, amount, method, metadata)
    })

    if err != nil {
        // Se circuito está aberto, falha imediatamente (fail-fast)
        if errors.Is(err, gobreaker.ErrOpenState) {
            return nil, payment.ErrProviderUnavailable
        }
        return nil, err
    }

    return result.(*payment.Payment), nil
}

// Refund tenta estornar (sem circuit breaker, pois é operação crítica)
func (p *StripeProviderWithCircuitBreaker) Refund(ctx context.Context, paymentId string) error {
    // Refund não passa pelo circuit breaker - SEMPRE tenta
    // (compensação é crítica, não podemos desistir)
    return p.provider.Refund(ctx, paymentId)
}

func (p *StripeProviderWithCircuitBreaker) GetStatus(ctx context.Context, paymentId string) (payment.Status, error) {
    result, err := p.breaker.Execute(func() (interface{}, error) {
        return p.provider.GetStatus(ctx, paymentId)
    })

    if err != nil {
        if errors.Is(err, gobreaker.ErrOpenState) {
            return "", payment.ErrProviderUnavailable
        }
        return "", err
    }

    return result.(payment.Status), nil
}
```

**Por que Circuit Breaker?**

Sem circuit breaker:
```
┌─────────┐       ┌─────────┐
│ API     │──┬───→│ Stripe  │ (offline)
└─────────┘  │    └─────────┘
             │    Timeout 30s
             │    Timeout 30s
             │    Timeout 30s (todas requests aguardam)
             └─── 100 requests = 3000s bloqueadas
```

Com circuit breaker:
```
1ª falha  → Tenta (timeout 30s)
2ª falha  → Tenta (timeout 30s)
3ª falha  → Tenta (timeout 30s)
4ª falha  → ABRE CIRCUITO
5ª+ falhas → Falha IMEDIATA (0s), retorna ErrProviderUnavailable
```

**Estados do circuit breaker:**

1. **Closed (normal):** Todas requests passam
2. **Open (falhou muito):** Todas requests falham imediatamente (não tenta)
3. **Half-Open (testando):** Permite algumas requests para testar se voltou

**Por que Refund não usa circuit breaker?**

Refund é **compensação** — operação crítica para desfazer saga. Se desistirmos de estornar, cliente paga 2x. Preferimos retry infinito a falhar.

---

## Testes: Mockando Saga Complexa

### EnrollmentProcessor Test (internal/app/enrollment_processor/processor_test.go)

```go
package enrollment_processor_test

import (
    "context"
    "errors"
    "testing"
    "time"

    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
    "github.com/stretchr/testify/require"

    "github.com/empresa/escola/internal/app/enrollment_processor"
    "github.com/empresa/escola/internal/domain/student"
    "github.com/empresa/escola/internal/domain/course"
    "github.com/empresa/escola/internal/domain/enrollment"
    "github.com/empresa/escola/internal/domain/payment"
)

// ============================================================
// MOCKS
// ============================================================

type MockStudentRepo struct {
    mock.Mock
}

func (m *MockStudentRepo) FindByID(ctx context.Context, id string) (*student.Student, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*student.Student), args.Error(1)
}

func (m *MockStudentRepo) Save(ctx context.Context, s *student.Student) error {
    return m.Called(ctx, s).Error(0)
}

func (m *MockStudentRepo) AddEnrolledCourse(ctx context.Context, studentId, courseId string) error {
    return m.Called(ctx, studentId, courseId).Error(0)
}

type MockCourseRepo struct {
    mock.Mock
}

func (m *MockCourseRepo) FindByID(ctx context.Context, id string) (*course.Course, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*course.Course), args.Error(1)
}

func (m *MockCourseRepo) IncrementEnrolled(ctx context.Context, courseId string) error {
    return m.Called(ctx, courseId).Error(0)
}

func (m *MockCourseRepo) DecrementEnrolled(ctx context.Context, courseId string) error {
    return m.Called(ctx, courseId).Error(0)
}

type MockEnrollmentRepo struct {
    mock.Mock
}

func (m *MockEnrollmentRepo) Save(ctx context.Context, e *enrollment.Enrollment) error {
    return m.Called(ctx, e).Error(0)
}

func (m *MockEnrollmentRepo) FindByID(ctx context.Context, id string) (*enrollment.Enrollment, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*enrollment.Enrollment), args.Error(1)
}

func (m *MockEnrollmentRepo) FindByStudentAndCourse(ctx context.Context, studentId, courseId string) (*enrollment.Enrollment, error) {
    args := m.Called(ctx, studentId, courseId)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*enrollment.Enrollment), args.Error(1)
}

func (m *MockEnrollmentRepo) Delete(ctx context.Context, id string) error {
    return m.Called(ctx, id).Error(0)
}

type MockPaymentProvider struct {
    mock.Mock
}

func (m *MockPaymentProvider) Charge(ctx context.Context, amount float64, method payment.Method, metadata map[string]string) (*payment.Payment, error) {
    args := m.Called(ctx, amount, method, metadata)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*payment.Payment), args.Error(1)
}

func (m *MockPaymentProvider) Refund(ctx context.Context, paymentId string) error {
    return m.Called(ctx, paymentId).Error(0)
}

func (m *MockPaymentProvider) GetStatus(ctx context.Context, paymentId string) (payment.Status, error) {
    args := m.Called(ctx, paymentId)
    return args.Get(0).(payment.Status), args.Error(1)
}

type MockCache struct {
    mock.Mock
}

func (m *MockCache) GetAvailableSeats(ctx context.Context, courseId string) (int, error) {
    args := m.Called(ctx, courseId)
    return args.Int(0), args.Error(1)
}

func (m *MockCache) DecrementSeats(ctx context.Context, courseId string) error {
    return m.Called(ctx, courseId).Error(0)
}

func (m *MockCache) IncrementSeats(ctx context.Context, courseId string) error {
    return m.Called(ctx, courseId).Error(0)
}

type MockEventPublisher struct {
    mock.Mock
}

func (m *MockEventPublisher) Publish(ctx context.Context, topic string, event interface{}) error {
    return m.Called(ctx, topic, event).Error(0)
}

type MockIdempotency struct {
    mock.Mock
}

func (m *MockIdempotency) Check(ctx context.Context, key string) (bool, *enrollment.Enrollment) {
    args := m.Called(ctx, key)
    if args.Get(1) == nil {
        return args.Bool(0), nil
    }
    return args.Bool(0), args.Get(1).(*enrollment.Enrollment)
}

func (m *MockIdempotency) Store(ctx context.Context, key string, enr *enrollment.Enrollment, ttl time.Duration) error {
    return m.Called(ctx, key, enr, ttl).Error(0)
}

// ============================================================
// TESTES
// ============================================================

func TestEnrollmentProcessor_Process_Success(t *testing.T) {
    // Arrange: Setup mocks
    ctx := context.Background()

    mockStudentRepo := &MockStudentRepo{}
    mockCourseRepo := &MockCourseRepo{}
    mockEnrollmentRepo := &MockEnrollmentRepo{}
    mockPaymentProvider := &MockPaymentProvider{}
    mockCache := &MockCache{}
    mockEventPublisher := &MockEventPublisher{}
    mockIdempotency := &MockIdempotency{}

    processor := enrollment_processor.NewEnrollmentProcessor(
        mockStudentRepo,
        mockCourseRepo,
        mockEnrollmentRepo,
        mockPaymentProvider,
        mockCache,
        mockEventPublisher,
        mockIdempotency,
    )

    // Setup: Dados de teste
    studentId := "student-123"
    courseId := "course-456"
    idempotencyKey := "idempotency-789"

    testStudent := &student.Student{
        Id:              studentId,
        Name:            "John Doe",
        Status:          student.StatusActive,
        EnrolledCourses: []string{},  // 0 cursos (pode matricular)
    }

    testCourse := &course.Course{
        Id:               courseId,
        Name:             "Calculus I",
        Capacity:         30,
        EnrolledStudents: 10,  // 20 vagas disponíveis
        Prerequisites:    []string{},
        Price:            500.0,
    }

    testPayment := &payment.Payment{
        Id:          "payment-abc",
        Amount:      500.0,
        Status:      payment.StatusCompleted,
        ProcessedAt: time.Now(),
    }

    // Mock expectations
    mockIdempotency.On("Check", ctx, idempotencyKey).Return(false, nil)  // Não processado ainda
    mockStudentRepo.On("FindByID", ctx, studentId).Return(testStudent, nil)
    mockCourseRepo.On("FindByID", ctx, courseId).Return(testCourse, nil)
    mockCache.On("GetAvailableSeats", ctx, courseId).Return(20, nil)
    mockCache.On("DecrementSeats", ctx, courseId).Return(nil)
    mockPaymentProvider.On("Charge", ctx, 500.0, payment.MethodCreditCard, mock.Anything).Return(testPayment, nil)
    mockEnrollmentRepo.On("Save", ctx, mock.AnythingOfType("*enrollment.Enrollment")).Return(nil)
    mockStudentRepo.On("AddEnrolledCourse", ctx, studentId, courseId).Return(nil)
    mockIdempotency.On("Store", ctx, idempotencyKey, mock.Anything, 24*time.Hour).Return(nil)

    req := enrollment_processor.ProcessEnrollmentRequest{
        StudentId:      studentId,
        CourseId:       courseId,
        PaymentMethod:  payment.MethodCreditCard,
        IdempotencyKey: idempotencyKey,
    }

    // Act: Processar matrícula
    result, err := processor.Process(ctx, req)

    // Assert: Verificar sucesso
    require.NoError(t, err)
    require.NotNil(t, result)
    assert.Equal(t, studentId, result.StudentId)
    assert.Equal(t, courseId, result.CourseId)
    assert.Equal(t, testPayment.Id, result.PaymentId)
    assert.Equal(t, enrollment.StatusActive, result.Status)

    // Verificar que TODAS as operações foram chamadas
    mockStudentRepo.AssertExpectations(t)
    mockCourseRepo.AssertExpectations(t)
    mockEnrollmentRepo.AssertExpectations(t)
    mockPaymentProvider.AssertExpectations(t)
    mockCache.AssertExpectations(t)
    mockIdempotency.AssertExpectations(t)
}

func TestEnrollmentProcessor_Process_PaymentFails_Rollback(t *testing.T) {
    // Arrange: Setup mocks
    ctx := context.Background()

    mockStudentRepo := &MockStudentRepo{}
    mockCourseRepo := &MockCourseRepo{}
    mockEnrollmentRepo := &MockEnrollmentRepo{}
    mockPaymentProvider := &MockPaymentProvider{}
    mockCache := &MockCache{}
    mockEventPublisher := &MockEventPublisher{}
    mockIdempotency := &MockIdempotency{}

    processor := enrollment_processor.NewEnrollmentProcessor(
        mockStudentRepo,
        mockCourseRepo,
        mockEnrollmentRepo,
        mockPaymentProvider,
        mockCache,
        mockEventPublisher,
        mockIdempotency,
    )

    studentId := "student-123"
    courseId := "course-456"
    idempotencyKey := "idempotency-789"

    testStudent := &student.Student{
        Id:              studentId,
        Status:          student.StatusActive,
        EnrolledCourses: []string{},
    }

    testCourse := &course.Course{
        Id:               courseId,
        Capacity:         30,
        EnrolledStudents: 10,
        Prerequisites:    []string{},
        Price:            500.0,
    }

    // Mock expectations
    mockIdempotency.On("Check", ctx, idempotencyKey).Return(false, nil)
    mockStudentRepo.On("FindByID", ctx, studentId).Return(testStudent, nil)
    mockCourseRepo.On("FindByID", ctx, courseId).Return(testCourse, nil)
    mockCache.On("GetAvailableSeats", ctx, courseId).Return(20, nil)
    mockCache.On("DecrementSeats", ctx, courseId).Return(nil)

    // Pagamento falha (cartão recusado)
    mockPaymentProvider.On("Charge", ctx, 500.0, payment.MethodCreditCard, mock.Anything).
        Return(nil, payment.ErrInsufficientFunds)

    // ⭐ COMPENSAÇÃO: cache deve incrementar vagas de volta
    mockCache.On("IncrementSeats", mock.Anything, courseId).Return(nil)

    req := enrollment_processor.ProcessEnrollmentRequest{
        StudentId:      studentId,
        CourseId:       courseId,
        PaymentMethod:  payment.MethodCreditCard,
        IdempotencyKey: idempotencyKey,
    }

    // Act: Processar matrícula (deve falhar)
    result, err := processor.Process(ctx, req)

    // Assert: Verificar falha
    require.Error(t, err)
    assert.Nil(t, result)
    assert.Contains(t, err.Error(), "payment failed")

    // ⭐ VERIFICAR COMPENSAÇÃO: IncrementSeats foi chamado
    mockCache.AssertCalled(t, "IncrementSeats", mock.Anything, courseId)

    // Verificar que enrollment NÃO foi salvo
    mockEnrollmentRepo.AssertNotCalled(t, "Save", mock.Anything, mock.Anything)
}

func TestEnrollmentProcessor_Process_Idempotency(t *testing.T) {
    // Arrange: Setup mocks
    ctx := context.Background()

    mockStudentRepo := &MockStudentRepo{}
    mockCourseRepo := &MockCourseRepo{}
    mockEnrollmentRepo := &MockEnrollmentRepo{}
    mockPaymentProvider := &MockPaymentProvider{}
    mockCache := &MockCache{}
    mockEventPublisher := &MockEventPublisher{}
    mockIdempotency := &MockIdempotency{}

    processor := enrollment_processor.NewEnrollmentProcessor(
        mockStudentRepo,
        mockCourseRepo,
        mockEnrollmentRepo,
        mockPaymentProvider,
        mockCache,
        mockEventPublisher,
        mockIdempotency,
    )

    idempotencyKey := "idempotency-789"

    // Enrollment já processado anteriormente
    existingEnrollment := &enrollment.Enrollment{
        Id:        "existing-enr-123",
        StudentId: "student-123",
        CourseId:  "course-456",
        Status:    enrollment.StatusActive,
    }

    // Mock: idempotência retorna enrollment anterior
    mockIdempotency.On("Check", ctx, idempotencyKey).Return(true, existingEnrollment)

    req := enrollment_processor.ProcessEnrollmentRequest{
        StudentId:      "student-123",
        CourseId:       "course-456",
        PaymentMethod:  payment.MethodCreditCard,
        IdempotencyKey: idempotencyKey,
    }

    // Act: Processar matrícula (retry)
    result, err := processor.Process(ctx, req)

    // Assert: Retorna enrollment anterior, sem reprocessar
    require.NoError(t, err)
    require.NotNil(t, result)
    assert.Equal(t, existingEnrollment.Id, result.Id)

    // ⭐ VERIFICAR: nenhuma operação foi executada (idempotência funcionou)
    mockStudentRepo.AssertNotCalled(t, "FindByID", mock.Anything, mock.Anything)
    mockCourseRepo.AssertNotCalled(t, "FindByID", mock.Anything, mock.Anything)
    mockPaymentProvider.AssertNotCalled(t, "Charge", mock.Anything, mock.Anything, mock.Anything, mock.Anything)
}
```

**Por que tantos mocks?**

Processor coordena **7 dependências**:
1. StudentRepo
2. CourseRepo
3. EnrollmentRepo
4. PaymentProvider
5. Cache
6. EventPublisher
7. IdempotencyChecker

Cada uma precisa de mock para testar isoladamente.

**Por que testar compensação explicitamente?**

Teste `PaymentFails_Rollback` verifica que:
1. Cache incrementa vagas de volta (`IncrementSeats` chamado)
2. Enrollment NÃO é salvo (`Save` não chamado)

Sem este teste, bug em compensação passaria despercebido até produção.

---

## Comparação: CRUD vs Orquestração

| Aspecto | CRUD Básico | Orquestração Avançada |
|---------|-------------|----------------------|
| **Agregados** | 1 (Student) | 4 (Student, Course, Enrollment, Payment) |
| **Operações** | Simples (FindByID, Save) | Complexas (Saga com 4 passos) |
| **Transações** | Local (PostgreSQL) | Distribuída (DB + Stripe + Cache) |
| **Compensação** | Rollback automático (SQL) | Rollback manual (Saga pattern) |
| **Resiliência** | Nenhuma | Circuit breaker (Stripe offline) |
| **Idempotência** | Não | Sim (retry seguro) |
| **Eventos** | Não | Pub/Sub assíncrono (RabbitMQ) |
| **Linhas de código** | ~500 | ~2000 |
| **Complexidade** | Júnior consegue | Pleno/Sênior |

---

## Quando Usar Cada Abordagem?

### Use CRUD simples quando:
- ✅ Operação envolve apenas 1 agregado
- ✅ Todas operações são locais (mesmo banco)
- ✅ Não precisa integrar APIs externas
- ✅ Falha = rollback automático funciona

### Use Orquestração com Saga quando:
- ✅ Operação envolve múltiplos sistemas (DB + API externa + cache)
- ✅ Precisa garantir consistência eventual
- ✅ Dependências externas podem falhar (payment gateway offline)
- ✅ Cliente pode fazer retry (precisa idempotência)
- ✅ Necessita publicar eventos para consumidores assíncronos

---

## Referências

- 📚 **Saga Pattern** — [Microservices Patterns (Chris Richardson)](https://microservices.io/patterns/data/saga.html)
- 📚 **Circuit Breaker** — [Release It! (Michael Nygard)](https://pragprog.com/titles/mnee2/release-it-second-edition/)
- 🔗 **Idempotency** — [Stripe API Design](https://stripe.com/docs/api/idempotent_requests)
- 🔗 **Compensating Transactions** — [Martin Fowler](https://martinfowler.com/articles/patterns-of-distributed-systems/compensating-transaction.html)

---

**Próximo:** [Checklist de Code Review](09-checklist.md) | **Anterior:** [CRUD Completo](07-exemplo-crud-completo.md) | **Voltar para:** [Índice](README.md)

**Última atualização:** 03/11/2025 16:42
