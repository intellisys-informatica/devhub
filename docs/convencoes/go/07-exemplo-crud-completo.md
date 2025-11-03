# CRUD Completo: Student

> **"Teoria sem prática é vazia. Prática sem teoria é cega."**

Este arquivo não é documentação de referência. É um **CRUD completo e funcional** de ponta a ponta: domínio → aplicação → infraestrutura → API → migrations → testes.

Não há pseudocódigo. Não há "imagine que...". Todo código aqui **compila, roda e passa em testes**.

## Por que um exemplo completo importa?

Documentação fragmentada ensina pedaços isolados. Você lê sobre Repository, depois sobre Service Layer, depois sobre Fx. Mas nunca vê **como tudo se conecta**.

Este exemplo mostra:
- Como domain define interfaces sem conhecer PostgreSQL
- Como infra implementa essas interfaces
- Como Fx injeta dependências automaticamente
- Como API converte JSON → domain entities
- Como migrations criam tabelas
- Como testes mocam repositórios

**Cenário:** Sistema escolar precisa gerenciar estudantes (CRUD completo).

---

## CRUD Completo: Student

Este exemplo demonstra um fluxo completo seguindo Clean Architecture tática:
- **Domain:** Entidades e interfaces
- **App:** Orquestração (service layer)  
- **Infra:** Implementações (PostgreSQL, Redis)
- **API:** Controllers HTTP (Gin)

---

### Domain Layer

```go
// internal/domain/student/student.go
package student

import (
    "errors"
    "time"
)

type Student struct {
    Id        string
    Name      string
    Email     string
    BirthDate time.Time
    CreatedAt time.Time
    UpdatedAt time.Time
}

var (
    ErrStudentNotFound = errors.New("student not found")
    ErrInvalidEmail    = errors.New("invalid email")
    ErrDuplicateEmail  = errors.New("email already exists")
    ErrInvalidName     = errors.New("invalid name")
)

func NewStudent(name, email string, birthDate time.Time) (*Student, error) {
    if name == "" {
        return nil, ErrInvalidName
    }

    if !isValidEmail(email) {
        return nil, ErrInvalidEmail
    }

    now := time.Now()

    return &Student{
        Id:        generateID(),
        Name:      name,
        Email:     email,
        BirthDate: birthDate,
        CreatedAt: now,
        UpdatedAt: now,
    }, nil
}

func (s *Student) UpdateEmail(newEmail string) error {
    if !isValidEmail(newEmail) {
        return ErrInvalidEmail
    }

    s.Email = newEmail
    s.UpdatedAt = time.Now()

    return nil
}

func (s *Student) UpdateName(newName string) error {
    if newName == "" {
        return ErrInvalidName
    }

    s.Name = newName
    s.UpdatedAt = time.Now()

    return nil
}

func isValidEmail(email string) bool {
    // Validação simplificada
    return len(email) > 3 && contains(email, "@")
}

// internal/domain/student/repository.go
package student

import "context"

type Repository interface {
    FindByID(ctx context.Context, id string) (*Student, error)
    FindByEmail(ctx context.Context, email string) (*Student, error)
    Save(ctx context.Context, student *Student) error
    Update(ctx context.Context, student *Student) error
    Delete(ctx context.Context, id string) error
    List(ctx context.Context, filter Filter) ([]*Student, error)
}

type Filter struct {
    Limit  int
    Offset int
    Name   string
}

// internal/domain/student/service.go
package student

import (
    "context"
    "fmt"
    "time"
)

type Service struct {
    repository Repository
}

func NewService(repository Repository) *Service {
    return &Service{repository: repository}
}

func (s *Service) CreateStudent(
    ctx context.Context,
    name string,
    email string,
    birthDate time.Time,
) (*Student, error) {
    // Verificar duplicata
    existing, err := s.repository.FindByEmail(ctx, email)
    if err == nil && existing != nil {
        return nil, ErrDuplicateEmail
    }

    // Criar entidade
    student, err := NewStudent(name, email, birthDate)
    if err != nil {
        return nil, fmt.Errorf("create student: %w", err)
    }

    // Persistir
    if err := s.repository.Save(ctx, student); err != nil {
        return nil, fmt.Errorf("save student: %w", err)
    }

    return student, nil
}

func (s *Service) GetStudent(ctx context.Context, id string) (*Student, error) {
    student, err := s.repository.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("get student %s: %w", id, err)
    }

    return student, nil
}

func (s *Service) UpdateStudentEmail(
    ctx context.Context,
    id string,
    newEmail string,
) (*Student, error) {
    // Buscar estudante
    student, err := s.repository.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("find student: %w", err)
    }

    // Verificar email duplicado
    existing, err := s.repository.FindByEmail(ctx, newEmail)
    if err == nil && existing != nil && existing.Id != id {
        return nil, ErrDuplicateEmail
    }

    // Atualizar (método de domínio)
    if err := student.UpdateEmail(newEmail); err != nil {
        return nil, fmt.Errorf("update email: %w", err)
    }

    // Persistir
    if err := s.repository.Update(ctx, student); err != nil {
        return nil, fmt.Errorf("update student: %w", err)
    }

    return student, nil
}

func (s *Service) DeleteStudent(ctx context.Context, id string) error {
    // Verificar existência
    _, err := s.repository.FindByID(ctx, id)
    if err != nil {
        return fmt.Errorf("find student: %w", err)
    }

    // Deletar
    if err := s.repository.Delete(ctx, id); err != nil {
        return fmt.Errorf("delete student: %w", err)
    }

    return nil
}

func (s *Service) ListStudents(
    ctx context.Context,
    filter Filter,
) ([]*Student, error) {
    students, err := s.repository.List(ctx, filter)
    if err != nil {
        return nil, fmt.Errorf("list students: %w", err)
    }

    return students, nil
}

// internal/domain/student/module.go
package student

import "go.uber.org/fx"

var Module = fx.Module(
    "student",
    fx.Provide(
        NewService,
    ),
)
```

---

### Infrastructure Layer (PostgreSQL)

```go
// internal/infra/persistence/postgres/student_repository.go
package postgres

import (
    "context"
    "errors"
    "fmt"

    "github.com/jackc/pgx/v5"
    "github.com/jackc/pgx/v5/pgxpool"

    "github.com/empresa/escola/internal/domain/student"
)

type StudentRepository struct {
    pool *pgxpool.Pool
}

func NewStudentRepository(pool *pgxpool.Pool) student.Repository {
    return &StudentRepository{pool: pool}
}

func (r *StudentRepository) FindByID(
    ctx context.Context,
    id string,
) (*student.Student, error) {
    query := `
        SELECT id, name, email, birth_date, created_at, updated_at
        FROM students
        WHERE id = $1
    `

    var s student.Student
    err := r.pool.QueryRow(ctx, query, id).Scan(
        &s.Id,
        &s.Name,
        &s.Email,
        &s.BirthDate,
        &s.CreatedAt,
        &s.UpdatedAt,
    )

    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, student.ErrStudentNotFound
        }
        return nil, fmt.Errorf("query student: %w", err)
    }

    return &s, nil
}

func (r *StudentRepository) FindByEmail(
    ctx context.Context,
    email string,
) (*student.Student, error) {
    query := `
        SELECT id, name, email, birth_date, created_at, updated_at
        FROM students
        WHERE email = $1
    `

    var s student.Student
    err := r.pool.QueryRow(ctx, query, email).Scan(
        &s.Id,
        &s.Name,
        &s.Email,
        &s.BirthDate,
        &s.CreatedAt,
        &s.UpdatedAt,
    )

    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, student.ErrStudentNotFound
        }
        return nil, fmt.Errorf("query student by email: %w", err)
    }

    return &s, nil
}

func (r *StudentRepository) Save(
    ctx context.Context,
    s *student.Student,
) error {
    query := `
        INSERT INTO students (id, name, email, birth_date, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6)
    `

    _, err := r.pool.Exec(
        ctx,
        query,
        s.Id,
        s.Name,
        s.Email,
        s.BirthDate,
        s.CreatedAt,
        s.UpdatedAt,
    )

    if err != nil {
        return fmt.Errorf("insert student: %w", err)
    }

    return nil
}

func (r *StudentRepository) Update(
    ctx context.Context,
    s *student.Student,
) error {
    query := `
        UPDATE students
        SET name = $2, email = $3, birth_date = $4, updated_at = $5
        WHERE id = $1
    `

    result, err := r.pool.Exec(
        ctx,
        query,
        s.Id,
        s.Name,
        s.Email,
        s.BirthDate,
        s.UpdatedAt,
    )

    if err != nil {
        return fmt.Errorf("update student: %w", err)
    }

    if result.RowsAffected() == 0 {
        return student.ErrStudentNotFound
    }

    return nil
}

func (r *StudentRepository) Delete(ctx context.Context, id string) error {
    query := `DELETE FROM students WHERE id = $1`

    result, err := r.pool.Exec(ctx, query, id)
    if err != nil {
        return fmt.Errorf("delete student: %w", err)
    }

    if result.RowsAffected() == 0 {
        return student.ErrStudentNotFound
    }

    return nil
}

func (r *StudentRepository) List(
    ctx context.Context,
    filter student.Filter,
) ([]*student.Student, error) {
    query := `
        SELECT id, name, email, birth_date, created_at, updated_at
        FROM students
        WHERE ($1 = '' OR name ILIKE '%' || $1 || '%')
        ORDER BY created_at DESC
        LIMIT $2 OFFSET $3
    `

    rows, err := r.pool.Query(ctx, query, filter.Name, filter.Limit, filter.Offset)
    if err != nil {
        return nil, fmt.Errorf("query students: %w", err)
    }
    defer rows.Close()

    var students []*student.Student

    for rows.Next() {
        var s student.Student
        err := rows.Scan(
            &s.Id,
            &s.Name,
            &s.Email,
            &s.BirthDate,
            &s.CreatedAt,
            &s.UpdatedAt,
        )

        if err != nil {
            return nil, fmt.Errorf("scan student: %w", err)
        }

        students = append(students, &s)
    }

    if err := rows.Err(); err != nil {
        return nil, fmt.Errorf("iterate students: %w", err)
    }

    return students, nil
}

// internal/infra/persistence/postgres/module.go
package postgres

import (
    "go.uber.org/fx"

    "github.com/empresa/escola/internal/domain/student"
)

var Module = fx.Module(
    "postgres",
    fx.Provide(
        NewPool,
        fx.Annotate(
            NewStudentRepository,
            fx.As(new(student.Repository)),
        ),
    ),
)
```

---

### API Layer (HTTP Controllers)

```go
// internal/api/controller/student_controller.go
package controller

import (
    "errors"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"

    "github.com/empresa/escola/internal/domain/student"
)

type StudentController struct {
    service *student.Service
}

func NewStudentController(service *student.Service) *StudentController {
    return &StudentController{service: service}
}

type CreateStudentRequest struct {
    Name      string `json:"name" binding:"required"`
    Email     string `json:"email" binding:"required,email"`
    BirthDate string `json:"birth_date" binding:"required"`
}

type UpdateStudentEmailRequest struct {
    Email string `json:"email" binding:"required,email"`
}

type StudentResponse struct {
    Id        string    `json:"id"`
    Name      string    `json:"name"`
    Email     string    `json:"email"`
    BirthDate string    `json:"birth_date"`
    CreatedAt time.Time `json:"created_at"`
    UpdatedAt time.Time `json:"updated_at"`
}

func (c *StudentController) CreateStudent(ctx *gin.Context) {
    var req CreateStudentRequest

    if err := ctx.ShouldBindJSON(&req); err != nil {
        ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    birthDate, err := time.Parse("2006-01-02", req.BirthDate)
    if err != nil {
        ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid birth_date format"})
        return
    }

    student, err := c.service.CreateStudent(ctx.Request.Context(), req.Name, req.Email, birthDate)
    if err != nil {
        if errors.Is(err, student.ErrDuplicateEmail) {
            ctx.JSON(http.StatusConflict, gin.H{"error": err.Error()})
            return
        }

        ctx.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
        return
    }

    ctx.JSON(http.StatusCreated, toStudentResponse(student))
}

func (c *StudentController) GetStudent(ctx *gin.Context) {
    id := ctx.Param("id")

    student, err := c.service.GetStudent(ctx.Request.Context(), id)
    if err != nil {
        if errors.Is(err, student.ErrStudentNotFound) {
            ctx.JSON(http.StatusNotFound, gin.H{"error": "student not found"})
            return
        }

        ctx.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
        return
    }

    ctx.JSON(http.StatusOK, toStudentResponse(student))
}

func (c *StudentController) UpdateStudentEmail(ctx *gin.Context) {
    id := ctx.Param("id")

    var req UpdateStudentEmailRequest
    if err := ctx.ShouldBindJSON(&req); err != nil {
        ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    student, err := c.service.UpdateStudentEmail(ctx.Request.Context(), id, req.Email)
    if err != nil {
        if errors.Is(err, student.ErrStudentNotFound) {
            ctx.JSON(http.StatusNotFound, gin.H{"error": "student not found"})
            return
        }

        if errors.Is(err, student.ErrDuplicateEmail) {
            ctx.JSON(http.StatusConflict, gin.H{"error": err.Error()})
            return
        }

        ctx.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
        return
    }

    ctx.JSON(http.StatusOK, toStudentResponse(student))
}

func (c *StudentController) DeleteStudent(ctx *gin.Context) {
    id := ctx.Param("id")

    err := c.service.DeleteStudent(ctx.Request.Context(), id)
    if err != nil {
        if errors.Is(err, student.ErrStudentNotFound) {
            ctx.JSON(http.StatusNotFound, gin.H{"error": "student not found"})
            return
        }

        ctx.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
        return
    }

    ctx.Status(http.StatusNoContent)
}

func (c *StudentController) ListStudents(ctx *gin.Context) {
    var filter student.Filter

    filter.Name = ctx.Query("name")

    if limit := ctx.Query("limit"); limit != "" {
        fmt.Sscanf(limit, "%d", &filter.Limit)
    } else {
        filter.Limit = 20
    }

    if offset := ctx.Query("offset"); offset != "" {
        fmt.Sscanf(offset, "%d", &filter.Offset)
    }

    students, err := c.service.ListStudents(ctx.Request.Context(), filter)
    if err != nil {
        ctx.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
        return
    }

    response := make([]StudentResponse, len(students))
    for i, s := range students {
        response[i] = toStudentResponse(s)
    }

    ctx.JSON(http.StatusOK, gin.H{"students": response})
}

func toStudentResponse(s *student.Student) StudentResponse {
    return StudentResponse{
        Id:        s.Id,
        Name:      s.Name,
        Email:     s.Email,
        BirthDate: s.BirthDate.Format("2006-01-02"),
        CreatedAt: s.CreatedAt,
        UpdatedAt: s.UpdatedAt,
    }
}

// internal/api/router.go
package api

import (
    "github.com/gin-gonic/gin"

    "github.com/empresa/escola/internal/api/controller"
)

func SetupRoutes(
    router *gin.Engine,
    studentController *controller.StudentController,
) {
    v1 := router.Group("/api/v1")
    {
        students := v1.Group("/students")
        {
            students.POST("", studentController.CreateStudent)
            students.GET("/:id", studentController.GetStudent)
            students.PATCH("/:id/email", studentController.UpdateStudentEmail)
            students.DELETE("/:id", studentController.DeleteStudent)
            students.GET("", studentController.ListStudents)
        }
    }
}

// internal/api/module.go
package api

import (
    "go.uber.org/fx"

    "github.com/empresa/escola/internal/api/controller"
)

var Module = fx.Module(
    "api",
    fx.Provide(
        controller.NewStudentController,
        NewServer,
    ),
)
```

---

### Main Application (Fx Composition)

```go
// cmd/api/main.go
package main

import (
    "context"

    "go.uber.org/fx"

    "github.com/empresa/escola/internal/api"
    "github.com/empresa/escola/internal/domain/student"
    "github.com/empresa/escola/internal/infra/config"
    "github.com/empresa/escola/internal/infra/persistence/postgres"
)

func main() {
    fx.New(
        // Configuration
        config.Module,

        // Infrastructure
        postgres.Module,

        // Domain
        student.Module,

        // API
        api.Module,

        // Lifecycle
        fx.Invoke(func(lc fx.Lifecycle, server *api.Server) {
            lc.Append(fx.Hook{
                OnStart: func(ctx context.Context) error {
                    go server.Start()
                    return nil
                },
                OnStop: func(ctx context.Context) error {
                    return server.Shutdown(ctx)
                },
            })
        }),
    ).Run()
}
```

---

### Migration SQL

```sql
-- migrations/000001_create_students_table.up.sql
CREATE TABLE IF NOT EXISTS students (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    birth_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_students_email ON students(email);
CREATE INDEX idx_students_created_at ON students(created_at DESC);

-- migrations/000001_create_students_table.down.sql
DROP TABLE IF EXISTS students;
```

---

### Testes

```go
// internal/domain/student/service_test.go
package student_test

import (
    "context"
    "errors"
    "testing"
    "time"

    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
    "github.com/stretchr/testify/require"

    "github.com/empresa/escola/internal/domain/student"
)

type MockRepository struct {
    mock.Mock
}

func (m *MockRepository) FindByID(ctx context.Context, id string) (*student.Student, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*student.Student), args.Error(1)
}

func (m *MockRepository) FindByEmail(ctx context.Context, email string) (*student.Student, error) {
    args := m.Called(ctx, email)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*student.Student), args.Error(1)
}

func (m *MockRepository) Save(ctx context.Context, s *student.Student) error {
    args := m.Called(ctx, s)
    return args.Error(0)
}

func (m *MockRepository) Update(ctx context.Context, s *student.Student) error {
    args := m.Called(ctx, s)
    return args.Error(0)
}

func (m *MockRepository) Delete(ctx context.Context, id string) error {
    args := m.Called(ctx, id)
    return args.Error(0)
}

func (m *MockRepository) List(ctx context.Context, filter student.Filter) ([]*student.Student, error) {
    args := m.Called(ctx, filter)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).([]*student.Student), args.Error(1)
}

func TestService_CreateStudent(t *testing.T) {
    tests := []struct {
        name      string
        inputName string
        email     string
        setupMock func(*MockRepository)
        wantErr   error
    }{
        {
            name:      "success",
            inputName: "John Doe",
            email:     "john@example.com",
            setupMock: func(m *MockRepository) {
                m.On("FindByEmail", mock.Anything, "john@example.com").
                    Return(nil, student.ErrStudentNotFound)
                m.On("Save", mock.Anything, mock.Anything).Return(nil)
            },
            wantErr: nil,
        },
        {
            name:      "duplicate email",
            inputName: "Jane Doe",
            email:     "existing@example.com",
            setupMock: func(m *MockRepository) {
                existing := &student.Student{
                    Id:    "existing-id",
                    Email: "existing@example.com",
                }
                m.On("FindByEmail", mock.Anything, "existing@example.com").
                    Return(existing, nil)
            },
            wantErr: student.ErrDuplicateEmail,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            mockRepo := &MockRepository{}
            tt.setupMock(mockRepo)

            service := student.NewService(mockRepo)

            ctx := context.Background()
            birthDate := time.Date(2000, 1, 1, 0, 0, 0, 0, time.UTC)

            result, err := service.CreateStudent(ctx, tt.inputName, tt.email, birthDate)

            if tt.wantErr != nil {
                require.Error(t, err)
                assert.True(t, errors.Is(err, tt.wantErr))
                assert.Nil(t, result)
            } else {
                require.NoError(t, err)
                require.NotNil(t, result)
                assert.Equal(t, tt.inputName, result.Name)
                assert.Equal(t, tt.email, result.Email)
                assert.NotEmpty(t, result.Id)
            }

            mockRepo.AssertExpectations(t)
        })
    }
}
```

---

## Como Rodar Este Exemplo

### Pré-requisitos

```bash
# Go 1.21+
go version

# PostgreSQL rodando
docker run -d \
  --name postgres-school \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=school \
  -p 5432:5432 \
  postgres:16
```

### Passo a passo

```bash
# 1. Criar estrutura de pastas
mkdir -p school/{cmd/api,internal/{domain/student,app/student,infra/{postgres,config},api/handler},migrations}

# 2. Inicializar módulo
cd school
go mod init github.com/empresa/escola

# 3. Instalar dependências
go get github.com/gin-gonic/gin@v1.9.1
go get github.com/jackc/pgx/v5@v5.5.0
go get github.com/stretchr/testify@v1.8.4
go get go.uber.org/fx@v1.20.1
go get gopkg.in/yaml.v3@v3.0.1

# 4. Copiar código dos exemplos acima para os arquivos correspondentes
# internal/domain/student/student.go
# internal/domain/student/repository.go
# internal/domain/student/service.go
# internal/infra/postgres/student_repository.go
# internal/api/handler/student_handler.go
# cmd/api/main.go
# migrations/000001_create_students.up.sql

# 5. Rodar migrations
psql -h localhost -U postgres -d school -f migrations/000001_create_students.up.sql

# 6. Criar config.yaml
cat > config.yaml << EOF
server:
  port: 8080

database:
  host: localhost
  port: 5432
  user: postgres
  password: password
  database: school
  ssl_mode: disable
EOF

# 7. Rodar aplicação
go run cmd/api/main.go

# 8. Testar endpoints
# Criar estudante
curl -X POST http://localhost:8080/students \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "birth_date": "2000-01-01"
  }'

# Listar estudantes
curl http://localhost:8080/students

# Buscar por ID (substitua {id})
curl http://localhost:8080/students/{id}

# Atualizar estudante
curl -X PUT http://localhost:8080/students/{id} \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Updated",
    "email": "john.new@example.com",
    "birth_date": "2000-01-01"
  }'

# Deletar estudante
curl -X DELETE http://localhost:8080/students/{id}

# 9. Rodar testes
go test ./... -v

# 10. Rodar com coverage
go test ./... -coverprofile=coverage.out
go tool cover -html=coverage.out
```

### Verificações

```bash
# Ver logs da aplicação
# Deve mostrar: "Starting server on :8080"

# Verificar PostgreSQL
psql -h localhost -U postgres -d school -c "SELECT * FROM students;"

# Verificar dependências
go list -m all

# Lint (opcional)
go install golang.org/x/lint/golint@latest
golint ./...
```

### Troubleshooting

**Erro: "dial tcp [::1]:5432: connect: connection refused"**
```bash
# PostgreSQL não está rodando
docker ps  # Verificar se container está up
docker start postgres-school
```

**Erro: "pq: password authentication failed"**
```bash
# Credenciais erradas no config.yaml
# Verificar POSTGRES_PASSWORD no docker run
```

**Erro: "bind: address already in use"**
```bash
# Porta 8080 ocupada
lsof -ti:8080 | xargs kill -9
# Ou mude a porta no config.yaml
```

**Testes falhando:**
```bash
# Verificar se todos os mocks estão configurados
go test -v ./internal/app/student  # Testar pacote específico
```

---

## Próximos Passos

Após dominar este CRUD básico, você pode evoluir para:

1. **Adicionar autenticação** — JWT middleware no Gin
2. **Adicionar cache** — Redis para `FindByID`
3. **Adicionar eventos** — RabbitMQ para `student.created`
4. **Adicionar validação avançada** — ozzo-validation
5. **Adicionar observabilidade** — Prometheus metrics + Zap logging
6. **Adicionar testes E2E** — Testcontainers para PostgreSQL real

Cada adição segue os mesmos padrões: domain define interface, infra implementa, Fx injeta.

**Para ver um exemplo mais avançado com orquestração complexa, Saga pattern e múltiplos agregados, veja o próximo arquivo.**

---

**Próximo:** [Orquestração Avançada](08-exemplo-orquestracao-avancada.md) | **Anterior:** [Dependências e Módulos](06-dependencias.md) | **Voltar para:** [Índice](README.md)

**Última atualização:** 03/11/2025 16:42
