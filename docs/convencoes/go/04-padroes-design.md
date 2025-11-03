# Padrões de Design em Go

> **"Padrões não são para copiar — são para adaptar ao contexto."**

Go não tem herança. Não tem decorators. Não tem anotações. Os padrões clássicos do Gang of Four (GoF) precisam ser **radicalmente adaptados** para funcionar idiomaticamente.

O que funciona em Java/C# (classes abstratas, herança múltipla, reflection pesada) gera **código não-idiomático** em Go. A linguagem força simplicidade: interfaces pequenas, composição sobre herança, explícito sobre implícito.

## Por que padrões importam em Go?

1. **Repository encapsula persistência** — Domain não conhece SQL/MongoDB
2. **Service Layer orquestra domínio** — Evita lógica de negócio em controllers
3. **Dependency Injection com Fx** — Montagem de grafo sem `new` manual espalhado
4. **Factory valida construção** — Garante que structs nascem válidos
5. **Strategy permite polimorfismo** — Trocar algoritmos em runtime (ex: provedores de email)
6. **Observer desacopla eventos** — Publicar evento sem conhecer consumidores

Este guia adapta padrões clássicos para **Go idiomático**, não para Java traduzido.

---

## Padrão Repository

**Regra:** Interfaces de repositório no domínio, implementações na infraestrutura.

**O problema que resolve:**

Sem Repository, seu domain fica **acoplado** ao banco de dados:

```go
// ❌ SEM REPOSITORY - Domain acoplado a PostgreSQL
package student

import "github.com/jackc/pgx/v5/pgxpool"

type Service struct {
    pool *pgxpool.Pool  // ❌ Domain conhece PostgreSQL!
}

func (s *Service) CreateStudent(name string) error {
    // ❌ SQL direto no domain
    _, err := s.pool.Exec("INSERT INTO students...")
    return err
}
```

**Consequências:**
1. **Testes lentos:** Precisa de banco real para testar `Service`
2. **Inflexível:** Trocar PostgreSQL → MongoDB = reescrever `Service`
3. **Viola SOLID:** Domain depende de infra (inversão errada)

**Solução com Repository:**

```go
// ✅ COM REPOSITORY - Domain define interface
package student

type Repository interface {  // Interface no domain
    Save(ctx context.Context, student *Student) error
    FindByID(ctx context.Context, id string) (*Student, error)
}

type Service struct {
    repo Repository  // ✅ Domain depende de interface, não implementação
}

func (s *Service) CreateStudent(ctx context.Context, name string) error {
    student := &Student{Name: name}
    return s.repo.Save(ctx, student)  // Não sabe se é PostgreSQL, MongoDB, in-memory
}
```

**Por que separar interface de implementação?**

1. **Inversão de Dependência (SOLID):** Domain define O QUE precisa, Infra implementa COMO
2. **Testabilidade:** Mock `Repository` para testar `Service` sem banco (testes em <10ms)
3. **Flexibilidade:** Trocar PostgreSQL → MongoDB? Apenas muda `infra/`, domain intocado

**Trade-off:** Mais arquivos e indireção. Compensa em:
- ✅ Projetos com múltiplas fontes de dados
- ✅ Necessidade de testes rápidos (CI/CD)
- ✅ Times grandes (domain e infra evoluem independentes)

**Quando NÃO usar:**
- ❌ CRUD simples com 1 dev
- ❌ Protótipos descartáveis
- ❌ Scripts de migração/admin

**Referências:**
- 📚 Martin Fowler - [Patterns of Enterprise Application Architecture](https://martinfowler.com/books/eaa.html)
- 🔗 [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)
- 📚 Eric Evans - Domain-Driven Design (Cap. 6: Lifecycle of Domain Objects)

#### ✅ Recomendado
```go
// internal/domain/student/repository.go
package student

import "context"

type Repository interface {
    Save(ctx context.Context, student *Student) error
    FindByID(ctx context.Context, id string) (*Student, error)
    FindByEmail(ctx context.Context, email string) (*Student, error)
    Update(ctx context.Context, student *Student) error
    Delete(ctx context.Context, id string) error
    List(ctx context.Context, filter Filter) ([]*Student, error)
}

// internal/infra/persistence/postgres/student_repository.go
package postgres

import (
    "context"
    "fmt"

    "github.com/jackc/pgx/v5/pgxpool"

    "github.com/company/school/internal/domain/student"
)

type StudentRepository struct {
    pool *pgxpool.Pool
}

func NewStudentRepository(pool *pgxpool.Pool) student.Repository {
    return &StudentRepository{pool: pool}
}

func (r *StudentRepository) Save(ctx context.Context, s *student.Student) error {
    query := `
        INSERT INTO students (id, name, email, birth_date, created_at)
        VALUES ($1, $2, $3, $4, $5)
    `

    _, err := r.pool.Exec(ctx, query, s.Id, s.Name, s.Email, s.BirthDate, s.CreatedAt)
    if err != nil {
        return fmt.Errorf("save student: %w", err)
    }

    return nil
}

func (r *StudentRepository) FindByID(ctx context.Context, id string) (*student.Student, error) {
    query := `SELECT id, name, email, birth_date, created_at FROM students WHERE id = $1`

    var s student.Student
    err := r.pool.QueryRow(ctx, query, id).Scan(&s.Id, &s.Name, &s.Email, &s.BirthDate, &s.CreatedAt)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, student.ErrStudentNotFound
        }
        return nil, fmt.Errorf("find student by id: %w", err)
    }

    return &s, nil
}
```

**Referências:**
- 📚 Martin Fowler - [Patterns of Enterprise Application Architecture](https://martinfowler.com/books/eaa.html)
- 🔗 [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)

---

## Padrão Service Layer

**Regra:** Serviços orquestram operações de domínio, coordenam repositórios e validações.

**O problema que resolve:**

Sem Service Layer, você tem duas opções ruins:

**Opção 1: Lógica no Controller (❌)**
```go
// ❌ Controller gordo - HTTP handler com lógica de negócio
func (h *StudentHandler) Create(c *gin.Context) {
    var req CreateStudentRequest
    c.BindJSON(&req)

    // ❌ Validação no controller
    if req.Email == "" {
        c.JSON(400, "email required")
        return
    }

    // ❌ Lógica de negócio no controller
    existing, _ := h.repo.FindByEmail(req.Email)
    if existing != nil {
        c.JSON(409, "email exists")
        return
    }

    // ❌ Construção no controller
    student := &Student{Name: req.Name, Email: req.Email}
    h.repo.Save(student)

    // ❌ Evento no controller
    h.publisher.Publish("student.created", student)

    c.JSON(201, student)
}
```

**Problemas:**
- Lógica duplicada (HTTP handler, gRPC handler, CLI precisam repetir tudo)
- Difícil testar (precisa mockar HTTP context)
- Viola Single Responsibility (controller faz HTTP + validação + persistência + eventos)

**Opção 2: Lógica no Repository (❌)**
```go
// ❌ Repository gordo - persistência + validação + eventos
func (r *StudentRepository) Save(student *Student) error {
    // ❌ Validação no repository
    if student.Email == "" {
        return errors.New("invalid")
    }

    // ❌ Repository consultando para validar
    existing, _ := r.FindByEmail(student.Email)
    if existing != nil {
        return errors.New("duplicate")
    }

    // SQL...
    r.db.Exec("INSERT...")

    // ❌ Repository publicando evento
    r.publisher.Publish("student.created")
    return nil
}
```

**Problemas:**
- Repository deveria apenas persistir, não validar
- Difícil testar validação sem banco
- Viola Single Responsibility

**Solução: Service Layer (✅)**

```go
// ✅ Service orquestra tudo
package student

type Service struct {
    repo      Repository
    validator Validator
    publisher EventPublisher
}

func (s *Service) CreateStudent(ctx context.Context, name, email string) (*Student, error) {
    // 1. Validar entrada
    if err := s.validator.ValidateEmail(email); err != nil {
        return nil, fmt.Errorf("invalid email: %w", err)
    }

    // 2. Verificar duplicação (regra de negócio)
    existing, _ := s.repo.FindByEmail(ctx, email)
    if existing != nil {
        return nil, ErrDuplicateEmail
    }

    // 3. Criar entidade (domain)
    student, err := NewStudent(name, email)
    if err != nil {
        return nil, err
    }

    // 4. Persistir
    if err := s.repo.Save(ctx, student); err != nil {
        return nil, fmt.Errorf("save student: %w", err)
    }

    // 5. Publicar evento
    s.publisher.Publish(ctx, Event{Type: "student.created", Data: student})

    return student, nil
}
```

**Benefícios:**
- ✅ Controller fino (apenas converte JSON → chama service → retorna HTTP)
- ✅ Reuso (HTTP, gRPC, CLI, Worker usam mesmo service)
- ✅ Testável (mocka repo, validator, publisher)
- ✅ Transações (pode envolver múltiplos repos em uma transação)

**Trade-off:** Mais uma camada. Compensa em:
- ✅ Projetos com múltiplos pontos de entrada (HTTP + gRPC + CLI)
- ✅ Lógica de orquestração complexa
- ✅ Necessidade de transações

**Quando NÃO usar:**
- ❌ CRUD puro (FindByID → retorna, sem validação extra)
- ❌ Protótipos simples

**Referências:**
- 📚 Martin Fowler - [Patterns of Enterprise Application Architecture](https://martinfowler.com/books/eaa.html) (Service Layer)
- 📚 Vaughn Vernon - Implementing Domain-Driven Design (Cap. 14: Application Services)

#### ✅ Recomendado
```go
// internal/domain/student/service.go
package student

import (
    "context"
    "fmt"
)

type Service struct {
    repository Repository
    validator  Validator
}

func NewService(repository Repository, validator Validator) *Service {
    return &Service{
        repository: repository,
        validator:  validator,
    }
}

func (s *Service) CreateStudent(ctx context.Context, name, email string) (*Student, error) {
    // Validação
    if err := s.validator.ValidateEmail(email); err != nil {
        return nil, fmt.Errorf("validate email: %w", err)
    }

    // Verificar duplicata
    existing, err := s.repository.FindByEmail(ctx, email)
    if err != nil && !errors.Is(err, ErrStudentNotFound) {
        return nil, fmt.Errorf("check existing student: %w", err)
    }
    if existing != nil {
        return nil, ErrDuplicateEmail
    }

    // Criar entidade
    student, err := NewStudent(name, email)
    if err != nil {
        return nil, fmt.Errorf("create student entity: %w", err)
    }

    // Persistir
    if err := s.repository.Save(ctx, student); err != nil {
        return nil, fmt.Errorf("save student: %w", err)
    }

    return student, nil
}

func (s *Service) UpdateStudentEmail(ctx context.Context, studentId, newEmail string) error {
    // Buscar estudante existente
    student, err := s.repository.FindByID(ctx, studentId)
    if err != nil {
        return fmt.Errorf("find student: %w", err)
    }

    // Validar novo email
    if err := s.validator.ValidateEmail(newEmail); err != nil {
        return fmt.Errorf("validate email: %w", err)
    }

    // Atualizar (método de domínio)
    if err := student.UpdateEmail(newEmail); err != nil {
        return fmt.Errorf("update email: %w", err)
    }

    // Persistir
    if err := s.repository.Update(ctx, student); err != nil {
        return fmt.Errorf("update student: %w", err)
    }

    return nil
}
```

---

## Injeção de Dependências (Uber Fx)

**Regra:** Usar Fx para gerenciar ciclo de vida e injeção de dependências.

**O problema que resolve:**

Sem DI, você tem **grafo de dependências manual** espalhado pelo código:

```go
// ❌ SEM DI - main.go monolítico
func main() {
    // Infra
    pool := pgxpool.New("postgres://...")
    cache := redis.NewClient(...)
    emailClient := sendgrid.New("api-key")

    // Domain
    studentRepo := postgres.NewStudentRepository(pool)
    courseRepo := postgres.NewCourseRepository(pool)
    studentValidator := student.NewValidator()
    
    // Services
    studentService := student.NewService(studentRepo, studentValidator)
    enrollmentService := enrollment.NewService(
        studentRepo,      // Precisa de student
        courseRepo,       // Precisa de course
        studentService,   // Precisa de service
        emailClient,      // Precisa de email
        cache,            // Precisa de cache
    )

    // API
    studentHandler := handler.NewStudentHandler(studentService)
    enrollmentHandler := handler.NewEnrollmentHandler(enrollmentService)

    // HTTP
    router := gin.Default()
    router.POST("/students", studentHandler.Create)
    router.POST("/enrollments", enrollmentHandler.Create)
    router.Run(":8080")
}
```

**Problemas:**
1. **Ordem importa:** Precisa criar `studentRepo` antes de `studentService`
2. **Difícil mudar:** Adicionar dependência = alterar `main.go` + todos construtores
3. **Não escala:** 50 services = 200+ linhas de `new()` em `main.go`
4. **Sem lifecycle:** Fechar conexões de DB/cache manualmente

**Solução com Fx:**

Fx **monta o grafo automaticamente** via reflexão. Você declara o que cada módulo precisa/fornece, Fx resolve ordem e injeta.

```go
// ✅ COM FX - main.go mínimo
func main() {
    fx.New(
        // Módulos de infra
        config.Module,
        postgres.Module,
        redis.Module,
        email.Module,

        // Módulos de domain
        student.Module,
        course.Module,
        enrollment.Module,

        // Módulo de API
        api.Module,

        // Invocar inicialização do servidor
        fx.Invoke(api.Start),
    ).Run()
}

// internal/domain/student/module.go
var Module = fx.Module(
    "student",
    fx.Provide(
        NewService,      // Fx vê que Service precisa de Repository + Validator
        NewValidator,    // Fx injeta automaticamente
    ),
)

// internal/infra/postgres/module.go
var Module = fx.Module(
    "postgres",
    fx.Provide(
        NewPool,                    // Cria pool
        NewStudentRepository,       // Recebe pool automaticamente
        NewCourseRepository,
        fx.Annotate(
            NewStudentRepository,
            fx.As(new(student.Repository)),  // Registra como interface
        ),
    ),
)
```

**Benefícios:**

1. **Grafo automático:** Fx calcula ordem de construção
2. **Lifecycle gerenciado:** Fx chama `Close()` automaticamente no shutdown
3. **Modular:** Cada package exporta `Module`, `main.go` apenas compõe
4. **Type-safe:** Erros de dependência em **tempo de inicialização**, não runtime
5. **Testável:** Pode substituir módulos inteiros (ex: trocar postgres.Module por inmemory.Module em testes)

**Trade-offs:**

| Vantagem | Desvantagem |
|----------|-------------|
| ✅ Grafo automático | ❌ Curva de aprendizado (anotações, reflexão) |
| ✅ Lifecycle gerenciado | ❌ Erros de DI às vezes crípticos |
| ✅ Modular/escalável | ❌ Overhead de reflexão (mínimo) |

**Quando usar:**
- ✅ Projetos com 10+ services/repositories
- ✅ Múltiplos binários (`cmd/api`, `cmd/worker`) compartilhando módulos
- ✅ Necessidade de trocar implementações facilmente (testes, staging, prod)

**Quando NÃO usar:**
- ❌ Projetos simples (3-5 structs)
- ❌ Scripts/ferramentas de linha de comando descartáveis

**Referências:**
- 🔗 [Uber Fx Documentation](https://uber-go.github.io/fx/)
- 🔗 [Dependency Injection in Go](https://blog.drewolson.org/dependency-injection-in-go)
- 📚 Dependency Injection Principles, Practices, and Patterns (Mark Seemann)

#### ✅ Recomendado
```go
// internal/domain/student/module.go
package student

import "go.uber.org/fx"

var Module = fx.Module(
    "student",
    fx.Provide(
        NewService,
        NewValidator,
    ),
)

// internal/infra/persistence/postgres/module.go
package postgres

import (
    "go.uber.org/fx"

    "github.com/company/school/internal/domain/student"
)

var Module = fx.Module(
    "postgres",
    fx.Provide(
        NewPool,
        fx.Annotate(
            NewStudentRepository,
            fx.As(new(student.Repository)),  // Vincula implementação à interface
        ),
    ),
)

// cmd/api/main.go
package main

import (
    "go.uber.org/fx"

    "github.com/company/school/internal/api"
    "github.com/company/school/internal/domain/student"
    "github.com/company/school/internal/infra/config"
    "github.com/company/school/internal/infra/persistence/postgres"
)

func main() {
    fx.New(
        // Configuração
        config.Module,

        // Infrastructure
        postgres.Module,

        // Domain
        student.Module,

        // API
        api.Module,

        // Lifecycle hooks
        fx.Invoke(func(lc fx.Lifecycle, srv *api.Server) {
            lc.Append(fx.Hook{
                OnStart: func(ctx context.Context) error {
                    return srv.Start(ctx)
                },
                OnStop: func(ctx context.Context) error {
                    return srv.Shutdown(ctx)
                },
            })
        }),
    ).Run()
}
```

**Referências:**
- 🔗 [Uber Fx](https://uber-go.github.io/fx/) - Documentação oficial
- 🔗 [Fx Examples](https://github.com/uber-go/fx/tree/master/examples)

---

## Padrão Factory

**Regra:** Usar construtores `New*` para inicialização com validação.

**O problema que resolve:**

Sem Factory, structs nascem **inválidos**:

```go
// ❌ SEM FACTORY - Struct inválido
student := &Student{}  // ❌ ID vazio, timestamps zerados
student.Name = "John"
// Esqueceu de preencher Email, CreatedAt, Status...
repo.Save(student)  // ❌ Salva lixo no banco
```

**Solução:**

Factory **garante construção válida**:

```go
// ✅ COM FACTORY
func NewStudent(name, email string) (*Student, error) {
    if name == "" {
        return nil, ErrInvalidName
    }
    if !isValidEmail(email) {
        return nil, ErrInvalidEmail
    }

    return &Student{
        Id:        generateID(),      // ✅ Sempre preenchido
        Name:      name,
        Email:     email,
        CreatedAt: time.Now(),       // ✅ Timestamp automático
        Status:    StatusActive,     // ✅ Estado inicial padrão
    }, nil
}

// Uso
student, err := NewStudent("John", "john@school.edu")
if err != nil {
    return err  // ✅ Erro na construção, não em runtime
}
```

**Quando usar:**
- ✅ Structs com campos obrigatórios
- ✅ Validação na construção
- ✅ Inicialização com valores padrão/computados

**Referências:**
- 📚 Gang of Four - Design Patterns (Factory Method)
- 🔗 [Effective Go - Constructors](https://go.dev/doc/effective_go#constructors_and_composite_literals)

#### ✅ Recomendado
```go
// Construtor simples
func NewService(repo Repository) *Service {
    return &Service{repository: repo}
}

// Construtor com validação
func NewStudent(name, email string) (*Student, error) {
    if name == "" {
        return nil, ErrInvalidName
    }

    if !isValidEmail(email) {
        return nil, ErrInvalidEmail
    }

    return &Student{
        Id:        generateID(),
        Name:      name,
        Email:     email,
        CreatedAt: time.Now(),
        Status:    StatusActive,
    }, nil
}

// Functional options pattern (para muitos parâmetros opcionais)
type ServerOption func(*Server)

func WithPort(port int) ServerOption {
    return func(s *Server) {
        s.port = port
    }
}

func WithTimeout(timeout time.Duration) ServerOption {
    return func(s *Server) {
        s.timeout = timeout
    }
}

func NewServer(opts ...ServerOption) *Server {
    server := &Server{
        port:    8080,              // Default
        timeout: 30 * time.Second,  // Default
    }

    for _, opt := range opts {
        opt(server)
    }

    return server
}

// Uso
server := NewServer(
    WithPort(9090),
    WithTimeout(60 * time.Second),
)
```

**Referências:**
- 🔗 [Functional Options Pattern](https://dave.cheney.net/2014/10/17/functional-options-for-friendly-apis)

---

## Padrão Strategy

**Regra:** Usar interfaces para comportamentos intercambiáveis.

**O problema que resolve:**

Sem Strategy, você tem **if/switch gigantes**:

```go
// ❌ SEM STRATEGY - Lógica acoplada
type EmailService struct {
    provider string  // "sendgrid" ou "mailgun" ou "ses"
}

func (s *EmailService) Send(email Email) error {
    if s.provider == "sendgrid" {
        // Código Sendgrid...
        client := sendgrid.NewClient(...)
        client.Send(...)
    } else if s.provider == "mailgun" {
        // Código Mailgun...
        client := mailgun.NewClient(...)
        client.Send(...)
    } else if s.provider == "ses" {
        // Código AWS SES...
        client := ses.New(...)
        client.SendEmail(...)
    }
    // ❌ Adicionar provedor = modificar este método (viola Open/Closed)
}
```

**Solução com Strategy:**

```go
// ✅ COM STRATEGY - Polimorfismo
type EmailProvider interface {  // Strategy
    Send(ctx context.Context, email Email) error
}

type EmailService struct {
    provider EmailProvider  // Abstração
}

// Implementação 1
type SendgridProvider struct { apiKey string }
func (p *SendgridProvider) Send(ctx context.Context, email Email) error { ... }

// Implementação 2
type MailgunProvider struct { domain, apiKey string }
func (p *MailgunProvider) Send(ctx context.Context, email Email) error { ... }

// Uso - trocar em runtime
service := &EmailService{
    provider: &SendgridProvider{apiKey: "..."},  // Prod
    // provider: &MailgunProvider{...},           // Staging
    // provider: &MockProvider{},                 // Testes
}
```

**Benefícios:**
- ✅ Adicionar provedor = nova struct, sem tocar em código existente (Open/Closed)
- ✅ Trocar implementação em runtime (prod vs teste)
- ✅ Testável (mock provider)

**Quando usar:**
- ✅ Múltiplas implementações de mesmo comportamento (provedores externos, algoritmos)
- ✅ Necessidade de trocar estratégia em runtime
- ✅ Evitar if/switch baseado em strings/enums

**Referências:**
- 📚 Gang of Four - Design Patterns (Strategy Pattern)
- 🔗 [Strategy Pattern in Go](https://refactoring.guru/design-patterns/strategy/go/example)

#### ✅ Recomendado
```go
// internal/domain/grade/calculator.go
package grade

import "context"

// Strategy interface
type GradeCalculator interface {
    Calculate(ctx context.Context, grades []float64) (float64, error)
    Name() string
}

// Implementação 1: Média simples
type SimpleAverageCalculator struct{}

func NewSimpleAverageCalculator() GradeCalculator {
    return &SimpleAverageCalculator{}
}

func (c *SimpleAverageCalculator) Calculate(ctx context.Context, grades []float64) (float64, error) {
    if len(grades) == 0 {
        return 0, ErrNoGrades
    }

    sum := 0.0
    for _, grade := range grades {
        sum += grade
    }

    return sum / float64(len(grades)), nil
}

func (c *SimpleAverageCalculator) Name() string {
    return "simple_average"
}

// Implementação 2: Média ponderada
type WeightedAverageCalculator struct {
    weights []float64
}

func NewWeightedAverageCalculator(weights []float64) GradeCalculator {
    return &WeightedAverageCalculator{weights: weights}
}

func (c *WeightedAverageCalculator) Calculate(ctx context.Context, grades []float64) (float64, error) {
    if len(grades) != len(c.weights) {
        return 0, ErrInvalidWeights
    }

    sum := 0.0
    totalWeight := 0.0

    for i, grade := range grades {
        sum += grade * c.weights[i]
        totalWeight += c.weights[i]
    }

    return sum / totalWeight, nil
}

func (c *WeightedAverageCalculator) Name() string {
    return "weighted_average"
}

// Context/Service usando a strategy
type GradeService struct {
    calculator GradeCalculator
    repository GradeRepository
}

func NewGradeService(calculator GradeCalculator, repository GradeRepository) *GradeService {
    return &GradeService{
        calculator: calculator,
        repository: repository,
    }
}

func (s *GradeService) CalculateFinalGrade(ctx context.Context, studentId string) (float64, error) {
    grades, err := s.repository.GetGradesByStudent(ctx, studentId)
    if err != nil {
        return 0, fmt.Errorf("get grades: %w", err)
    }

    finalGrade, err := s.calculator.Calculate(ctx, grades)
    if err != nil {
        return 0, fmt.Errorf("calculate final grade: %w", err)
    }

    return finalGrade, nil
}
```

**Injeção com Fx:**
```go
// internal/domain/grade/module.go
var Module = fx.Module(
    "grade",
    fx.Provide(
        // Strategies
        fx.Annotate(
            NewSimpleAverageCalculator,
            fx.As(new(GradeCalculator)),
            fx.ResultTags(`name:"simple"`),
        ),
        fx.Annotate(
            NewWeightedAverageCalculator,
            fx.As(new(GradeCalculator)),
            fx.ResultTags(`name:"weighted"`),
        ),

        // Service (injeta strategy baseada em config)
        NewGradeService,
    ),
)
```

**Referências:**
- 📚 Gang of Four - Design Patterns: Elements of Reusable Object-Oriented Software
- 🔗 [Strategy Pattern](https://refactoring.guru/design-patterns/strategy)

---

## Padrão Observer (Event-Driven)

**Regra:** Usar channels ou event bus para comunicação assíncrona entre componentes.

**O problema que resolve:**

Sem Observer, serviços ficam **acoplados**:

```go
// ❌ SEM OBSERVER - Acoplamento direto
type StudentService struct {
    repo         Repository
    emailService EmailService      // ❌ Acoplado a email
    analyticsService AnalyticsService  // ❌ Acoplado a analytics
}

func (s *StudentService) CreateStudent(ctx context.Context, name string) error {
    student := &Student{Name: name}
    s.repo.Save(ctx, student)

    // ❌ StudentService precisa conhecer TODOS os side-effects
    s.emailService.SendWelcome(ctx, student)
    s.analyticsService.Track(ctx, "student_created", student.Id)

    // ❌ Adicionar novo side-effect = modificar StudentService
    // s.notificationService.Notify(...)
    // s.webhookService.Trigger(...)
    return nil
}
```

**Problema:** `StudentService` não deveria saber sobre email, analytics, webhooks. Viola Single Responsibility.

**Solução com Observer:**

```go
// ✅ COM OBSERVER - Desacoplado via eventos
type EventPublisher interface {
    Publish(ctx context.Context, event Event) error
}

type StudentService struct {
    repo      Repository
    publisher EventPublisher  // ✅ Publica eventos, não conhece consumidores
}

func (s *StudentService) CreateStudent(ctx context.Context, name string) error {
    student := &Student{Name: name}
    s.repo.Save(ctx, student)

    // ✅ Publica evento genérico
    s.publisher.Publish(ctx, Event{
        Type: "student.created",
        Data: student,
    })

    return nil
}

// Consumidores se inscrevem independentemente
type EmailHandler struct { client EmailClient }
func (h *EmailHandler) Handle(ctx context.Context, event Event) error {
    if event.Type == "student.created" {
        student := event.Data.(*Student)
        return h.client.SendWelcome(ctx, student)
    }
    return nil
}

type AnalyticsHandler struct { client AnalyticsClient }
func (h *AnalyticsHandler) Handle(ctx context.Context, event Event) error {
    if event.Type == "student.created" {
        return h.client.Track(ctx, "student_created", event.Data)
    }
    return nil
}

// Registro (em main ou módulo)
bus.Subscribe("student.created", emailHandler.Handle)
bus.Subscribe("student.created", analyticsHandler.Handle)
// ✅ Adicionar novo consumidor = apenas Subscribe, StudentService intocado
```

**Benefícios:**
- ✅ Desacoplamento (publisher não conhece subscribers)
- ✅ Extensível (adicionar handler sem modificar publisher)
- ✅ Assíncrono (handlers podem rodar em goroutines)

**Trade-offs:**

| Vantagem | Desvantagem |
|----------|-------------|
| ✅ Desacoplamento total | ❌ Debugging mais difícil (fluxo indireto) |
| ✅ Fácil adicionar handlers | ❌ Garantir ordem de execução é complexo |
| ✅ Escalável (RabbitMQ, Kafka) | ❌ Overhead de mensageria |

**Quando usar:**
- ✅ Side-effects de uma ação (criar student → enviar email + log + webhook)
- ✅ Múltiplos consumidores do mesmo evento
- ✅ Necessidade de processamento assíncrono

**Quando NÃO usar:**
- ❌ Fluxo síncrono crítico (criar student → retornar ID)
- ❌ Apenas 1 consumidor (use função direta)

**Referências:**
- 📚 Gang of Four - Design Patterns (Observer Pattern)
- 🔗 [Event-Driven Architecture](https://martinfowler.com/articles/201701-event-driven.html) - Martin Fowler
- 🔗 [Go Patterns - Pub/Sub](https://github.com/tmrts/go-patterns#pubsub)

#### ✅ Recomendado
```go
// internal/domain/student/event.go
package student

import "time"

type EventType string

const (
    EventStudentCreated EventType = "student.created"
    EventStudentUpdated EventType = "student.updated"
    EventStudentDeleted EventType = "student.deleted"
)

type Event struct {
    Type      EventType
    StudentId string
    Timestamp time.Time
    Data      map[string]interface{}
}

// internal/app/event/bus.go
package event

import (
    "context"
    "sync"
)

type Handler func(ctx context.Context, event Event) error

type Bus struct {
    handlers map[EventType][]Handler
    mutex    sync.RWMutex
}

func NewBus() *Bus {
    return &Bus{
        handlers: make(map[EventType][]Handler),
    }
}

func (b *Bus) Subscribe(eventType EventType, handler Handler) {
    b.mutex.Lock()
    defer b.mutex.Unlock()

    b.handlers[eventType] = append(b.handlers[eventType], handler)
}

func (b *Bus) Publish(ctx context.Context, event Event) error {
    b.mutex.RLock()
    handlers := b.handlers[event.Type]
    b.mutex.RUnlock()

    for _, handler := range handlers {
        if err := handler(ctx, event); err != nil {
            // Log error mas continua processando outros handlers
            log.Printf("handler error: %v", err)
        }
    }

    return nil
}

// Uso no Service
func (s *StudentService) CreateStudent(ctx context.Context, name, email string) (*Student, error) {
    student, err := NewStudent(name, email)
    if err != nil {
        return nil, err
    }

    if err := s.repository.Save(ctx, student); err != nil {
        return nil, err
    }

    // Publicar evento
    s.eventBus.Publish(ctx, Event{
        Type:      EventStudentCreated,
        StudentId: student.Id,
        Timestamp: time.Now(),
        Data: map[string]interface{}{
            "name":  student.Name,
            "email": student.Email,
        },
    })

    return student, nil
}

// Subscriber (outro serviço)
type NotificationService struct {
    eventBus *event.Bus
    sender   EmailSender
}

func (n *NotificationService) Init() {
    n.eventBus.Subscribe(student.EventStudentCreated, n.handleStudentCreated)
}

func (n *NotificationService) handleStudentCreated(ctx context.Context, event Event) error {
    // Enviar email de boas-vindas
    return n.sender.SendWelcomeEmail(ctx, event.StudentId)
}
```

**Referências:**
- 🔗 [Observer Pattern](https://refactoring.guru/design-patterns/observer)

---



---

**Próximo:** [Boas Práticas Go](05-boas-praticas.md) | **Anterior:** [Organização de Código](03-organizacao-codigo.md) | **Voltar para:** [Índice](README.md)

**Última atualização:** 03/11/2025 16:42
