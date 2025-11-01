# Go Lang

Padrões e convenções para desenvolvimento em Go.

## Introdução

Go (Golang) é uma linguagem de programação criada pelo Google, conhecida por sua simplicidade, eficiência e excelente suporte para concorrência.

## Nomenclatura

### Pacotes

Use nomes curtos, descritivos e em minúsculas:

```go
// ✅ Bom
package user
package http
package database

// ❌ Ruim
package UserPackage
package HTTP_Package
```

### Variáveis e Funções

Use **camelCase** para variáveis privadas e **PascalCase** para exportadas:

```go
// Privado (interno ao pacote)
var userName string
func calculateTotal() int {}

// Público (exportado)
var UserCount int
func GetUserByID(id string) User {}
```

### Constantes

Use **PascalCase** ou **camelCase** conforme visibilidade:

```go
// Exportada
const MaxConnections = 100
const DefaultTimeout = 30 * time.Second

// Privada
const maxRetries = 3
const apiVersion = "v1"
```

### Interfaces

Nome da interface geralmente é o verbo + "er":

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

type Closer interface {
    Close() error
}

// Interface composta
type ReadWriteCloser interface {
    Reader
    Writer
    Closer
}
```

## Estrutura de Projeto

### Layout Padrão

```
project/
├── cmd/
│   └── myapp/
│       └── main.go
├── internal/
│   ├── handlers/
│   ├── models/
│   └── services/
├── pkg/
│   └── utils/
├── api/
├── web/
├── configs/
├── scripts/
├── test/
├── docs/
├── go.mod
├── go.sum
└── README.md
```

### Descrição dos Diretórios

- **cmd/** - Aplicações principais do projeto
- **internal/** - Código privado da aplicação (não pode ser importado por outros projetos)
- **pkg/** - Código que pode ser importado por aplicações externas
- **api/** - Definições de API (OpenAPI/Swagger, Protocol Buffers)
- **web/** - Assets web (templates, static files)
- **configs/** - Arquivos de configuração
- **test/** - Testes adicionais e dados de teste

## Padrões de Código

### 1. Declaração de Variáveis

```go
// ✅ Bom - Declaração curta
name := "João"
count := 42

// ✅ Bom - Declaração com var quando tipo é diferente do valor
var timeout time.Duration = 30 * time.Second

// ✅ Bom - Zero value
var users []User
var enabled bool  // false
var count int     // 0
```

### 2. Tratamento de Erros

```go
// ✅ Bom - Trate erros imediatamente
result, err := doSomething()
if err != nil {
    return nil, fmt.Errorf("failed to do something: %w", err)
}

// ✅ Bom - Guard clauses
func ProcessUser(user *User) error {
    if user == nil {
        return errors.New("user cannot be nil")
    }

    if user.Email == "" {
        return errors.New("email is required")
    }

    // Processar usuário
    return nil
}

// ❌ Ruim - Ignorar erros
result, _ := doSomething()  // Não ignore erros!
```

### 3. Formatação

Use `gofmt` ou `goimports`:

```bash
# Formatar código
gofmt -w .

# Formatar e organizar imports
goimports -w .
```

### 4. Comentários

```go
// Package user provides user management functionality.
package user

// User represents a user in the system.
type User struct {
    ID    string
    Name  string
    Email string
}

// GetUserByID retrieves a user by their ID.
// Returns an error if the user is not found.
func GetUserByID(id string) (*User, error) {
    // Implementation
    return nil, nil
}
```

## Boas Práticas

### 1. Use defer para cleanup

```go
func ReadFile(filename string) ([]byte, error) {
    file, err := os.Open(filename)
    if err != nil {
        return nil, err
    }
    defer file.Close()  // Garante que arquivo será fechado

    return io.ReadAll(file)
}
```

### 2. Inicialize mapas e slices

```go
// ✅ Bom
users := make(map[string]User)
items := make([]Item, 0, 10)  // capacidade inicial

// ❌ Ruim - map nil causa panic
var users map[string]User
users["key"] = User{}  // panic!
```

### 3. Use context para controle de fluxo

```go
func FetchData(ctx context.Context, url string) ([]byte, error) {
    req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
    if err != nil {
        return nil, err
    }

    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    return io.ReadAll(resp.Body)
}

// Uso com timeout
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

data, err := FetchData(ctx, "https://api.example.com/data")
```

### 4. Evite pânico, use erros

```go
// ❌ Ruim
func Divide(a, b int) int {
    if b == 0 {
        panic("division by zero")
    }
    return a / b
}

// ✅ Bom
func Divide(a, b int) (int, error) {
    if b == 0 {
        return 0, errors.New("division by zero")
    }
    return a / b, nil
}
```

## Concorrência

### Goroutines

```go
// Iniciar goroutine
go processData(data)

// Esperar com WaitGroup
var wg sync.WaitGroup

for i := 0; i < 10; i++ {
    wg.Add(1)
    go func(id int) {
        defer wg.Done()
        processItem(id)
    }(i)
}

wg.Wait()
```

### Channels

```go
// Canal básico
ch := make(chan int)

// Enviar
go func() {
    ch <- 42
}()

// Receber
value := <-ch

// Canal com buffer
ch := make(chan int, 100)

// Select para múltiplos canais
select {
case msg := <-ch1:
    fmt.Println("Received from ch1:", msg)
case msg := <-ch2:
    fmt.Println("Received from ch2:", msg)
case <-time.After(1 * time.Second):
    fmt.Println("Timeout")
}
```

### Mutex para sincronização

```go
type SafeCounter struct {
    mu    sync.Mutex
    count int
}

func (c *SafeCounter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.count++
}

func (c *SafeCounter) Value() int {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.count
}
```

## Testes

### Teste Básico

```go
// user_test.go
package user

import "testing"

func TestGetUserByID(t *testing.T) {
    user, err := GetUserByID("123")

    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }

    if user.ID != "123" {
        t.Errorf("expected ID 123, got %s", user.ID)
    }
}
```

### Table-Driven Tests

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -2, -3, -5},
        {"mixed", 2, -3, -1},
        {"zero", 0, 5, 5},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Add(tt.a, tt.b)
            if result != tt.expected {
                t.Errorf("Add(%d, %d) = %d; want %d",
                    tt.a, tt.b, result, tt.expected)
            }
        })
    }
}
```

### Benchmarks

```go
func BenchmarkCalculate(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Calculate(100)
    }
}
```

## Exemplo Completo: HTTP Server

```go
package main

import (
    "encoding/json"
    "log"
    "net/http"
    "time"
)

type User struct {
    ID        string    `json:"id"`
    Name      string    `json:"name"`
    Email     string    `json:"email"`
    CreatedAt time.Time `json:"created_at"`
}

type Server struct {
    users map[string]User
}

func NewServer() *Server {
    return &Server{
        users: make(map[string]User),
    }
}

func (s *Server) handleGetUser(w http.ResponseWriter, r *http.Request) {
    id := r.URL.Query().Get("id")

    user, ok := s.users[id]
    if !ok {
        http.Error(w, "user not found", http.StatusNotFound)
        return
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(user)
}

func (s *Server) handleCreateUser(w http.ResponseWriter, r *http.Request) {
    var user User

    if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    user.CreatedAt = time.Now()
    s.users[user.ID] = user

    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(user)
}

func main() {
    server := NewServer()

    http.HandleFunc("/user", func(w http.ResponseWriter, r *http.Request) {
        switch r.Method {
        case http.MethodGet:
            server.handleGetUser(w, r)
        case http.MethodPost:
            server.handleCreateUser(w, r)
        default:
            http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
        }
    })

    log.Println("Server starting on :8080")
    if err := http.ListenAndServe(":8080", nil); err != nil {
        log.Fatal(err)
    }
}
```

## Ferramentas Essenciais

### Linting

```bash
# Instalar golangci-lint
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Rodar
golangci-lint run
```

### Formatação

```bash
# gofmt
gofmt -w .

# goimports (organiza imports)
go install golang.org/x/tools/cmd/goimports@latest
goimports -w .
```

### Testes

```bash
# Rodar todos os testes
go test ./...

# Com coverage
go test -cover ./...

# Coverage detalhado
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### Dependency Management

```bash
# Inicializar módulo
go mod init github.com/username/project

# Adicionar dependência
go get github.com/gorilla/mux

# Limpar dependências não usadas
go mod tidy

# Verificar dependências
go mod verify
```

## Checklist de Code Review

- [ ] Código formatado com `gofmt`
- [ ] Imports organizados
- [ ] Erros tratados adequadamente
- [ ] Comentários em funções exportadas
- [ ] Testes escritos
- [ ] Sem goroutine leaks
- [ ] Context usado para cancelamento
- [ ] Recursos liberados com defer
- [ ] Nomes seguem convenções Go
- [ ] Sem código não utilizado

## Recursos Adicionais

- [Effective Go](https://go.dev/doc/effective_go)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Go by Example](https://gobyexample.com/)
- [Standard Go Project Layout](https://github.com/golang-standards/project-layout)
- [Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md)
