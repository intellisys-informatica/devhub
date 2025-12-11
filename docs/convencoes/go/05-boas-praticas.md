# Boas Práticas Go

> **"Boas práticas não são regras — são lições que custaram bugs em produção."**

Go não tem linter que force "boas práticas". Você pode escrever código horroroso que compila perfeitamente. A diferença entre código que funciona e código que **evolui sem quebrar** está nas decisões pequenas: interfaces pequenas vs god interfaces, testes tabulares vs copy-paste, mocks vs banco real.

Este guia não é sobre pureza acadêmica. É sobre **decisões que economizam tempo** quando você volta ao código 6 meses depois ou quando um junior precisa adicionar uma feature.

## Por que boas práticas importam em Go?

1. **Interfaces pequenas = testabilidade** — Mock 2 métodos é trivial, mock 15 é inferno
2. **Accept interfaces, return structs** — Flexibilidade na entrada, clareza na saída
3. **Table-driven tests** — Adicionar caso de teste = 3 linhas, não 30
4. **Testify** — Assertions legíveis, erros claros
5. **Transações com defer** — Rollback automático, impossível esquecer
6. **Configuração YAML** — Staging/prod sem recompilar

Estas práticas custaram **bugs reais** para a comunidade Go aprender. Não reinvente a roda quebrando de novo.

---

## Interfaces Pequenas

**Regra:** Interfaces com 1-5 métodos (Interface Segregation Principle).

#### ✅ Recomendado
```go
// Interfaces pequenas e focadas
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

type Closer interface {
    Close() error
}

// Composição de interfaces
type ReadWriteCloser interface {
    Reader
    Writer
    Closer
}

// Domínio escolar - interfaces segregadas
type StudentFinder interface {
    FindByID(ctx context.Context, id string) (*Student, error)
    FindByEmail(ctx context.Context, email string) (*Student, error)
}

type StudentPersister interface {
    Save(ctx context.Context, student *Student) error
    Update(ctx context.Context, student *Student) error
    Delete(ctx context.Context, id string) error
}

// Interface composta quando necessário
type StudentRepository interface {
    StudentFinder
    StudentPersister
}
```

#### ❌ NÃO FAÇA
```go
// ❌ Interface gigante (god interface)
type StudentService interface {
    Create(ctx context.Context, student *Student) error
    Update(ctx context.Context, student *Student) error
    Delete(ctx context.Context, id string) error
    FindByID(ctx context.Context, id string) (*Student, error)
    FindByEmail(ctx context.Context, email string) (*Student, error)
    List(ctx context.Context, filter Filter) ([]*Student, error)
    Validate(student *Student) error
    SendEmail(ctx context.Context, studentId string) error
    GenerateReport(ctx context.Context, studentId string) ([]byte, error)
    Archive(ctx context.Context, studentId string) error
    Restore(ctx context.Context, studentId string) error
    Export(ctx context.Context, format string) ([]byte, error)
    // ... 15+ métodos
}
```

**Referência:**
- 📚 Robert C. Martin - Clean Architecture (Interface Segregation Principle)

---

## Aceitar Interfaces, Retornar Structs

**Regra:** Parâmetros devem ser interfaces, retornos devem ser structs concretos.

**Por que isso importa?**
- **Aceitar interfaces:** Seu código fica testável (pode passar mocks) e flexível (múltiplas implementações)
- **Retornar structs:** Quem chama sabe exatamente o que recebe, não precisa fazer type assertion

**Trade-off:** Se você retornar interface, está "escondendo" a implementação, mas dificulta para o consumidor saber quais campos/métodos existem. Go prefere explicitação.

**Exemplo mundo escolar:**
```go
// ❌ Retornar interface força consumidor a fazer type assertion
func NewService(repo StudentRepository) StudentService {
    return &studentServiceImpl{...}  // Quem chama não sabe métodos disponíveis
}

// ✅ Retornar struct concreta = API clara
func NewService(repo StudentRepository) *StudentService {
    return &StudentService{...}  // IDE autocompleta métodos
}
```

**Quando quebrar a regra:** Raramente, mas se você tem múltiplas implementações da mesma "coisa" e quer polimorfismo total, pode retornar interface. Exemplo: `io.Reader`, `http.Handler`.

**Referência:**
- 🔗 [Accept interfaces, return structs](https://bryanftan.medium.com/accept-interfaces-return-structs-in-go-d4cab29a301b)

#### ✅ Recomendado
```go
// ✅ Aceita interface, retorna struct
func NewStudentService(repo StudentRepository, validator StudentValidator) *StudentService {
    return &StudentService{
        repository: repo,
        validator:  validator,
    }
}

// ✅ Parâmetros interfaces, retorno struct
func ProcessEnrollment(
    ctx context.Context,
    finder StudentFinder,
    persister EnrollmentPersister,
    studentId string,
    courseId string,
) (*Enrollment, error) {
    student, err := finder.FindByID(ctx, studentId)
    if err != nil {
        return nil, fmt.Errorf("find student: %w", err)
    }

    enrollment := &Enrollment{
        Id:        generateID(),
        StudentId: studentId,
        CourseId:  courseId,
        Status:    StatusActive,
    }

    if err := persister.Save(ctx, enrollment); err != nil {
        return nil, fmt.Errorf("save enrollment: %w", err)
    }

    return enrollment, nil
}
```

#### ❌ NÃO FAÇA
```go
// ❌ Retorna interface (limita implementação)
func NewStudentService(repo StudentRepository) StudentService {
    return &studentServiceImpl{repository: repo}
}

// ❌ Parâmetros concretos (alto acoplamento)
func ProcessEnrollment(
    ctx context.Context,
    repo *PostgresStudentRepository,  // ❌ Concreto
    studentId string,
) (*Enrollment, error) {
    // ...
}
```

**Benefícios:**
- Facilita testes (mocks de interfaces)
- Reduz acoplamento
- Permite múltiplas implementações
- Structs concretos têm documentação clara de campos

---

## Testes Orientados a Tabela (Table-Driven Tests)

**Regra:** Usar subtests com tabelas para testar múltiplos cenários.

**O problema que resolve:**

Sem table-driven tests, você duplica código:

```go
// ❌ SEM TABLE-DRIVEN - Repetição massiva
func TestValidateStudent_ValidStudent(t *testing.T) {
    student := &Student{Name: "John", Email: "john@test.com"}
    err := ValidateStudent(student)
    if err != nil {
        t.Errorf("expected no error, got %v", err)
    }
}

func TestValidateStudent_MissingName(t *testing.T) {
    student := &Student{Email: "john@test.com"}
    err := ValidateStudent(student)
    if !errors.Is(err, ErrInvalidName) {
        t.Errorf("expected ErrInvalidName, got %v", err)
    }
}

func TestValidateStudent_InvalidEmail(t *testing.T) {
    student := &Student{Name: "John", Email: "invalid"}
    err := ValidateStudent(student)
    if !errors.Is(err, ErrInvalidEmail) {
        t.Errorf("expected ErrInvalidEmail, got %v", err)
    }
}

func TestValidateStudent_NilStudent(t *testing.T) {
    err := ValidateStudent(nil)
    if !errors.Is(err, ErrNilStudent) {
        t.Errorf("expected ErrNilStudent, got %v", err)
    }
}

// ❌ 4 funções, 40+ linhas, lógica duplicada
```

**Problemas:**
1. **Repetição:** Setup duplicado em cada função
2. **Manutenção:** Mudar assinatura = atualizar 10+ funções
3. **Adicionar caso:** Copiar/colar função inteira

**Solução com Table-Driven:**

```go
// ✅ COM TABLE-DRIVEN - Conciso e extensível
func TestValidateStudent(t *testing.T) {
    tests := []struct {
        name    string
        student *Student
        wantErr error
    }{
        {
            name:    "valid student",
            student: &Student{Name: "John", Email: "john@test.com"},
            wantErr: nil,
        },
        {
            name:    "missing name",
            student: &Student{Email: "john@test.com"},
            wantErr: ErrInvalidName,
        },
        {
            name:    "invalid email",
            student: &Student{Name: "John", Email: "invalid"},
            wantErr: ErrInvalidEmail,
        },
        {
            name:    "nil student",
            student: nil,
            wantErr: ErrNilStudent,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateStudent(tt.student)
            if !errors.Is(err, tt.wantErr) {
                t.Errorf("got %v, want %v", err, tt.wantErr)
            }
        })
    }
}

// ✅ 1 função, 20 linhas, adicionar caso = 4 linhas
```

**Benefícios:**

1. **Menos código:** 10 cenários = 10 linhas, não 10 funções
2. **Clareza:** Inputs e outputs esperados lado a lado
3. **Fácil adicionar casos:** Novo cenário = 4 linhas na tabela
4. **Subtests isolados:** `t.Run()` faz cada caso rodar independente
5. **Filtro por nome:** `go test -run TestValidate/missing_name`

**Por que usar table-driven tests?**

- ✅ **Reduz duplicação** — Setup compartilhado
- ✅ **Facilita manutenção** — Mudar lógica = um lugar
- ✅ **Melhora legibilidade** — Casos ficam visíveis em tabela
- ✅ **Acelera adição de casos** — Copy linha, ajusta valores

**Quando NÃO usar:**

- ❌ Teste com setup complexo diferente para cada caso (perde vantagem)
- ❌ Apenas 1 cenário (overkill)

**Referências:**
- 🔗 [Table Driven Tests](https://go.dev/wiki/TableDrivenTests) - Go Wiki oficial
- 🔗 [Advanced Testing](https://www.youtube.com/watch?v=8hQG7QlcLBk) - Mitchell Hashimoto

#### ✅ Recomendado
```go
func TestStudentValidation(t *testing.T) {
    tests := []struct {
        name    string
        student *Student
        wantErr error
    }{
        {
            name: "valid student",
            student: &Student{
                Id:    "student-1",
                Name:  "John Doe",
                Email: "john@example.com",
            },
            wantErr: nil,
        },
        {
            name: "missing name",
            student: &Student{
                Id:    "student-2",
                Email: "jane@example.com",
            },
            wantErr: ErrInvalidName,
        },
        {
            name: "invalid email",
            student: &Student{
                Id:    "student-3",
                Name:  "Bob Smith",
                Email: "invalid-email",
            },
            wantErr: ErrInvalidEmail,
        },
        {
            name:    "nil student",
            student: nil,
            wantErr: ErrNilStudent,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateStudent(tt.student)

            if !errors.Is(err, tt.wantErr) {
                t.Errorf("ValidateStudent() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}

// Table-driven test com múltiplas verificações
func TestCalculateGPA(t *testing.T) {
    tests := []struct {
        name   string
        grades []float64
        want   float64
    }{
        {
            name:   "perfect grades",
            grades: []float64{10.0, 10.0, 10.0},
            want:   10.0,
        },
        {
            name:   "mixed grades",
            grades: []float64{7.0, 8.5, 9.0},
            want:   8.17,
        },
        {
            name:   "single grade",
            grades: []float64{8.5},
            want:   8.5,
        },
        {
            name:   "empty grades",
            grades: []float64{},
            want:   0.0,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := CalculateGPA(tt.grades)

            if math.Abs(got-tt.want) > 0.01 {
                t.Errorf("CalculateGPA() = %.2f, want %.2f", got, tt.want)
            }
        })
    }
}
```

**Referência:**
- 🔗 [Table Driven Tests](https://go.dev/wiki/TableDrivenTests) - Go Wiki oficial

---

## Testify para Assertions

**Regra:** Usar `testify/require` para assertions críticas, `testify/assert` para verificações não-críticas.

#### ✅ Recomendado
```go
import (
    "testing"

    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestStudentService_CreateStudent(t *testing.T) {
    // Setup
    repo := &MockStudentRepository{}
    service := NewStudentService(repo)

    ctx := context.Background()
    name := "John Doe"
    email := "john@example.com"

    // Expectativas do mock
    repo.On("Save", mock.Anything, mock.Anything).Return(nil)

    // Execução
    student, err := service.CreateStudent(ctx, name, email)

    // Assertions críticas (require para quando falha)
    require.NoError(t, err, "CreateStudent should not return error")
    require.NotNil(t, student, "Student should not be nil")

    // Assertions não-críticas (assert continua testando)
    assert.Equal(t, name, student.Name, "Name should match")
    assert.Equal(t, email, student.Email, "Email should match")
    assert.NotEmpty(t, student.Id, "Id should be generated")
    assert.False(t, student.CreatedAt.IsZero(), "CreatedAt should be set")

    // Verificar mock foi chamado
    repo.AssertExpectations(t)
}

func TestStudentRepository_FindByID(t *testing.T) {
    // Setup
    repo := setupTestRepository(t)
    ctx := context.Background()

    // Criar estudante de teste
    student := &Student{
        Id:    "student-1",
        Name:  "Jane Doe",
        Email: "jane@example.com",
    }

    err := repo.Save(ctx, student)
    require.NoError(t, err, "Setup: save student should succeed")

    // Test: Encontrar estudante existente
    found, err := repo.FindByID(ctx, student.Id)
    require.NoError(t, err)
    require.NotNil(t, found)

    assert.Equal(t, student.Id, found.Id)
    assert.Equal(t, student.Name, found.Name)
    assert.Equal(t, student.Email, found.Email)

    // Test: Estudante não existe
    notFound, err := repo.FindByID(ctx, "non-existent")
    require.Error(t, err)
    assert.Nil(t, notFound)
    assert.True(t, errors.Is(err, ErrStudentNotFound))
}
```

**Diferença require vs assert:**
- `require`: Para quando falha (teste crítico)
- `assert`: Continua executando (permite múltiplas falhas)

**Referência:**
- 🔗 [Testify](https://github.com/stretchr/testify) - Documentação oficial

---

## Mocks com Testify

**Regra:** Usar `testify/mock` para criar mocks de interfaces.

#### ✅ Recomendado
```go
// mock_student_repository.go
package student

import (
    "context"

    "github.com/stretchr/testify/mock"
)

type MockStudentRepository struct {
    mock.Mock
}

func (m *MockStudentRepository) FindByID(ctx context.Context, id string) (*Student, error) {
    args := m.Called(ctx, id)

    if args.Get(0) == nil {
        return nil, args.Error(1)
    }

    return args.Get(0).(*Student), args.Error(1)
}

func (m *MockStudentRepository) Save(ctx context.Context, student *Student) error {
    args := m.Called(ctx, student)
    return args.Error(0)
}

func (m *MockStudentRepository) Update(ctx context.Context, student *Student) error {
    args := m.Called(ctx, student)
    return args.Error(0)
}

func (m *MockStudentRepository) Delete(ctx context.Context, id string) error {
    args := m.Called(ctx, id)
    return args.Error(0)
}

// Uso nos testes
func TestStudentService_UpdateEmail(t *testing.T) {
    // Setup
    mockRepo := &MockStudentRepository{}
    service := NewStudentService(mockRepo)

    ctx := context.Background()
    studentId := "student-1"
    newEmail := "newemail@example.com"

    existingStudent := &Student{
        Id:    studentId,
        Name:  "John Doe",
        Email: "old@example.com",
    }

    // Mock expectations
    mockRepo.On("FindByID", ctx, studentId).Return(existingStudent, nil)
    mockRepo.On("Update", ctx, mock.MatchedBy(func(s *Student) bool {
        return s.Email == newEmail
    })).Return(nil)

    // Execução
    err := service.UpdateEmail(ctx, studentId, newEmail)

    // Verificações
    require.NoError(t, err)
    mockRepo.AssertExpectations(t)

    // Verificar chamadas específicas
    mockRepo.AssertCalled(t, "FindByID", ctx, studentId)
    mockRepo.AssertCalled(t, "Update", ctx, mock.Anything)
}

// Mock com retorno de erro
func TestStudentService_UpdateEmail_NotFound(t *testing.T) {
    mockRepo := &MockStudentRepository{}
    service := NewStudentService(mockRepo)

    ctx := context.Background()
    studentId := "non-existent"

    // Mock retorna erro
    mockRepo.On("FindByID", ctx, studentId).Return(nil, ErrStudentNotFound)

    err := service.UpdateEmail(ctx, studentId, "new@example.com")

    require.Error(t, err)
    assert.True(t, errors.Is(err, ErrStudentNotFound))
    mockRepo.AssertExpectations(t)
}
```

**Referência:**
- 🔗 [Testify Mock](https://pkg.go.dev/github.com/stretchr/testify/mock) - Documentação

---

## Transações com Defer

**Regra:** Sempre usar `defer` para rollback de transações.

**O problema que resolve:**

Sem defer, você esquece rollback em paths de erro:

```go
// ❌ SEM DEFER - Vazamento de transação
func (s *Service) CreateEnrollment(ctx context.Context, data Data) error {
    tx, _ := s.db.Begin(ctx)

    if err := s.repo.Save(ctx, tx, data); err != nil {
        tx.Rollback(ctx)  // ✅ Lembrou aqui
        return err
    }

    if err := s.validate(data); err != nil {
        return err  // ❌ ESQUECEU rollback! Transação vazada
    }

    if err := s.publish(data); err != nil {
        tx.Rollback(ctx)  // ✅ Lembrou aqui
        return err
    }

    return tx.Commit(ctx)
}
```

**Problema:** Cada `return` precisa lembrar de chamar `Rollback()`. Esqueça uma vez = transação travada no banco.

**Solução com Defer:**

```go
// ✅ COM DEFER - Rollback garantido
func (s *Service) CreateEnrollment(ctx context.Context, data Data) (err error) {
    tx, err := s.db.Begin(ctx)
    if err != nil {
        return fmt.Errorf("begin tx: %w", err)
    }

    // Defer executa SEMPRE ao sair da função
    defer func() {
        if err != nil {
            tx.Rollback(ctx)  // ✅ Rollback automático em qualquer erro
        }
    }()

    if err = s.repo.Save(ctx, tx, data); err != nil {
        return fmt.Errorf("save: %w", err)  // ✅ defer chama Rollback
    }

    if err = s.validate(data); err != nil {
        return fmt.Errorf("validate: %w", err)  // ✅ defer chama Rollback
    }

    if err = s.publish(data); err != nil {
        return fmt.Errorf("publish: %w", err)  // ✅ defer chama Rollback
    }

    return tx.Commit(ctx)  // ✅ Sucesso, commit explícito
}
```

**Por que isso funciona:**

1. `defer` executa na ordem LIFO ao sair da função
2. Closure captura variável `err` (named return)
3. Se `err != nil`, defer chama `Rollback()`
4. Se sucesso, `Commit()` é chamado, defer vê `err == nil` e não faz nada

**Benefícios:**

- ✅ **Impossível esquecer rollback** — Automático em qualquer path de erro
- ✅ **Código limpo** — Não precisa `tx.Rollback()` em cada `if err != nil`
- ✅ **Seguro** — Mesmo em panic, defer executa

**Referências:**
- 🔗 [Database Transactions](https://go.dev/doc/database/execute-transactions) - Go Database/SQL tutorial

#### ✅ Recomendado
```go
func (s *EnrollmentService) CreateEnrollmentWithPayment(
    ctx context.Context,
    studentId string,
    courseId string,
    amount float64,
) (*Enrollment, error) {
    // Iniciar transação
    tx, err := s.db.Begin(ctx)
    if err != nil {
        return nil, fmt.Errorf("begin transaction: %w", err)
    }

    // Garantir rollback em caso de erro
    defer func() {
        if err != nil {
            tx.Rollback(ctx)
        }
    }()

    // Criar matrícula
    enrollment := &Enrollment{
        Id:        generateID(),
        StudentId: studentId,
        CourseId:  courseId,
        Status:    StatusActive,
    }

    if err = s.enrollmentRepo.SaveTx(ctx, tx, enrollment); err != nil {
        return nil, fmt.Errorf("save enrollment: %w", err)
    }

    // Criar pagamento
    payment := &Payment{
        Id:           generateID(),
        EnrollmentId: enrollment.Id,
        Amount:       amount,
        Status:       PaymentStatusPending,
    }

    if err = s.paymentRepo.SaveTx(ctx, tx, payment); err != nil {
        return nil, fmt.Errorf("save payment: %w", err)
    }

    // Commit (sem erro atribui nil, defer não faz rollback)
    if err = tx.Commit(ctx); err != nil {
        return nil, fmt.Errorf("commit transaction: %w", err)
    }

    return enrollment, nil
}

// Pattern alternativo com helper
type TxFunc func(ctx context.Context, tx Transaction) error

func (s *EnrollmentService) WithTransaction(ctx context.Context, fn TxFunc) error {
    tx, err := s.db.Begin(ctx)
    if err != nil {
        return fmt.Errorf("begin transaction: %w", err)
    }

    defer func() {
        if p := recover(); p != nil {
            tx.Rollback(ctx)
            panic(p)
        } else if err != nil {
            tx.Rollback(ctx)
        }
    }()

    err = fn(ctx, tx)
    if err != nil {
        return err
    }

    return tx.Commit(ctx)
}

// Uso do helper
func (s *EnrollmentService) CreateEnrollment(
    ctx context.Context,
    studentId string,
    courseId string,
) (*Enrollment, error) {
    var enrollment *Enrollment

    err := s.WithTransaction(ctx, func(ctx context.Context, tx Transaction) error {
        enrollment = &Enrollment{
            Id:        generateID(),
            StudentId: studentId,
            CourseId:  courseId,
        }

        if err := s.enrollmentRepo.SaveTx(ctx, tx, enrollment); err != nil {
            return fmt.Errorf("save enrollment: %w", err)
        }

        return nil
    })

    if err != nil {
        return nil, err
    }

    return enrollment, nil
}
```

---

## Configuração com YAML

**Regra:** Arquivos de configuração devem usar extensão `.yaml` (não `.yml`, `.json`, `.toml`).

#### ✅ Recomendado
```yaml
# config.yaml
server:
  port: 8080
  host: 0.0.0.0
  timeout: 30s

database:
  host: localhost
  port: 5432
  name: school_db
  user: postgres
  password: secret
  max_connections: 25

redis:
  host: localhost
  port: 6379
  password: ""
  db: 0

log:
  level: info
  format: json
  output: stdout
```

```go
// internal/infra/config/config.go
package config

import (
    "fmt"
    "os"
    "time"

    "gopkg.in/yaml.v3"
)

type Config struct {
    Server   ServerConfig   `yaml:"server"`
    Database DatabaseConfig `yaml:"database"`
    Redis    RedisConfig    `yaml:"redis"`
    Log      LogConfig      `yaml:"log"`
}

type ServerConfig struct {
    Port    int           `yaml:"port"`
    Host    string        `yaml:"host"`
    Timeout time.Duration `yaml:"timeout"`
}

type DatabaseConfig struct {
    Host           string `yaml:"host"`
    Port           int    `yaml:"port"`
    Name           string `yaml:"name"`
    User           string `yaml:"user"`
    Password       string `yaml:"password"`
    MaxConnections int    `yaml:"max_connections"`
}

type RedisConfig struct {
    Host     string `yaml:"host"`
    Port     int    `yaml:"port"`
    Password string `yaml:"password"`
    DB       int    `yaml:"db"`
}

type LogConfig struct {
    Level  string `yaml:"level"`
    Format string `yaml:"format"`
    Output string `yaml:"output"`
}

func Load(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("read config file: %w", err)
    }

    var config Config
    if err := yaml.Unmarshal(data, &config); err != nil {
        return nil, fmt.Errorf("parse config: %w", err)
    }

    // Valores default
    if config.Server.Port == 0 {
        config.Server.Port = 8080
    }

    if config.Server.Timeout == 0 {
        config.Server.Timeout = 30 * time.Second
    }

    return &config, nil
}

// Uso
func main() {
    config, err := config.Load("config.yaml")
    if err != nil {
        log.Fatal(err)
    }

    // ...
}
```

**Referência:**
- 🔗 [gopkg.in/yaml.v3](https://pkg.go.dev/gopkg.in/yaml.v3) - YAML para Go

---



---

**Próximo:** [Dependências e Módulos](06-dependencias.md) | **Anterior:** [Padrões de Design](04-padroes-design.md) | **Voltar para:** [Índice](README.md)

**Última atualização:** 03/11/2025 16:42
