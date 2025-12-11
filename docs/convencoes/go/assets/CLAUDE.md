# Diretrizes para Agentes de IA - Código Go Backend

> **Propósito:** Regras técnicas executáveis para geração, revisão e refatoração de código Go backend.

Este documento consolida padrões extraídos de documentação técnica consolidada (3000+ linhas). Não são opiniões pessoais — são convenções da comunidade Go e práticas de projetos reais de médio/grande porte.

**Aplicável a:** Claude, GPT-4, Copilot, Cursor, ou qualquer agente trabalhando com código Go backend.

---

## 1. Nomenclatura: Regras Absolutas

### Consistência de Idioma
**Regra:** 100% inglês OU 100% português. NUNCA misture.

```go
// ❌ RECUSAR - Idioma misto
type Student struct {
    Nome  string  // português
    Email string  // inglês
}
func obterStudent(id string) Student  // misto

// ✅ ACEITAR - Consistente
type Student struct {
    Name  string
    Email string
}
func GetStudent(ctx context.Context, id string) (*Student, error)
```

### Packages
**Regras:**
- Singular, lowercase, sem underscore
- `student` não `students`, `Students`, `student_service`

```go
// ❌ RECUSAR
package Students
package student_service
package studentPkg

// ✅ ACEITAR
package student
package enrollment
package notification
```

### Structs e Interfaces
**Structs:** PascalCase (exportado) ou camelCase (privado)
**Interfaces:** Sufixo `-er`/`-or` quando possível, 1-5 métodos máximo

```go
// ✅ ACEITAR
type Student struct { ... }           // struct exportado
type privateConfig struct { ... }     // struct privado

type Repository interface { ... }     // interface
type Notifier interface { ... }       // sufixo -er
type Validator interface { ... }      // sufixo -or
```

### Campo ID vs Método ID
**Problema:** Campo `ID` conflita com método de interface `ID()`.

```go
// ❌ RECUSAR - Conflito
type Student struct {
    ID string  // campo ID
}
func (s *Student) ID() string { return s.ID }  // ERRO: conflito

// ✅ ACEITAR - Sem conflito
type Student struct {
    Id string  // campo Id (lowercase d)
}
func (s *Student) ID() string { return s.Id }  // OK
```

### Funções e Construtores
**Regras:**
- Funções começam com verbo: `GetStudent`, `CreateEnrollment`, `UpdateEmail`
- Construtores com prefixo `New*`: `NewStudent`, `NewService`, `NewRepository`

```go
// ❌ RECUSAR
func Student(name string) *Student           // sem verbo
func StudentByID(id string) *Student         // sem verbo
func MakeStudent(name string) *Student       // não usar Make

// ✅ ACEITAR
func NewStudent(name string) (*Student, error)
func GetStudent(ctx context.Context, id string) (*Student, error)
func CreateStudent(ctx context.Context, student *Student) error
```

### Variáveis e Constantes
**Variáveis:** camelCase, descritivas (evite abreviações desnecessárias)
**Constantes:** PascalCase (não UPPER_SNAKE_CASE em Go)
**Booleanos:** Prefixos is/has/can/should (inglês) ou esta/tem/pode/deve (português)

```go
// ❌ RECUSAR
const MAX_RETRY_COUNT = 3      // UPPER_SNAKE_CASE
var usr string                 // abreviação desnecessária
var active bool                // sem prefixo

// ✅ ACEITAR
const MaxRetries = 3
const DefaultTimeout = 30 * time.Second
var userName string
var isActive bool
var hasPermission bool
```

### Receptores, Context, Errors
**Receptores:** 1 letra minúscula consistente (`s`, `r`, `repo`, `svc`)
**Context:** Nome completo `ctx` (inglês) ou `contexto` (português)
**Errors:** Nome completo `err` (inglês) ou `erro` (português)
**Mutexes:** Nome completo `mutex` (não `mu`)

```go
// ✅ ACEITAR
func (s *Student) Enroll(ctx context.Context) error
func (r *Repository) Save(ctx context.Context, s *Student) error
func (svc *Service) Process(ctx context.Context) error
```

### Erros Sentinela
**Formato:** Prefixo `Err*` (inglês) ou `Erro*` (português)

```go
// ✅ ACEITAR
var (
    ErrStudentNotFound = errors.New("student not found")
    ErrInvalidEmail    = errors.New("invalid email")
    ErrDuplicateEntry  = errors.New("duplicate entry")
)
```

---

## 2. Context e Error Handling: Não Negociável

### Context Propagation
**Regras absolutas:**
1. Context SEMPRE primeiro parâmetro
2. Context NUNCA armazenado em struct
3. Context propagado em TODA operação I/O (DB, HTTP, cache)

```go
// ❌ RECUSAR - Context em struct
type Service struct {
    ctx context.Context  // NUNCA fazer isso
}

// ❌ RECUSAR - Context não primeiro parâmetro
func (s *Service) Create(name string, ctx context.Context) error

// ❌ RECUSAR - Sem context em operação I/O
func (r *Repository) Save(student *Student) error

// ✅ ACEITAR - Context correto
func (s *Service) Create(ctx context.Context, name string) (*Student, error) {
    return s.repo.Save(ctx, student)
}

func (r *Repository) Save(ctx context.Context, s *Student) error {
    _, err := r.pool.Exec(ctx, query, s.Id, s.Name)
    return err
}
```

**Por quê:** Context carrega cancelamento, timeouts e valores de requisição. Armazenar em struct mistura contextos de múltiplas requisições (bug grave em concorrência).

### Error Wrapping
**Regra:** SEMPRE encapsular erros com contexto usando `fmt.Errorf` com `%w`.

```go
// ❌ RECUSAR - Erro sem contexto
func (s *Service) Process(ctx context.Context, id string) error {
    err := s.repo.FindByID(ctx, id)
    if err != nil {
        return err  // perde contexto de ONDE falhou
    }
}

// ✅ ACEITAR - Erro com contexto
func (s *Service) Process(ctx context.Context, id string) error {
    student, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return fmt.Errorf("processar matricula do student %s: %w", id, err)
    }
    // ...
}
```

**Por quê:** Go não tem stack traces automáticos. Wrapping cria cadeia de contexto rastreável.

### Error Checking
**Regra:** NUNCA ignore erros silenciosamente. Use `errors.Is()` e `errors.As()` para verificação.

```go
// ❌ RECUSAR - Erro ignorado
s.repo.Save(ctx, student)  // ignora retorno

// ✅ ACEITAR - Erro verificado
if err := s.repo.Save(ctx, student); err != nil {
    if errors.Is(err, ErrDuplicateEntry) {
        return fmt.Errorf("student já existe: %w", err)
    }
    return fmt.Errorf("salvar student: %w", err)
}
```

---

## 3. Arquitetura: Clean Architecture Tática

### Estrutura de Camadas
**Obrigatório:**

```
internal/
├── domain/           # Core business logic, ZERO deps externas
│   └── student/
│       ├── student.go        # Entidade
│       ├── repository.go     # Interface
│       └── service.go        # Lógica de domínio
├── app/              # Orquestração, casos de uso
│   └── enrollment/
│       └── processor.go      # Coordena múltiplos domínios
├── infra/            # Implementações (DB, cache, HTTP)
│   ├── postgres/
│   │   └── student_repository.go
│   └── cache/
│       └── redis_client.go
└── api/              # Controllers/Handlers HTTP
    └── controllers/
        └── student_controller.go
```

### Fluxo de Dependências
**Regra:** API → App → Domain ← Infra

```
┌─────────┐
│   API   │  (controllers, handlers)
└────┬────┘
     │
┌────▼────┐
│   App   │  (casos de uso, orquestração)
└────┬────┘
     │
┌────▼────┐
│ Domain  │  (entities, interfaces, business rules)
└────▲────┘
     │
┌────┴────┐
│  Infra  │  (implementações: DB, cache, HTTP clients)
└─────────┘
```

**Domain define interfaces, Infra implementa:**

```go
// ✅ ACEITAR - Interface no domain
// internal/domain/student/repository.go
package student

type Repository interface {
    Save(ctx context.Context, s *Student) error
    FindByID(ctx context.Context, id string) (*Student, error)
}

// ✅ ACEITAR - Implementação na infra
// internal/infra/postgres/student_repository.go
package postgres

import "github.com/company/project/internal/domain/student"

type StudentRepository struct {
    pool *pgxpool.Pool
}

func NewStudentRepository(pool *pgxpool.Pool) student.Repository {
    return &StudentRepository{pool: pool}
}

func (r *StudentRepository) Save(ctx context.Context, s *student.Student) error {
    // Implementação PostgreSQL
}
```

### Repository Pattern
**Quando usar:**
- ✅ Múltiplas fontes de dados (PostgreSQL + Redis + S3)
- ✅ Testes rápidos necessários (mock repository)
- ✅ Times grandes (domain e infra evoluem independentes)

**Quando NÃO usar:**
- ❌ CRUD simples com 1 desenvolvedor
- ❌ Protótipos descartáveis
- ❌ Scripts de migração/admin

**Pattern obrigatório se usar:**

```go
// Domain define O QUE precisa
type Repository interface {
    Save(ctx context.Context, s *Student) error
    FindByID(ctx context.Context, id string) (*Student, error)
    Update(ctx context.Context, s *Student) error
    Delete(ctx context.Context, id string) error
}

// Infra implementa COMO
type PostgresRepository struct { ... }
type MongoRepository struct { ... }
type InMemoryRepository struct { ... }  // para testes
```

---

## 4. Dependency Injection: Padrão Fx

### Module Pattern
**Regra:** Todo domínio expõe `var Module = fx.Module(...)`.

```go
// ✅ ACEITAR - Module no domain
// internal/domain/student/module.go
package student

import "go.uber.org/fx"

var Module = fx.Module("student",
    fx.Provide(NewService),
)

func NewService(repo Repository) *Service {
    return &Service{repo: repo}
}

// ✅ ACEITAR - Module na infra
// internal/infra/postgres/module.go
package postgres

import (
    "go.uber.org/fx"
    "github.com/company/project/internal/domain/student"
)

var Module = fx.Module("postgres",
    fx.Provide(
        NewPool,  // *pgxpool.Pool
        fx.Annotate(
            NewStudentRepository,
            fx.As(new(student.Repository)),  // bind interface
        ),
    ),
)

// ✅ ACEITAR - Composição no main
// cmd/api/main.go
package main

import (
    "go.uber.org/fx"
    "github.com/company/project/internal/domain/student"
    "github.com/company/project/internal/infra/postgres"
)

func main() {
    fx.New(
        postgres.Module,
        student.Module,
        fx.Invoke(runServer),
    ).Run()
}
```

**Não inventar:** Usar Fx como documentado. Não criar sistema de DI customizado sem justificativa forte.

---

## 5. Testes: Table-Driven Obrigatório

### Pattern Table-Driven
**Regra:** SEMPRE use table-driven tests para múltiplos cenários.

```go
// ✅ ACEITAR - Table-driven test
func TestCreateStudent(t *testing.T) {
    tests := []struct {
        name      string
        input     string
        wantErr   bool
        errType   error
    }{
        {
            name:    "válido",
            input:   "João Silva",
            wantErr: false,
        },
        {
            name:    "nome vazio",
            input:   "",
            wantErr: true,
            errType: ErrInvalidName,
        },
        {
            name:    "nome muito longo",
            input:   strings.Repeat("a", 256),
            wantErr: true,
            errType: ErrNameTooLong,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result, err := NewStudent(tt.input)
            
            if tt.wantErr {
                require.Error(t, err)
                require.True(t, errors.Is(err, tt.errType))
                return
            }
            
            require.NoError(t, err)
            assert.Equal(t, tt.input, result.Name)
        })
    }
}
```

### Testify para Assertions e Mocks
**Regra:** Use `testify/require` para assertions críticas, `testify/assert` para não-críticas.

```go
import (
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
    "github.com/stretchr/testify/mock"
)

// ✅ ACEITAR - require para crítico (para o teste)
require.NoError(t, err)
require.NotNil(t, result)

// ✅ ACEITAR - assert para não-crítico (continua o teste)
assert.Equal(t, expected, result)
assert.True(t, result.IsActive)
```

### Mocks com Testify
**Pattern obrigatório:**

```go
// ✅ ACEITAR - Mock definition
type MockRepository struct {
    mock.Mock
}

func (m *MockRepository) Save(ctx context.Context, s *student.Student) error {
    args := m.Called(ctx, s)
    return args.Error(0)
}

func (m *MockRepository) FindByID(ctx context.Context, id string) (*student.Student, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*student.Student), args.Error(1)
}

// ✅ ACEITAR - Mock usage
func TestService_CreateStudent(t *testing.T) {
    mockRepo := new(MockRepository)
    service := student.NewService(mockRepo)

    mockRepo.On("Save", mock.Anything, mock.MatchedBy(func(s *student.Student) bool {
        return s.Name == "João Silva"
    })).Return(nil)

    err := service.CreateStudent(context.Background(), "João Silva")
    require.NoError(t, err)
    
    mockRepo.AssertExpectations(t)  // Verifica que Save foi chamado
}
```

---

## 6. Código Idiomático: Padrões Obrigatórios

### Early Return
**Regra:** Preferir early return ao invés de else desnecessário.

```go
// ❌ RECUSAR - Else desnecessário
func Validate(email string) error {
    if email != "" {
        if strings.Contains(email, "@") {
            return nil
        } else {
            return ErrInvalidEmail
        }
    } else {
        return ErrEmptyEmail
    }
}

// ✅ ACEITAR - Early return
func Validate(email string) error {
    if email == "" {
        return ErrEmptyEmail
    }
    if !strings.Contains(email, "@") {
        return ErrInvalidEmail
    }
    return nil
}
```

### Nil Slices
**Regra:** Preferir nil slices ao invés de slices vazios inicializados.

```go
// ❌ EVITAR - Slice vazio inicializado
students := []*Student{}
students := make([]*Student, 0)

// ✅ ACEITAR - Nil slice
var students []*Student

// len() e range funcionam com nil
if len(students) == 0 { ... }  // OK
for _, s := range students { ... }  // OK
```

### Defer para Cleanup
**Regra:** SEMPRE usar defer para cleanup (Close, Unlock, Rollback).

```go
// ❌ RECUSAR - Sem defer (leak se houver erro)
func Process(ctx context.Context) error {
    file, err := os.Open("data.txt")
    if err != nil {
        return err
    }
    // Se erro abaixo, file não fecha (leak)
    data, err := io.ReadAll(file)
    file.Close()
    return processData(data)
}

// ✅ ACEITAR - Defer garante cleanup
func Process(ctx context.Context) error {
    file, err := os.Open("data.txt")
    if err != nil {
        return err
    }
    defer file.Close()  // Sempre fecha, mesmo com panic
    
    data, err := io.ReadAll(file)
    if err != nil {
        return fmt.Errorf("ler arquivo: %w", err)
    }
    return processData(data)
}
```

### Transações com Defer
**Pattern obrigatório:**

```go
// ✅ ACEITAR - Transação com defer
func (s *Service) CreateWithDependencies(ctx context.Context, student *Student) (err error) {
    tx, err := s.db.Begin(ctx)
    if err != nil {
        return fmt.Errorf("iniciar transação: %w", err)
    }
    
    defer func() {
        if err != nil {
            tx.Rollback(ctx)
        }
    }()
    
    if err = s.repo.SaveTx(ctx, tx, student); err != nil {
        return fmt.Errorf("salvar student: %w", err)
    }
    
    if err = s.enrollmentRepo.CreateTx(ctx, tx, enrollment); err != nil {
        return fmt.Errorf("criar enrollment: %w", err)
    }
    
    if err = tx.Commit(ctx); err != nil {
        return fmt.Errorf("commit transação: %w", err)
    }
    
    return nil
}
```

### Interfaces Pequenas
**Regra:** Interfaces devem ter 1-5 métodos. Mais que isso é "god interface".

```go
// ❌ RECUSAR - God interface
type StudentRepository interface {
    Save(ctx context.Context, s *Student) error
    FindByID(ctx context.Context, id string) (*Student, error)
    FindByEmail(ctx context.Context, email string) (*Student, error)
    Update(ctx context.Context, s *Student) error
    Delete(ctx context.Context, id string) error
    List(ctx context.Context, filter Filter) ([]*Student, error)
    Count(ctx context.Context, filter Filter) (int, error)
    BulkInsert(ctx context.Context, students []*Student) error
    BulkUpdate(ctx context.Context, students []*Student) error
    // ... mais 10 métodos
}

// ✅ ACEITAR - Interface segregada
type StudentWriter interface {
    Save(ctx context.Context, s *Student) error
    Update(ctx context.Context, s *Student) error
    Delete(ctx context.Context, id string) error
}

type StudentReader interface {
    FindByID(ctx context.Context, id string) (*Student, error)
    FindByEmail(ctx context.Context, email string) (*Student, error)
    List(ctx context.Context, filter Filter) ([]*Student, error)
}

type StudentRepository interface {
    StudentWriter
    StudentReader
}
```

### Accept Interfaces, Return Structs
**Regra:** Parâmetros aceitam interfaces, retornos são structs concretos.

```go
// ❌ RECUSAR - Retorna interface
func NewService(repo Repository) Service {  // retorna interface
    return &service{repo: repo}
}

// ❌ RECUSAR - Parâmetro concreto
func ProcessStudent(repo *PostgresRepository) error {  // concreto
    // Alto acoplamento com PostgreSQL
}

// ✅ ACEITAR - Interface entrada, struct saída
func NewService(repo Repository) *Service {  // retorna struct
    return &Service{repo: repo}
}

func ProcessStudent(repo Repository) error {  // interface
    // Funciona com qualquer implementação
}
```

---

## 7. Geração de Código: Princípios de Execução

### Antes de Gerar Código
**Checklist obrigatório:**
1. ❓ Entendi completamente o requisito?
2. ❓ Qual o contexto arquitetural do projeto?
3. ❓ Precisa de Repository ou é CRUD simples?
4. ❓ Qual idioma (inglês/português) está sendo usado?
5. ❓ Há padrões existentes no código que devo seguir?

**NUNCA gere código sem responder essas perguntas.**

### Template de Código Gerado
**Estrutura obrigatória:**

```go
// ✅ ACEITAR - Código com contexto
// Package student implementa lógica de domínio para entidade Student.
// 
// Padrão: Repository pattern com interface no domain, implementação em infra.
package student

import (
    "context"
    "fmt"
    "time"
)

// Student representa um aluno matriculado no sistema.
// Regras de negócio:
// - Nome é obrigatório e deve ter entre 3-100 caracteres
// - Email é obrigatório e deve ser válido
type Student struct {
    Id        string
    Name      string
    Email     string
    BirthDate time.Time
    CreatedAt time.Time
}

// NewStudent cria um novo student com validações.
// Retorna erro se:
// - name vazio ou < 3 caracteres
// - email inválido (sem @)
func NewStudent(name, email string, birthDate time.Time) (*Student, error) {
    if len(name) < 3 {
        return nil, fmt.Errorf("nome deve ter no mínimo 3 caracteres")
    }
    // validações...
    return &Student{
        Id:        generateID(),
        Name:      name,
        Email:     email,
        BirthDate: birthDate,
        CreatedAt: time.Now(),
    }, nil
}
```

### O Que NÃO Fazer
**Proibido:**
- ❌ Gerar código sem comentários explicativos
- ❌ Propor CQRS/Event Sourcing sem justificativa (overkill)
- ❌ Criar abstrações prematuras (YAGNI - You Aren't Gonna Need It)
- ❌ Usar exemplos "Foo/Bar" genéricos (use domínio real)
- ❌ Ignorar trade-offs de decisões arquiteturais

### Priorização de Simplicidade
**Regra:** Comece simples, adicione complexidade apenas quando justificado.

```
CRUD simples → Repository → Service Layer → CQRS → Event Sourcing
    ↑                                                      ↑
  Comece aqui                               Só se REALMENTE necessário
```

---

## 8. Revisão de Código: Checklist Executável

### Verificações Automáticas
**Rodar ANTES de aprovar código:**

```bash
# Formatação
gofmt -w .
goimports -w .

# Linting
golangci-lint run

# Testes
go test ./... -v -race -cover

# Segurança
govulncheck ./...
```

### Checklist Manual
**Verificar em ordem:**

#### Nomenclatura
- [ ] Idioma 100% consistente?
- [ ] Packages singular, lowercase, sem underscore?
- [ ] Construtores com `New*`?
- [ ] Campo `Id` (não `ID`) se há método `ID()`?
- [ ] Interfaces com 1-5 métodos?

#### Context e Errors
- [ ] Context primeiro parâmetro em todas operações I/O?
- [ ] Context NUNCA em struct field?
- [ ] Errors wrapped com `fmt.Errorf("contexto: %w", err)`?
- [ ] Errors verificados (não ignorados)?

#### Arquitetura
- [ ] Repository interface no domain, implementação na infra?
- [ ] Fluxo de dependências correto (API→App→Domain←Infra)?
- [ ] Fx modules expostos corretamente?

#### Testes
- [ ] Table-driven tests para múltiplos cenários?
- [ ] Testify usado para assertions e mocks?
- [ ] Mocks verificados com `AssertExpectations`?
- [ ] Coverage aceitável (definir: ex. >70%)?

#### Código Idiomático
- [ ] Early return ao invés de else desnecessário?
- [ ] Defer usado para cleanup (Close, Rollback, Unlock)?
- [ ] Nil slices ao invés de slices vazios?
- [ ] Interfaces pequenas (<5 métodos)?

### Anti-Patterns para Alertar
**Detectar e recusar:**

```go
// ❌ ALERTAR - Context em struct
type Service struct {
    ctx context.Context
}

// ❌ ALERTAR - God interface
type Repository interface {
    // 15+ métodos
}

// ❌ ALERTAR - Erro sem wrapping
return err

// ❌ ALERTAR - Idioma misto
type Student struct {
    Nome string
    Email string
}

// ❌ ALERTAR - Package com underscore
package student_service

// ❌ ALERTAR - Constante em UPPER_SNAKE_CASE
const MAX_RETRIES = 3
```

---

## 9. Comunicação de Output: Formato Obrigatório

### Estrutura de Resposta
**Template a seguir:**

```markdown
## 🔍 Análise
[Descrição do problema/requisito identificado]

## ✅ Solução Recomendada
[Código implementado com comentários inline]

## 🤔 Trade-offs
**Decisão X vs Y:**
- ✅ Vantagens da decisão tomada
- ❌ Desvantagens/limitações
- ⚠️ Quando considerar alternativa

## 💡 Alternativas Consideradas
[Outras abordagens possíveis e por que não foram escolhidas]
```

### Categorização Visual
**Usar sempre:**
- ✅ O que fazer / código correto
- ❌ O que NÃO fazer / código incorreto / anti-pattern
- ⚠️ Avisos / casos especiais / atenção necessária
- 🤔 Trade-offs / decisões / considerações
- 💡 Alternativas / sugestões / melhorias

### Explicações Obrigatórias
**Sempre incluir:**
1. **Por quê** a decisão foi tomada
2. **Trade-offs** da abordagem
3. **Quando usar** vs **quando NÃO usar**
4. **Referências** (se aplicável)

### Exemplo de Boa Resposta

```markdown
## 🔍 Análise
O código atual não usa Repository Pattern. Domain está acoplado ao PostgreSQL.

## ✅ Solução Recomendada
```go
// internal/domain/student/repository.go
package student

type Repository interface {
    Save(ctx context.Context, s *Student) error
    FindByID(ctx context.Context, id string) (*Student, error)
}

// internal/infra/postgres/student_repository.go
package postgres

type StudentRepository struct {
    pool *pgxpool.Pool
}

func NewStudentRepository(pool *pgxpool.Pool) student.Repository {
    return &StudentRepository{pool: pool}
}
```

## 🤔 Trade-offs

**Repository Pattern:**
- ✅ **Vantagem:** Testes rápidos (mock repository), domain desacoplado
- ❌ **Desvantagem:** Mais arquivos, indireção adicional
- ⚠️ **Quando usar:** Projetos com múltiplas fontes de dados, necessidade de testes unitários rápidos
- ⚠️ **Quando NÃO usar:** CRUD trivial com 1 dev, protótipos

## 💡 Alternativas Consideradas

**Opção 1: GORM (ORM)**
- Menos boilerplate, mas "mágico" demais para Go idiomático
- Dificulta queries complexas

**Opção 2: Código direto no Service**
- Mais simples, mas acopla domain a PostgreSQL
- Testes precisam de banco real (lentos)

**Decisão:** Repository com pgx/v5 (driver nativo, performance, idiomático).
```

---

## 10. Referências Rápidas

### Bibliotecas Recomendadas
- **HTTP:** Gin (`github.com/gin-gonic/gin`)
- **DB PostgreSQL:** pgx/v5 (`github.com/jackc/pgx/v5`)
- **DI:** Uber Fx (`go.uber.org/fx`)
- **Testes:** Testify (`github.com/stretchr/testify`)
- **Validação:** ozzo-validation/v4 (`github.com/go-ozzo/ozzo-validation/v4`)
- **Logging:** Zap (`go.uber.org/zap`)
- **Migrations:** golang-migrate (`github.com/golang-migrate/migrate/v4`)
- **Cache/Redis:** go-redis/v9 (`github.com/redis/go-redis/v9`)

### Comandos de Verificação
```bash
# Formatação automática
gofmt -w .
goimports -w .

# Linting
golangci-lint run --enable-all

# Testes com race detection
go test ./... -v -race -cover

# Coverage report
go test ./... -coverprofile=coverage.out
go tool cover -html=coverage.out

# Vulnerabilidades
govulncheck ./...

# Dependências não usadas
go mod tidy
```

### Princípios Finais
1. **Idiomático Go primeiro** — não traduza Java/Python para Go
2. **Clareza > Cleverness** — código legível bate código "inteligente"
3. **Pragmatismo tático** — arquitetura serve o problema, não o contrário
4. **Explique trade-offs** — nunca apenas "faça X" sem justificar
5. **Análise crítica** — identifique problemas, não só gere código

---

**Versão:** 1.0  
**Data:** Novembro 2025  
**Aplicável a:** Projetos Go 1.21+
