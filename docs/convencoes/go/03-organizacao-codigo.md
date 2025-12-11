# Organização de Código em Go

> **"Código idiomático não é sobre seguir regras — é sobre comunicar intenção sem esforço."**

Go é uma linguagem opinativa. Há **uma** forma idiomática de propagar contexto, **uma** forma idiomática de tratar erros, **uma** forma idiomática de estruturar concorrência.

Ignorar essas convenções não quebra o compilador, mas quebra a **legibilidade universal** — qualquer desenvolvedor Go experiente reconhece padrões idiomáticos instantaneamente. Código não-idiomático força análise extra, mesmo que funcione.

## Por que organização de código importa em Go?

1. **Context propagation é obrigatória** — Sem `context.Context`, você perde cancelamento e timeouts
2. **Error handling é explícito** — Go não tem exceptions, então `if err != nil` aparece em TODA função
3. **Defer controla cleanup** — Arquivos, conexões, locks precisam de `defer` ou vazam recursos
4. **Goroutines são baratas mas perigosas** — 1 milhão de goroutines é viável, mas sem controle vira vazamento de memória
5. **Channels orquestram concorrência** — Mal usados, causam deadlocks silenciosos

Este guia não é sobre preferências pessoais. É sobre **padrões que a comunidade Go consolidou em 15 anos**.

---

## Propagação de Context

**Regra:** Context sempre como **primeiro parâmetro**, nunca armazenar em structs.

**Por que Context é importante?**
- **Cancelamento:** Permite interromper operações longas (ex: usuário fechou navegador, não precisa terminar consulta SQL)
- **Timeouts:** Define limites de tempo para operações
- **Valores de request:** Passa request ID, user ID através da call stack sem poluir assinaturas

**Por que não guardar em struct?**
Se você guardar `ctx` em struct, ele "vaza" o escopo da requisição. Imagine:
1. Request 1 chega, você cria `service` com `ctx1`
2. Request 2 chega, reutiliza mesmo `service`, mas deveria usar `ctx2`
3. Resultado: `ctx1` pode cancelar operações de `ctx2` (bug grave!)

**Exemplo escolar:**
```go
// ❌ ERRADO: Context em struct
type EnrollmentService struct {
    ctx context.Context  // Perigoso! Mistura requisições
}

// ✅ CORRETO: Context como parâmetro
func (s *EnrollmentService) ProcessEnrollment(
    ctx context.Context,  // Cada chamada tem seu próprio contexto
    studentId string,
) error
```

**Referência:**
- 🔗 [Go Context Package](https://pkg.go.dev/context) - Documentação oficial
- 🔗 [Context and Cancellation](https://go.dev/blog/context) - Blog oficial

#### ✅ Recomendado
```go
func (s *StudentService) ProcessEnrollment(ctx context.Context, enrollment *Enrollment) error
func (r *StudentRepository) FindByID(ctx context.Context, id string) (*Student, error)
func (h *StudentHandler) HandleRequest(ctx context.Context, req Request) (Response, error)
```

#### ❌ NÃO FAÇA
```go
// ❌ Context armazenado em struct
type StudentService struct {
    ctx context.Context  // ❌ Nunca fazer isso
}

// ❌ Context não é primeiro parâmetro
func (s *StudentService) Process(id string, ctx context.Context) error

// ❌ Context não propagado
func (s *StudentService) Process(id string) error {
    // Sem context, não pode cancelar ou passar valores
}
```

**Context values (use com moderação):**
```go
// Definir chaves como tipos privados
type contextKey string

const (
    userIDKey    contextKey = "user_id"
    requestIDKey contextKey = "request_id"
)

// Adicionar valor
ctx = context.WithValue(ctx, userIDKey, "user-123")

// Recuperar valor
if userID, ok := ctx.Value(userIDKey).(string); ok {
    // Usar userID
}
```

**Referência:**
- 🔗 [Go Context Package](https://pkg.go.dev/context) - Documentação oficial

---

## Tratamento de Erros

**Regra:** Sempre encapsular erros com contexto usando `fmt.Errorf` com `%w`.

**Por que encapsular erros?**

Erros em Go não têm stack traces automáticos. Quando você retorna `err` direto, perde **onde** o erro aconteceu na call stack. Encapsular com `%w` cria uma cadeia de contexto rastreável.

**Exemplo do problema:**
```go
// ❌ Sem contexto
func ProcessEnrollment(studentId string) error {
    err := repository.FindByID(studentId)
    if err != nil {
        return err  // Erro diz "not found", mas não diz ONDE nem POR QUÊ
    }
}

// Você recebe: "not found"
// Não sabe: foi student? course? enrollment? Qual ID?
```

**Solução com contexto:**
```go
// ✅ Com contexto
func ProcessEnrollment(studentId string) error {
    err := repository.FindByID(studentId)
    if err != nil {
        return fmt.Errorf("process enrollment for student %s: %w", studentId, err)
    }
}

// Você recebe: "process enrollment for student abc123: student not found"
// Agora sabe: erro em enrollment, student abc123, causa raiz "not found"
```

**Por que `%w` e não `%v`?**

- `%w` = **Wraps** o erro original, permite usar `errors.Is()` e `errors.As()`
- `%v` = **Converte** erro para string, perde tipo original (não consegue detectar `ErrStudentNotFound`)

**Referências:**
- 🔗 [Error Handling in Go](https://go.dev/blog/error-handling-and-go) - Blog oficial
- 🔗 [Working with Errors](https://go.dev/blog/go1.13-errors) - Go 1.13+ errors package

#### ✅ Recomendado
```go
func (s *StudentService) GetStudent(ctx context.Context, id string) (*Student, error) {
    student, err := s.repository.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("get student %s: %w", id, err)
    }

    if err := s.validator.Validate(student); err != nil {
        return nil, fmt.Errorf("validate student: %w", err)
    }

    return student, nil
}

// Verificação de erro específico
student, err := service.GetStudent(ctx, "123")
if err != nil {
    if errors.Is(err, ErrStudentNotFound) {
        // Tratar erro específico
    }
    return err
}
```

#### ❌ NÃO FAÇA
```go
func (s *StudentService) GetStudent(ctx context.Context, id string) (*Student, error) {
    student, err := s.repository.FindByID(ctx, id)
    if err != nil {
        return nil, err  // ❌ Erro sem contexto
    }

    if student == nil {
        return nil, errors.New("student not found")  // ❌ Erro genérico
    }

    return student, nil
}
```

**Erros sentinela (sentinel errors):**
```go
package student

import "errors"

var (
    ErrStudentNotFound = errors.New("student not found")
    ErrInvalidEmail    = errors.New("invalid email")
    ErrDuplicateEmail  = errors.New("email already exists")
)

// Uso
func (r *StudentRepository) FindByID(ctx context.Context, id string) (*Student, error) {
    // ...
    if notFound {
        return nil, ErrStudentNotFound
    }
    return student, nil
}
```

**Referência:**
- 🔗 [Error Handling in Go](https://go.dev/blog/error-handling-and-go) - Blog oficial
- 🔗 [Working with Errors](https://go.dev/blog/go1.13-errors) - Go 1.13+ errors

#### ⚡ Early Return (Evitar else desnecessário)

**Regra:** Preferir retornos antecipados ao invés de blocos `else` (flexível, não rígida).

```go
// ✅ Recomendado - Early return
func ValidateStudent(student *Student) error {
    if student == nil {
        return ErrNilStudent
    }

    if student.Name == "" {
        return ErrInvalidName
    }

    if !isValidEmail(student.Email) {
        return ErrInvalidEmail
    }

    // Caminho feliz sem indentação excessiva
    return nil
}

// ✅ Recomendado - Early return com lógica
func CalculateDiscount(student *Student) float64 {
    if student == nil {
        return 0
    }

    if student.GPA >= 9.0 {
        return 0.20  // 20% desconto
    }

    if student.GPA >= 7.0 {
        return 0.10  // 10% desconto
    }

    return 0  // Sem desconto
}

// ❌ EVITAR - else desnecessário
func ValidateStudent(student *Student) error {
    if student == nil {
        return ErrNilStudent
    } else {  // ❌ else desnecessário
        if student.Name == "" {
            return ErrInvalidName
        } else {  // ❌ else desnecessário
            if !isValidEmail(student.Email) {
                return ErrInvalidEmail
            } else {  // ❌ else desnecessário
                return nil
            }
        }
    }
}

// ⚠️ Exceção - else aceitável quando melhora legibilidade
func GetStudentStatus(student *Student) string {
    if student.IsActive {
        return "Active"
    } else {
        return "Inactive"  // ✅ else claro aqui
    }
}
```

**Nota:** A regra de evitar `else` visa **reduzir indentação** e melhorar legibilidade. Use bom senso: se `else` torna o código mais claro, use-o.

---

## Nil vs Slices Vazios

**Regra:** Preferir `nil` slices ao invés de slices vazios.

**Por que isso importa?**

Em Go, `nil` slices e slices vazios são **funcionalmente equivalentes** para operações normais (`len()`, `range`, `append`), mas há diferenças sutis:

1. **Memória:** `nil` não aloca, `[]T{}` aloca estrutura interna (header)
2. **JSON:** `nil` serializa como `null`, `[]T{}` serializa como `[]`
3. **Semântica:** `nil` significa "ausência de dados", `[]T{}` significa "lista vazia intencional"

**Exemplo do impacto em JSON:**
```go
type Response struct {
    Students []Student `json:"students"`
}

// nil slice
resp := Response{Students: nil}
// JSON: {"students": null}

// Empty slice
resp := Response{Students: []Student{}}
// JSON: {"students": []}
```

**Quando usar cada um:**

- ✅ **`nil`** → Quando não há dados (caso padrão)
- ✅ **`[]T{}`** → Quando você PRECISA de lista vazia explícita em JSON/API

**Regra prática:** Use `nil` por padrão. Só use `[]T{}` quando a diferença semântica importa (ex: APIs REST que diferenciam `null` vs `[]`).

**Referências:**
- 🔗 [Go Slices: usage and internals](https://go.dev/blog/slices-intro) - Blog oficial
- 🔗 [Nil slices vs empty slices](https://www.youtube.com/watch?v=YS4e4q9oBaU) - JustForFunc

#### ✅ Recomendado
```go
func GetStudents(filter Filter) ([]Student, error) {
    if nothingFound {
        return nil, nil  // ✅ Retorna nil
    }

    students := []Student{}  // Inicializa apenas quando vai popular
    // ... popula students
    return students, nil
}

// Tratamento (ambos funcionam igual)
students, err := GetStudents(filter)
for _, student := range students {  // ✅ Funciona com nil ou []
    // ...
}

if len(students) == 0 {  // ✅ Funciona com nil ou []
    // Não há estudantes
}
```

#### ⚠️ Evitar (mas não é erro)
```go
func GetStudents(filter Filter) ([]Student, error) {
    if nothingFound {
        return []Student{}, nil  // ⚠️ Aloca memória desnecessariamente
    }
    // ...
}
```

**Importante:** Ambos funcionam, mas `nil` é mais idiomático e eficiente.

---

## Inicialização de Structs

**Regra:** Usar composite literals com campos nomeados.

#### ✅ Recomendado
```go
student := Student{
    Id:        "123",
    Name:      "John Doe",
    Email:     "john@school.edu",
    CreatedAt: time.Now(),
}

// Construtores para validação
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
    }, nil
}
```

#### ❌ NÃO FAÇA
```go
// ❌ Campos posicionais (frágil a mudanças)
student := Student{"123", "John Doe", "john@school.edu", time.Now()}

// ❌ Struct vazio sem validação
student := Student{}
student.Name = "John"  // Campos obrigatórios não populados
```

---

## Defer para Cleanup

**Regra:** Sempre usar `defer` para liberar recursos.

**Por que defer é crítico?**

Recursos não liberados causam **vazamentos** que não são óbvios:

1. **File descriptors:** Linux limita ~1024 FDs por processo. Esqueça `Close()`, app para em produção
2. **Database connections:** Pool esgota, novas requests travam esperando conexão livre
3. **Mutexes:** Goroutine trava esperando lock que nunca foi liberado (deadlock)
4. **HTTP response bodies:** Vazamento de memória e conexões TCP

**Problema sem defer:**
```go
// ❌ Perigoso
func ProcessFile(filename string) error {
    file, err := os.Open(filename)
    if err != nil {
        return err
    }

    data, err := io.ReadAll(file)
    if err != nil {
        return err  // ❌ BUG: file.Close() nunca chamado!
    }

    file.Close()  // ❌ Só fecha em caso de sucesso
    return nil
}
```

**Solução com defer:**
```go
// ✅ Seguro
func ProcessFile(filename string) error {
    file, err := os.Open(filename)
    if err != nil {
        return err
    }
    defer file.Close()  // ✅ Garante fechamento em QUALQUER cenário

    data, err := io.ReadAll(file)
    if err != nil {
        return err  // ✅ file.Close() será chamado
    }

    return nil  // ✅ file.Close() será chamado
}
```

**Ordem de execução:** LIFO (Last In, First Out) — último defer declarado é o primeiro executado.

```go
func Example() {
    defer fmt.Println("3")
    defer fmt.Println("2")
    defer fmt.Println("1")
    fmt.Println("Start")
}
// Output:
// Start
// 1
// 2
// 3
```

**Armadilha: Defer em loops**
```go
// ❌ VAZAMENTO: defer só executa no fim da FUNÇÃO, não da iteração
func ProcessFiles(files []string) error {
    for _, filename := range files {
        file, err := os.Open(filename)
        if err != nil {
            return err
        }
        defer file.Close()  // ❌ Acumula N arquivos abertos!
        // ...
    }
    return nil
}

// ✅ CORRETO: Encapsular em função auxiliar
func ProcessFiles(files []string) error {
    for _, filename := range files {
        if err := processFile(filename); err != nil {
            return err
        }
    }
    return nil
}

func processFile(filename string) error {
    file, err := os.Open(filename)
    if err != nil {
        return err
    }
    defer file.Close()  // ✅ Fecha no fim desta função
    // ...
    return nil
}
```

**Referências:**
- 🔗 [Defer, Panic, and Recover](https://go.dev/blog/defer-panic-and-recover) - Blog oficial

#### ✅ Recomendado
```go
func ProcessFile(filename string) error {
    file, err := os.Open(filename)
    if err != nil {
        return err
    }
    defer file.Close()  // ✅ Garante fechamento

    // Processar arquivo
    return nil
}

// Locks
func (c *StudentCache) Get(key string) (interface{}, bool) {
    c.mutex.RLock()
    defer c.mutex.RUnlock()  // ✅ Garante unlock

    value, ok := c.data[key]
    return value, ok
}

// Transações
func (s *StudentService) CreateStudent(ctx context.Context, student Student) error {
    tx, err := s.db.Begin(ctx)
    if err != nil {
        return err
    }
    defer tx.Rollback(ctx)  // ✅ Rollback se não commitar

    // ... operações

    return tx.Commit(ctx)  // Commit explícito
}
```

---

## Goroutines e WaitGroups

**Regra:** Sempre sincronizar goroutines com WaitGroup ou context.

**Por que sincronização é crítica?**

Goroutines são tão baratas (2KB de stack inicial) que é tentador criar milhares delas. Mas sem controle:

1. **Vazamento de goroutines:** Goroutines órfãs continuam consumindo memória indefinidamente
2. **Race conditions:** Múltiplas goroutines acessando mesma variável sem sincronização
3. **Função retorna antes de goroutines terminarem:** Dados não processados, arquivos não salvos

**Problema: Goroutines sem sincronização**
```go
// ❌ PERIGOSO
func ProcessStudents(students []Student) {
    for _, student := range students {
        go func(s Student) {
            // Processar student...
            fmt.Println(s.Name)
        }(student)
    }
    // ❌ Função retorna IMEDIATAMENTE
    // Goroutines podem não ter terminado!
}

func main() {
    ProcessStudents(students)
    // Programa termina, goroutines são abortadas
}
```

**Solução 1: WaitGroup (quando você quer esperar todas)**
```go
// ✅ CORRETO
func ProcessStudents(students []Student) {
    var wg sync.WaitGroup

    for _, student := range students {
        wg.Add(1)  // Incrementa contador
        go func(s Student) {
            defer wg.Done()  // Decrementa ao terminar
            // Processar student...
        }(student)
    }

    wg.Wait()  // Bloqueia até todas goroutines terminarem
}
```

**Solução 2: Context (quando você quer cancelar)**
```go
// ✅ CORRETO com cancelamento
func ProcessStudents(ctx context.Context, students []Student) error {
    var wg sync.WaitGroup
    errChan := make(chan error, 1)

    for _, student := range students {
        wg.Add(1)
        go func(s Student) {
            defer wg.Done()

            select {
            case <-ctx.Done():
                return  // Cancelado
            default:
                if err := process(s); err != nil {
                    errChan <- err
                }
            }
        }(student)
    }

    wg.Wait()
    close(errChan)

    if err := <-errChan; err != nil {
        return err
    }
    return nil
}
```

**Armadilha: Captura de variável de loop**
```go
// ❌ BUG CLÁSSICO: todas goroutines processam ÚLTIMO student
for _, student := range students {
    go func() {
        process(student)  // ❌ Captura variável do loop!
    }()
}

// ✅ CORRETO: passar como parâmetro
for _, student := range students {
    go func(s Student) {
        process(s)  // ✅ Cópia da variável
    }(student)
}
```

**Referências:**
- 🔗 [Concurrency](https://go.dev/tour/concurrency/1) - Go Tour
- 🔗 [Share Memory By Communicating](https://go.dev/blog/codelab-share) - Blog oficial
- 🔗 [Common Goroutine Leaks](https://www.youtube.com/watch?v=3EW1hZ8DVyw) - GopherCon

#### ✅ Recomendado
```go
func ProcessBatch(items []Item) {
    var wg sync.WaitGroup

    for _, item := range items {
        wg.Add(1)
        go func(i Item) {
            defer wg.Done()
            process(i)
        }(item)  // ✅ Passa item como parâmetro
    }

    wg.Wait()  // ✅ Aguarda todas as goroutines
}

// Com context para cancelamento
func ProcessBatchWithContext(ctx context.Context, items []Item) error {
    var wg sync.WaitGroup
    errChan := make(chan error, len(items))

    for _, item := range items {
        wg.Add(1)
        go func(i Item) {
            defer wg.Done()

            select {
            case <-ctx.Done():
                errChan <- ctx.Err()
                return
            default:
                if err := process(i); err != nil {
                    errChan <- err
                }
            }
        }(item)
    }

    wg.Wait()
    close(errChan)

    // Verificar erros
    for err := range errChan {
        if err != nil {
            return err
        }
    }

    return nil
}
```

#### ❌ NÃO FAÇA
```go
func ProcessBatch(items []Item) {
    for _, item := range items {
        go func() {
            process(item)  // ❌ Closure captura variável do loop
        }()
    }
    // ❌ Não aguarda goroutines terminarem
}
```

**Referência:**
- 🔗 [Effective Go - Concurrency](https://go.dev/doc/effective_go#concurrency) - Documentação oficial

---

## Channels e Select

**Regra:** Usar channels para comunicação entre goroutines, `select` para multiplexação. Sempre fechar channels no lado do **produtor**.

**Por que channels existem?**

Go segue o princípio **"Don't communicate by sharing memory; share memory by communicating"**. Ao invés de múltiplas goroutines acessando variáveis compartilhadas com mutexes (error-prone), você envia dados por channels.

**Trade-offs:**

| Abordagem | Quando usar | Vantagem | Desvantagem |
|-----------|-------------|----------|-------------|
| **Mutex** | Proteger estado compartilhado | Simples, baixo overhead | Fácil esquecer lock/unlock (deadlock) |
| **Channel** | Pipeline de dados, coordenação | Menos race conditions, idiomático | Overhead maior, deadlock se mal usado |

**Tipos de channels:**

1. **Unbuffered** (`make(chan T)`) → Bloqueia até receptor estar pronto (sincronização estrita)
2. **Buffered** (`make(chan T, N)`) → Permite N mensagens enfileiradas (decoupling)

**Problema: Deadlock com unbuffered channel**
```go
// ❌ DEADLOCK
func main() {
    ch := make(chan int)
    ch <- 42  // ❌ Bloqueia para sempre (ninguém recebendo)
    fmt.Println(<-ch)
}

// ✅ CORRETO: goroutine separada
func main() {
    ch := make(chan int)
    go func() {
        ch <- 42  // Goroutine envia
    }()
    fmt.Println(<-ch)  // Main recebe
}
```

**Select: Multiplexação de channels**

`select` é como `switch`, mas para channels — bloqueia até um caso estar pronto.

```go
// ✅ Timeout pattern
func FetchWithTimeout(url string) (string, error) {
    resultChan := make(chan string, 1)
    errorChan := make(chan error, 1)

    go func() {
        data, err := http.Get(url)
        if err != nil {
            errorChan <- err
            return
        }
        resultChan <- data
    }()

    select {
    case result := <-resultChan:
        return result, nil
    case err := <-errorChan:
        return "", err
    case <-time.After(5 * time.Second):
        return "", errors.New("timeout após 5s")
    }
}
```

**Armadilha: Fechar channel múltiplas vezes**
```go
// ❌ PANIC
ch := make(chan int)
close(ch)
close(ch)  // ❌ PANIC: close of closed channel

// ✅ CORRETO: apenas o sender fecha
func producer(out chan<- int) {
    defer close(out)  // ✅ Sender fecha quando terminar
    for i := 0; i < 10; i++ {
        out <- i
    }
}

func consumer(in <-chan int) {
    for val := range in {  // ✅ Loop termina quando channel fecha
        fmt.Println(val)
    }
}
```

**Referências:**
- 🔗 [Go Concurrency Patterns](https://go.dev/talks/2012/concurrency.slide) - Rob Pike
- 🔗 [Advanced Go Concurrency Patterns](https://go.dev/blog/io2013-talk-concurrency) - Blog oficial
- 📚 Concurrency in Go (Katherine Cox-Buday)

#### ✅ Recomendado
```go
// Producer
func generateNumbers(max int) <-chan int {
    ch := make(chan int)

    go func() {
        defer close(ch)  // ✅ Producer fecha o channel

        for i := 0; i < max; i++ {
            ch <- i
        }
    }()

    return ch
}

// Consumer
func consumeNumbers(ch <-chan int) {
    for num := range ch {  // ✅ Range detecta channel fechado
        process(num)
    }
}

// Select com timeout
func fetchWithTimeout(ctx context.Context, url string) ([]byte, error) {
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()

    resultCh := make(chan []byte)
    errCh := make(chan error)

    go func() {
        data, err := fetch(url)
        if err != nil {
            errCh <- err
            return
        }
        resultCh <- data
    }()

    select {
    case data := <-resultCh:
        return data, nil
    case err := <-errCh:
        return nil, err
    case <-ctx.Done():
        return nil, ctx.Err()
    }
}
```

#### ❌ NÃO FAÇA
```go
func consumeNumbers(ch <-chan int) {
    for {
        num, ok := <-ch
        if !ok {
            break
        }
        process(num)
    }
    close(ch)  // ❌ Consumer não deve fechar channel
}
```

---



---

**Próximo:** [Padrões de Design](04-padroes-design.md) | **Anterior:** [Estrutura de Pastas](02-estrutura-pastas.md) | **Voltar para:** [Índice](README.md)

**Última atualização:** 03/11/2025 16:42
