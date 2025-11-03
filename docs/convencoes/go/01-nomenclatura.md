# Nomenclatura em Go

> **"Clareza é melhor que inteligência."** — Rob Pike

Nomenclatura não é sobre preferência estética. É sobre **reduzir atrito cognitivo** ao ler código que você não escreveu — ou que escreveu há 6 meses e esqueceu completamente.

Um nome bem escolhido elimina a necessidade de documentação. Um nome ruim força você a abrir arquivos, rastrear tipos e mergulhar em implementação só para entender o que deveria ser óbvio.

Go não tem decoradores mágicos, anotações ou metaprogramação para compensar nomes ruins. O que você nomeia é exatamente o que outras pessoas vão ler. Sem atalhos.

## Por que nomenclatura importa tanto em Go?

1. **Go não tem classes** — structs e interfaces carregam toda a semântica de tipos
2. **Sem sobrecarga de métodos** — cada nome deve ser único e autoexplicativo
3. **Exportação via capitalização** — a primeira letra define visibilidade pública/privada
4. **Inferência de tipos** — `:=` oculta tipos, então nomes devem compensar com clareza
5. **Code review cultural** — a comunidade Go é extremamente opinativa sobre estilo

Este guia não é sobre regras arbitrárias. É sobre **comunicar intenção com mínimo atrito cognitivo**.

---

## Idioma do Código

**Regra:** O idioma deve ser escolhido pela equipe no início do projeto e **mantido consistente** em todo o código.

**Padrão da comunidade Go:** Inglês (recomendado para projetos open-source ou equipes internacionais).

**Português:** Aceitável para projetos internos onde toda a equipe é brasileira e o domínio de negócio é melhor expresso em português. Esta escolha deve ser **explícita e documentada**.

> ⚠️ **Regra de ouro:** Não misture idiomas. Se escolher português, use em todo o projeto (packages, structs, funções, variáveis). Se escolher inglês, idem.

#### ❌ NÃO FAÇA - Mistura de idiomas
```go
// ❌ Struct em inglês, campos em português
type Student struct {
    Nome     string  // ❌ Inconsistente
    Address  string
}

// ❌ Função em português, tipo em inglês
func obterStudent(id int) Student { ... }

// ❌ Package português, tipos inglês
package aluno
type Student struct { ... }  // ❌ Inconsistente
```

#### ✅ Recomendado - Consistência total
```go
package student

type Student struct {
    Id        string
    Name      string
    BirthDate time.Time
}

func NewStudent(name string, birthDate time.Time) (*Student, error) {
    if name == "" {
        return nil, errors.New("name is required")
    }
    return &Student{
        Id:        generateID(),
        Name:      name,
        BirthDate: birthDate,
    }, nil
}

func (s *Student) Enroll(ctx context.Context, courseId string) error {
    // Implementação
}
```

> **Nota para código em português:** Se optar por português, substitua `ctx` → `contexto`, `err` → `erro`, `NewX` → `NovoX`, mas mantenha 100% consistente.

---

## Convenções de Nomenclatura

| Elemento | Convenção | Exemplo Inglês | Exemplo Português |
|----------|-----------|----------------|-------------------|
| **Packages** | lowercase, singular, sem underscore | `student`, `enrollment` | `aluno`, `matricula` |
| **Structs** | PascalCase (exportado) / camelCase (privado) | `Student`, `Course` | `Aluno`, `Disciplina` |
| **Interfaces** | PascalCase, sufixo `-er` se aplicável | `Repository`, `Notifier` | `Repositorio`, `Notificador` |
| **Funções** | PascalCase (exportado) / camelCase (privado) | `GetStudent()`, `validateEmail()` | `ObterAluno()`, `validarEmail()` |
| **Variáveis** | camelCase | `studentName`, `isActive` | `nomeAluno`, `estaAtivo` |
| **Constantes** | PascalCase (não UPPER_SNAKE) | `MaxRetries`, `DefaultTimeout` | `MaximoTentativas`, `TimeoutPadrao` |
| **Receptores** | 1 letra minúscula | `s *Student`, `r *Repository` | `a *Aluno`, `r *Repositorio` |
| **Context** | Nome completo | `ctx context.Context` | `contexto context.Context` |
| **Erros** | Nome completo | `err error` | `erro error` |
| **Mutexes** | Nome completo | `mutex sync.RWMutex` | `mutex sync.RWMutex` |

---

## Packages

**Regra:** Sempre **singular**, **lowercase**, **sem underscore**.

#### ❌ NÃO FAÇA
```go
package Students          // ❌ Plural
package student_service   // ❌ Underscore
package Student           // ❌ PascalCase
package alunos            // ❌ Plural (se português)
```

#### ✅ Recomendado
```go
// Inglês
package student
package enrollment
package grade

// Português
package aluno
package matricula
package nota
```

**Estrutura de imports:**
```go
import (
    // Standard library (alfabética)
    "context"
    "errors"
    "fmt"
    "time"

    // Externos (alfabética)
    "github.com/gin-gonic/gin"
    "github.com/jackc/pgx/v5/pgxpool"

    // Internos (alfabética, agrupados por módulo)
    "github.com/empresa/escola/internal/domain/aluno"
    "github.com/empresa/escola/internal/infra/config"
)
```

---

## Structs e Types

**Regra:** PascalCase para exportados, camelCase para privados.

#### ✅ Recomendado
```go
// Exportado (público) - Inglês
type Student struct {
    Id        string
    Name      string
    Email     string
    BirthDate time.Time
    CreatedAt time.Time
}

// Exportado (público) - Português
type Aluno struct {
    Id              string
    Nome            string
    Email           string
    DataNascimento  time.Time
    CriadoEm        time.Time
}

// Privado (interno ao pacote)
type alunoCache struct {
    dados map[string]*Aluno
    mutex sync.RWMutex
}

// Value objects
type Email string
type CPF string
```

#### ⚠️ Importante: Campos ID

Use `Id` (maiúsculo + minúsculo) ao invés de `ID` para **evitar conflito com métodos de interface**.

**Contexto técnico:** Quando um struct precisa implementar uma interface que exige um método `ID()`, ter um campo chamado `ID` criaria ambiguidade e erro de compilação.

```go
// ✅ Recomendado - Sem conflito
type Student struct {
    Id   string  // Campo
    Name string
}

// Interface que exige método ID()
type Identifiable interface {
    ID() string
}

// Implementação funciona perfeitamente
func (s *Student) ID() string {
    return s.Id  // Retorna o campo Id
}

// ❌ EVITAR - Causa conflito
type Student struct {
    ID   string  // ❌ Campo ID
}

// ❌ ERRO: método ID e campo ID conflitam
func (s *Student) ID() string {
    return s.ID  // Ambíguo: campo ou método?
}
```

**Ordem dos campos em structs:**
1. IDs e identificadores
2. Campos de negócio
3. Timestamps (CreatedAt, UpdatedAt, DeletedAt)
4. Metadados/flags

```go
// Inglês
type Enrollment struct {
    // Identificadores
    Id        string
    StudentId string
    CourseId  string

    // Negócio
    Status    EnrollmentStatus
    Grade     float64

    // Timestamps
    EnrolledAt   time.Time
    CompletedAt  *time.Time

    // Metadados
    Active       bool
}

// Português
type Matricula struct {
    // Identificadores
    Id           string
    AlunoId      string
    DisciplinaId string

    // Negócio
    Status       StatusMatricula
    Nota         float64

    // Timestamps
    MatriculadoEm time.Time
    ConcluidoEm   *time.Time

    // Metadados
    Ativa         bool
}
```

---

## Interfaces

**Regra:** Pequenas (1-5 métodos), nomeadas com sufixo `-er`/`-or` quando apropriado.

**Por que interfaces pequenas?**
- **Testabilidade:** Mais fácil criar mocks para 2 métodos do que para 15
- **Flexibilidade:** Você pode compor interfaces maiores a partir de pequenas
- **Interface Segregation (SOLID):** Clientes não devem depender de métodos que não usam

**Como pensar:** Pergunte "Esta interface faz UMA coisa coesa?" Se a resposta envolve "e" (ex: "salva E valida E notifica"), quebre em interfaces menores.

**Exemplo escolar:**
- `StudentFinder` → Apenas busca (Find)
- `StudentPersister` → Apenas persistência (Save, Update, Delete)
- `StudentRepository` → Composição de Finder + Persister quando necessário

**Sufixo -er/-or:** Use quando a interface descreve um comportamento ("quem faz algo"). Exemplo: `Reader` (quem lê), `Writer` (quem escreve), `Validator` (quem valida).

**Referência:**
- 📚 Robert C. Martin - Clean Architecture (Interface Segregation Principle)
- 🔗 [Interface Pollution](https://rakyll.org/interface-pollution/) - Rakyll

#### ✅ Recomendado
```go
// Inglês - Sufixo -er para comportamento único
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Notifier interface {
    Notify(ctx context.Context, message string) error
}

// Inglês - Sem sufixo quando descreve papel/repositório
type StudentRepository interface {
    FindByID(ctx context.Context, id string) (*Student, error)
    Save(ctx context.Context, student *Student) error
}

// Português - Sufixo -or/-dor
type Notificador interface {
    Notificar(contexto context.Context, mensagem string) error
}

// Português - Sem sufixo para repositórios
type RepositorioAluno interface {
    BuscarPorID(contexto context.Context, id string) (*Aluno, error)
    Salvar(contexto context.Context, aluno *Aluno) error
}
```

#### ❌ NÃO FAÇA - Interfaces grandes (god interface)
```go
// ❌ Interface monolítica com muitos métodos
type StudentManager interface {
    Create(ctx context.Context, student Student) error
    Update(ctx context.Context, student Student) error
    Delete(ctx context.Context, id string) error
    Find(ctx context.Context, id string) (*Student, error)
    List(ctx context.Context, filter Filter) ([]*Student, error)
    Validate(student Student) error
    SendWelcomeEmail(ctx context.Context, student Student) error
    GenerateReport(ctx context.Context, id string) ([]byte, error)
    // ... 10+ métodos
}
```

**Solução:** Separar em interfaces menores
```go
// ✅ Interfaces segregadas
type StudentRepository interface {
    FindByID(ctx context.Context, id string) (*Student, error)
    Save(ctx context.Context, student *Student) error
    Update(ctx context.Context, student *Student) error
    Delete(ctx context.Context, id string) error
}

type StudentValidator interface {
    Validate(student *Student) error
}

type StudentNotifier interface {
    SendWelcomeEmail(ctx context.Context, student *Student) error
}
```

---

## Funções e Métodos

**Regra:** Iniciar com **verbo** (ação), seguido do substantivo (alvo).

#### ✅ Recomendado
```go
// Inglês - Construtores com New
func NewStudent(name string, email string) (*Student, error)
func NewStudentRepository(pool *pgxpool.Pool) StudentRepository

// Inglês - Métodos CRUD
func (s *StudentService) CreateStudent(ctx context.Context, student *Student) error
func (s *StudentService) GetStudent(ctx context.Context, id string) (*Student, error)
func (s *StudentService) UpdateStudent(ctx context.Context, student *Student) error
func (s *StudentService) DeleteStudent(ctx context.Context, id string) error
func (s *StudentService) ListStudents(ctx context.Context, filter Filter) ([]*Student, error)

// Inglês - Métodos de domínio
func (s *Student) Enroll(ctx context.Context, courseId string) error
func (s *Student) CalculateGPA() float64
func (s *Student) IsActive() bool
func (s *Student) HasCompletedCourse(courseId string) bool

// Português - Construtores com Novo
func NovoAluno(nome string, email string) (*Aluno, error)
func NovoRepositorioAluno(pool *pgxpool.Pool) RepositorioAluno

// Português - Métodos CRUD
func (s *ServicoAluno) CriarAluno(contexto context.Context, aluno *Aluno) error
func (s *ServicoAluno) ObterAluno(contexto context.Context, id string) (*Aluno, error)
func (s *ServicoAluno) AtualizarAluno(contexto context.Context, aluno *Aluno) error
func (s *ServicoAluno) RemoverAluno(contexto context.Context, id string) error
func (s *ServicoAluno) ListarAlunos(contexto context.Context, filtro Filtro) ([]*Aluno, error)

// Português - Métodos de domínio
func (a *Aluno) Matricular(contexto context.Context, disciplinaId string) error
func (a *Aluno) CalcularMedia() float64
func (a *Aluno) EstaAtivo() bool
func (a *Aluno) CompletouDisciplina(disciplinaId string) bool
```

#### ❌ NÃO FAÇA
```go
// ❌ Sem verbo (substantivo apenas)
func Student(name string) *Student  // ❌ Usar NewStudent
func StudentByID(id string) *Student  // ❌ Usar GetStudent ou FindStudent

// ❌ Verbo no final
func StudentCreate(student *Student) error  // ❌ Usar CreateStudent
func StudentDelete(id string) error  // ❌ Usar DeleteStudent
```

#### 📏 Limite de Linha e Formatação de Assinaturas

**Regra:** Máximo de **80 caracteres por linha** (flexível, não rígida).

Para assinaturas de funções/métodos com muitos parâmetros ou nomes longos, use formatação vertical:

```go
// ✅ Assinatura curta - uma linha
func GetStudent(ctx context.Context, id string) (*Student, error)

// ✅ Assinatura longa - formatação vertical
func CreateEnrollmentWithValidation(
    ctx context.Context,
    studentId string,
    courseId string,
    startDate time.Time,
    validator EnrollmentValidator,
) (*Enrollment, error) {
    // Implementação
}

// ✅ Múltiplos retornos - formatação vertical
func ProcessStudentGrades(
    ctx context.Context,
    studentId string,
    grades []float64,
) (average float64, passed bool, err error) {
    // Implementação
}

// ✅ Chamadas longas - formatação vertical
enrollment, err := service.CreateEnrollmentWithValidation(
    ctx,
    student.Id,
    course.Id,
    time.Now(),
    defaultValidator,
)
```

**Nota:** A regra de 80 caracteres é uma **guideline**, não uma restrição absoluta. Priorize legibilidade sobre conformidade estrita.

---

## Variáveis

**Regra:** camelCase, nomes descritivos (evitar abreviações desnecessárias).

#### ✅ Recomendado
```go
// Inglês
var studentName string
var isActive bool
var totalStudents int
var enrollmentDate time.Time

// Português
var nomeAluno string
var estaAtivo bool
var totalAlunos int
var dataMatricula time.Time

// Booleanos: prefixos is/has/can/should (inglês) ou esta/tem/pode/deve (português)
var isEnrolled bool
var hasGraduated bool
var canEnroll bool

var estaMatriculado bool
var foiFormado bool
var podeMatricular bool

// Slices e maps: plural
var students []*Student
var coursesByID map[string]*Course

var alunos []*Aluno
var disciplinasPorID map[string]*Disciplina
```

#### ⚠️ Abreviações Permitidas

Apenas em contextos muito limitados:

```go
// ✅ Aceitável em loops curtos
for i := 0; i < len(students); i++ {
    // ...
}

for idx, student := range students {
    // ...
}

// ✅ Context e error (apenas se código em inglês)
func ProcessStudent(ctx context.Context, id string) error {
    student, err := repository.FindByID(ctx, id)
    if err != nil {
        return err
    }
    // ...
}

// ✅ Context e erro (se código em português)
func ProcessarAluno(contexto context.Context, id string) error {
    aluno, erro := repositorio.BuscarPorID(contexto, id)
    if erro != nil {
        return erro
    }
    // ...
}
```

#### ❌ NÃO FAÇA
```go
// ❌ Abreviações desnecessárias
var stud *Student     // ❌ Usar student
var enr *Enrollment   // ❌ Usar enrollment
var usr *User         // ❌ Usar user

// ❌ Nomes de uma letra (exceto loops e receivers)
func ProcessData(s string, n int, d time.Time) error  // ❌ Nomes crípticos

// ✅ Usar nomes descritivos
func ProcessData(studentName string, age int, enrollmentDate time.Time) error
```

---

## Constantes

**Regra:** PascalCase (não UPPER_SNAKE_CASE).

#### ✅ Recomendado
```go
// Inglês
const (
    MaxStudentsPerClass = 30
    DefaultTimeout      = 30 * time.Second
    MinimumPassingGrade = 7.0
)

// Português
const (
    MaximoAlunosPorTurma = 30
    TimeoutPadrao        = 30 * time.Second
    NotaMinimaAprovacao  = 7.0
)

// Enums com iota
type EnrollmentStatus int

const (
    EnrollmentStatusPending EnrollmentStatus = iota
    EnrollmentStatusActive
    EnrollmentStatusCompleted
    EnrollmentStatusCancelled
)

// Enums em português
type StatusMatricula int

const (
    StatusMatriculaPendente StatusMatricula = iota
    StatusMatriculaAtiva
    StatusMatriculaConcluida
    StatusMatriculaCancelada
)
```

#### ❌ NÃO FAÇA
```go
// ❌ UPPER_SNAKE_CASE (não é idiomático em Go)
const (
    MAX_STUDENTS_PER_CLASS = 30
    DEFAULT_TIMEOUT = 30 * time.Second
    MINIMUM_PASSING_GRADE = 7.0
)
```

---

## Erros Sentinela

**Regra:** Prefixo `Err` (inglês) ou `Erro` (português) + descrição PascalCase.

#### ✅ Recomendado
```go
// Inglês
var (
    ErrStudentNotFound      = errors.New("student not found")
    ErrInvalidEmail         = errors.New("invalid email")
    ErrDuplicateEnrollment  = errors.New("student already enrolled")
    ErrInsufficientGrade    = errors.New("grade below minimum")
)

// Português
var (
    ErroAlunoNaoEncontrado      = errors.New("aluno não encontrado")
    ErroEmailInvalido           = errors.New("email inválido")
    ErroMatriculaDuplicada      = errors.New("aluno já matriculado")
    ErroNotaInsuficiente        = errors.New("nota abaixo do mínimo")
)

// Uso
student, err := repository.FindByID(ctx, id)
if err != nil {
    if errors.Is(err, ErrStudentNotFound) {
        return nil, fmt.Errorf("search failed: %w", err)
    }
    return nil, err
}
```

#### ❌ NÃO FAÇA
```go
// ❌ Sem prefixo Err/Erro
var (
    NotFound      = errors.New("not found")
    InvalidEmail  = errors.New("invalid email")
)

// ❌ UPPER_SNAKE_CASE
var (
    STUDENT_NOT_FOUND = errors.New("student not found")
    INVALID_EMAIL     = errors.New("invalid email")
)

// ❌ Mistura de idiomas
var (
    ErrAlunoNaoEncontrado = errors.New("student not found")  // ❌ Var PT, msg EN
    ErroStudentNotFound   = errors.New("aluno não encontrado")  // ❌ Var EN, msg PT
)
```

---

## Receptores de Métodos

**Regra:** 1 letra minúscula (primeira letra do tipo), consistente em todo o arquivo.

#### ✅ Recomendado
```go
// Inglês - receiver 's' para Student
func (s *Student) Enroll(ctx context.Context, courseId string) error { ... }
func (s *Student) CalculateGPA() float64 { ... }
func (s *Student) IsActive() bool { ... }

// Português - receiver 'a' para Aluno
func (a *Aluno) Matricular(contexto context.Context, disciplinaId string) error { ... }
func (a *Aluno) CalcularMedia() float64 { ... }
func (a *Aluno) EstaAtivo() bool { ... }

// Repository - receiver 'r'
func (r *StudentRepository) FindByID(ctx context.Context, id string) (*Student, error) { ... }
func (r *StudentRepository) Save(ctx context.Context, student *Student) error { ... }

// Service - receiver 's'
func (s *StudentService) CreateStudent(ctx context.Context, student *Student) error { ... }
func (s *StudentService) GetStudent(ctx context.Context, id string) (*Student, error) { ... }
```

#### ❌ NÃO FAÇA
```go
// ❌ Receiver inconsistente no mesmo tipo
func (s *Student) Enroll(...) error { ... }
func (student *Student) IsActive() bool { ... }  // ❌ Usar 's' consistentemente

// ❌ Receiver com nome completo
func (student *Student) Enroll(...) error { ... }  // ❌ Usar 's'
func (repo *StudentRepository) Save(...) error { ... }  // ❌ Usar 'r'
```

---

## Mutexes

**Regra:** Nome completo `mutex` (não `mu`).

#### ✅ Recomendado
```go
// Inglês
type StudentCache struct {
    data  map[string]*Student
    mutex sync.RWMutex
}

func (c *StudentCache) Get(id string) (*Student, bool) {
    c.mutex.RLock()
    defer c.mutex.RUnlock()

    student, ok := c.data[id]
    return student, ok
}

func (c *StudentCache) Set(id string, student *Student) {
    c.mutex.Lock()
    defer c.mutex.Unlock()

    c.data[id] = student
}

// Português
type CacheAluno struct {
    dados map[string]*Aluno
    mutex sync.RWMutex
}

func (c *CacheAluno) Obter(id string) (*Aluno, bool) {
    c.mutex.RLock()
    defer c.mutex.RUnlock()

    aluno, ok := c.dados[id]
    return aluno, ok
}
```

#### ❌ NÃO FAÇA
```go
// ❌ Abreviação 'mu'
type StudentCache struct {
    data map[string]*Student
    mu   sync.RWMutex  // ❌ Usar 'mutex'
}
```

---



---

**Próximo:** [Estrutura de Pastas](02-estrutura-pastas.md) | **Voltar para:** [Índice](README.md)

**Última atualização:** 03/11/2025 16:42
