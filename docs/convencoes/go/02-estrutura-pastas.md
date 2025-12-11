# Estrutura de Pastas em Go

> **"Estrutura de pastas não é organização — é controle de acoplamento."**

Pastas em Go não são apenas agrupamento visual. São **barreiras de acesso**. O compilador usa a estrutura de diretórios para decidir o que você pode ou não importar.

- `internal/` → Ninguém de fora pode importar
- `pkg/` → Qualquer projeto pode reutilizar
- `cmd/` → Pontos de entrada executáveis

Não existe "padrão oficial" de estrutura. O que existe é **convenção da comunidade** baseada em projetos reais (Kubernetes, Docker, Prometheus). Se você ignorá-la, vai confundir todo desenvolvedor Go que tocar no seu código.

Este guia não é sobre "o jeito certo". É sobre **decisões com consequências técnicas claras**.

---

## Por que estrutura importa em Go?

1. **`internal/` é fiscalizado pelo compilador** — Código fora do módulo não consegue importar nada de lá
2. **Não existe namespace de classes** — Você precisa usar packages para separar responsabilidades
3. **Import cycles quebram compilação** — Estrutura ruim = refatoração impossível
4. **`cmd/` define binários** — Cada subpasta vira um executável separado
5. **Visibilidade é por package** — Arquivos na mesma pasta veem tudo uns dos outros (público ou privado)

**Trade-off crítico:** Quanto mais pastas você cria, mais explícito fica o acoplamento. Quanto menos pastas, mais fácil criar dependências circulares acidentais.

---

## Layout Padrão de Projeto

**Regra:** Seguir o layout padrão da comunidade Go com adaptações para Clean Architecture tática.

```
escola/
├── cmd/                    # 🔴 FUNDAMENTAL - Binários executáveis
│   ├── api/
│   │   └── main.go
│   ├── worker/
│   │   └── main.go
│   └── migrator/
│       └── main.go
│
├── internal/               # 🔴 FUNDAMENTAL - Código privado da aplicação
│   ├── domain/            # Lógica de negócio pura (SEM dependências externas)
│   ├── app/               # Coordenadores/orquestradores (NÃO use cases puros)
│   ├── infra/             # Implementações de infraestrutura
│   ├── api/               # HTTP handlers, controllers
│   └── shared/            # Código compartilhado entre camadas
│
├── pkg/                    # 🟡 SITUACIONAL - Código reutilizável por outros projetos
│   ├── logger/
│   └── validator/
│
├── migrations/             # 🟡 SITUACIONAL - Migrations de banco de dados
│   ├── 000001_create_students.up.sql
│   └── 000001_create_students.down.sql
│
├── config/                 # 🟡 SITUACIONAL - Arquivos de configuração (.yaml)
│   ├── config.yaml
│   └── config.example.yaml
│
├── docker/                 # 🟡 SITUACIONAL - Dockerfiles
│   ├── Dockerfile.api
│   └── Dockerfile.worker
│
├── go.mod                  # 🔴 FUNDAMENTAL - Dependências
├── go.sum                  # 🔴 FUNDAMENTAL - Checksums
├── Makefile                # 🟡 SITUACIONAL - Comandos úteis
├── README.md               # 🔴 FUNDAMENTAL - Documentação
└── docker-compose.yaml     # 🟡 SITUACIONAL - Ambiente local
```

**Legenda:**
- 🔴 **FUNDAMENTAL** - Deve existir em todo projeto
- 🟡 **SITUACIONAL** - Criar apenas quando necessário

**Referências:**
- 🔗 [Go Project Layout](https://github.com/golang-standards/project-layout) - Layout padrão da comunidade

---

## Estrutura Internal: Clean Architecture + DDD Tático

> ⚠️ **Importante:** Utilizamos uma abordagem **TÁTICA** de Clean Architecture combinada com DDD (Domain-Driven Design). Não é purismo dogmático. O objetivo é separação de responsabilidades pragmática que facilite manutenção, testes e evolução do código.

### Por que essa estrutura existe?

**Problemas que ela resolve:**

1. **"Não sei onde colocar este código"** → Cada camada tem responsabilidade clara
2. **"Mudou o banco, quebrou tudo"** → Infraestrutura isolada por interfaces
3. **"Testes são lentos demais"** → Domain sem dependências = testes rápidos
4. **"Features novas sempre quebram código antigo"** → Vertical slicing reduz acoplamento
5. **"Time novo não entende nada"** → Estrutura padronizada = onboarding previsível

**Trade-offs:**

| Vantagem | Desvantagem |
|----------|-------------|
| ✅ Testabilidade alta (domain isolado) | ❌ Mais arquivos/pastas inicialmente |
| ✅ Flexibilidade (trocar infra é trivial) | ❌ Curva de aprendizado para juniors |
| ✅ Escalabilidade de time (menos conflitos) | ❌ Over-engineering para apps CRUD simples |
| ✅ Evolução sem quebrar legacy | ❌ Requer disciplina para manter limites |

**Quando usar essa estrutura:**
- ✅ Projetos com 3+ desenvolvedores
- ✅ Aplicações que viverão 6+ meses
- ✅ Domínio de negócio complexo (múltiplas regras)
- ✅ Necessidade de trocar infraestrutura (ex: migrar DB)

**Quando NÃO usar:**
- ❌ CRUD simples com 1 dev (overkill)
- ❌ Protótipos descartáveis
- ❌ Scripts internos de automação

### As 4 Camadas: Responsabilidades Detalhadas

#### 🎯 Domain (`internal/domain/`)

**O que é:**  
Regras de negócio **puras**. Entidades, value objects, interfaces de repositórios, serviços de domínio. **Zero dependências externas** — nem database, nem HTTP, nem frameworks.

**Pense assim:**  
*"Se eu reescrever este sistema em Java/Python/Rust, este código ainda faria sentido?"*

**O que vai aqui:**
- ✅ Entidades (structs com comportamento)
- ✅ Value Objects (tipos customizados com validação)
- ✅ Interfaces de repositórios (contratos, não implementações)
- ✅ Serviços de domínio (lógica que não pertence a uma entidade)
- ✅ Erros de domínio (`ErrAlunoNaoEncontrado`, `ErrMatriculaDuplicada`)

**O que NÃO vai aqui:**
- ❌ SQL queries
- ❌ HTTP handlers
- ❌ Chamadas a APIs externas
- ❌ Imports de `database/sql`, `net/http`, `github.com/gin-gonic/gin`

**Exemplo escolar concreto:**

```go
// internal/domain/aluno/aluno.go
package aluno

import (
    "errors"
    "time"
)

// Entidade com comportamento
type Aluno struct {
    Id              string
    Nome            string
    Email           Email  // Value Object
    DataNascimento  time.Time
    Matriculas      []string  // IDs de matrículas
}

// Regra de negócio: aluno só pode ter até 7 matrículas simultâneas
func (a *Aluno) PodeMatricular() bool {
    return len(a.Matriculas) < 7
}

// Regra de negócio: aluno precisa ter 18+ anos
func (a *Aluno) EhMaiorIdade() bool {
    return time.Since(a.DataNascimento).Hours() > 18*365*24
}

// Value Object com validação
type Email string

func NovoEmail(valor string) (Email, error) {
    if !strings.Contains(valor, "@") {
        return "", errors.New("email inválido")
    }
    return Email(valor), nil
}

// Interface de repositório (contrato, não implementação)
type Repositorio interface {
    Salvar(ctx context.Context, aluno *Aluno) error
    BuscarPorID(ctx context.Context, id string) (*Aluno, error)
    BuscarPorEmail(ctx context.Context, email Email) (*Aluno, error)
}

// Serviço de domínio (lógica que não pertence a uma entidade)
type Servico struct {
    repo Repositorio
}

func NovoServico(repo Repositorio) *Servico {
    return &Servico{repo: repo}
}

// Orquestra lógica de múltiplas entidades
func (s *Servico) ValidarMatricula(ctx context.Context, alunoId, disciplinaId string) error {
    aluno, err := s.repo.BuscarPorID(ctx, alunoId)
    if err != nil {
        return err
    }

    if !aluno.PodeMatricular() {
        return errors.New("aluno já possui 7 matrículas")
    }

    if !aluno.EhMaiorIdade() {
        return errors.New("aluno precisa ter 18+ anos")
    }

    return nil
}
```

**Referências:**
- 📚 Eric Evans - Domain-Driven Design (Cap. 5: Model-Driven Design)
- 📚 Vaughn Vernon - Implementing Domain-Driven Design (Cap. 5-8: Entities, Value Objects, Services)
- 🔗 [Domain Layer - Martin Fowler](https://martinfowler.com/eaaCatalog/domainModel.html)

---

#### 🔄 App (`internal/app/`)

**O que é:**  
Orquestradores de **casos de uso**. Coordenam múltiplos domain services, repositories, e infraestrutura (email, fila, cache) para completar uma ação do usuário.

**Pense assim:**  
*"Este código conecta vários domain services para completar um fluxo de negócio completo."*

**Diferença crítica:** Domain tem regras isoladas. App **orquestra** essas regras + efeitos colaterais (salvar DB, enviar email, publicar evento).

**O que vai aqui:**
- ✅ Casos de uso (ex: `ProcessadorInscricao`, `DespachadorNotificacao`)
- ✅ Orquestração de transações (iniciar, commit, rollback)
- ✅ Coordenação de eventos (publicar mensagem na fila)
- ✅ Interação com múltiplos agregados de domínio

**O que NÃO vai aqui:**
- ❌ Regras de negócio (isso é domain)
- ❌ Queries SQL (isso é infra)
- ❌ Validação de JSON (isso é API)

**Exemplo escolar concreto:**

```go
// internal/app/inscricao/processador.go
package inscricao

import (
    "context"
    "fmt"

    "github.com/empresa/escola/internal/domain/aluno"
    "github.com/empresa/escola/internal/domain/matricula"
    "github.com/empresa/escola/internal/infra/email"
    "github.com/empresa/escola/internal/infra/mensageria"
)

// Processador orquestra TODO o fluxo de matrícula
type Processador struct {
    alunoRepo      aluno.Repositorio
    matriculaRepo  matricula.Repositorio
    emailProvider  email.Provedor
    eventPublisher mensageria.Publicador
}

func NovoProcessador(
    alunoRepo aluno.Repositorio,
    matriculaRepo matricula.Repositorio,
    emailProvider email.Provedor,
    eventPublisher mensageria.Publicador,
) *Processador {
    return &Processador{
        alunoRepo:      alunoRepo,
        matriculaRepo:  matriculaRepo,
        emailProvider:  emailProvider,
        eventPublisher: eventPublisher,
    }
}

// ProcessarInscricao orquestra: validar → salvar → notificar → publicar evento
func (p *Processador) ProcessarInscricao(ctx context.Context, alunoId, disciplinaId string) error {
    // 1. Buscar aluno (domain)
    aluno, err := p.alunoRepo.BuscarPorID(ctx, alunoId)
    if err != nil {
        return fmt.Errorf("buscar aluno: %w", err)
    }

    // 2. Validar regra de negócio (domain)
    if !aluno.PodeMatricular() {
        return fmt.Errorf("aluno já possui 7 matrículas")
    }

    // 3. Criar matrícula (domain)
    mat := matricula.Nova(alunoId, disciplinaId)

    // 4. Persistir (infra)
    if err := p.matriculaRepo.Salvar(ctx, mat); err != nil {
        return fmt.Errorf("salvar matrícula: %w", err)
    }

    // 5. Enviar email de confirmação (infra)
    if err := p.emailProvider.Enviar(ctx, email.Mensagem{
        Para:     string(aluno.Email),
        Assunto:  "Matrícula confirmada",
        Conteudo: fmt.Sprintf("Você foi matriculado em %s", disciplinaId),
    }); err != nil {
        // Log, mas não falha (email é side effect)
        fmt.Printf("erro ao enviar email: %v\n", err)
    }

    // 6. Publicar evento (infra - mensageria)
    evento := mensageria.Evento{
        Tipo:    "matricula.criada",
        Payload: map[string]string{"alunoId": alunoId, "disciplinaId": disciplinaId},
    }
    if err := p.eventPublisher.Publicar(ctx, evento); err != nil {
        return fmt.Errorf("publicar evento: %w", err)
    }

    return nil
}
```

**Por que Application existe separado de Domain?**

Sem camada Application, você teria duas opções ruins:

1. **Colocar orquestração no Domain** → Domain fica acoplado a infra (email, fila)
2. **Colocar orquestração na API** → Controllers ficam gigantes, lógica duplicada

Application é o **ponto de entrada para casos de uso**, mantendo Domain puro e API fina.

**Referências:**
- 📚 Robert C. Martin - Clean Architecture (Cap. 20: Business Rules)
- 📚 Vaughn Vernon - Implementing Domain-Driven Design (Cap. 14: Application Services)
- 🔗 [Application Layer - DDD Reference](https://domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf)

---

#### 🔌 Infra (`internal/infra/`)

**O que é:**  
**Implementações** de interfaces definidas no Domain. Database, cache, APIs externas, email, filas, config. Tudo que fala com o mundo externo.

**Pense assim:**  
*"Se eu trocar PostgreSQL por MongoDB, apenas esta pasta muda. Domain e App não sabem de nada."*

**O que vai aqui:**
- ✅ Implementações de repositórios (PostgreSQL, MongoDB, Redis)
- ✅ Provedores de email (Sendgrid, Mailgun, SMTP)
- ✅ Clientes de APIs externas (pagamento, CEP, autenticação)
- ✅ Mensageria (RabbitMQ, Kafka, SQS)
- ✅ Configuração (carregar YAML, env vars)

**O que NÃO vai aqui:**
- ❌ Regras de negócio (isso é domain)
- ❌ Orquestração de casos de uso (isso é app)
- ❌ Validação de entrada HTTP (isso é API)

**Exemplo escolar concreto:**

```go
// internal/infra/persistencia/postgres/aluno_repositorio.go
package postgres

import (
    "context"
    "errors"

    "github.com/jackc/pgx/v5"
    "github.com/jackc/pgx/v5/pgxpool"

    "github.com/empresa/escola/internal/domain/aluno"
)

// Implementa interface aluno.Repositorio
type RepositorioAluno struct {
    pool *pgxpool.Pool
}

func NovoRepositorioAluno(pool *pgxpool.Pool) *RepositorioAluno {
    return &RepositorioAluno{pool: pool}
}

func (r *RepositorioAluno) Salvar(ctx context.Context, a *aluno.Aluno) error {
    query := `
        INSERT INTO alunos (id, nome, email, data_nascimento)
        VALUES ($1, $2, $3, $4)
        ON CONFLICT (id) DO UPDATE SET
            nome = EXCLUDED.nome,
            email = EXCLUDED.email
    `
    _, err := r.pool.Exec(ctx, query, a.Id, a.Nome, a.Email, a.DataNascimento)
    return err
}

func (r *RepositorioAluno) BuscarPorID(ctx context.Context, id string) (*aluno.Aluno, error) {
    query := `SELECT id, nome, email, data_nascimento FROM alunos WHERE id = $1`
    
    var a aluno.Aluno
    err := r.pool.QueryRow(ctx, query, id).Scan(&a.Id, &a.Nome, &a.Email, &a.DataNascimento)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, aluno.ErrAlunoNaoEncontrado
        }
        return nil, err
    }

    return &a, nil
}

func (r *RepositorioAluno) BuscarPorEmail(ctx context.Context, email aluno.Email) (*aluno.Aluno, error) {
    query := `SELECT id, nome, email, data_nascimento FROM alunos WHERE email = $1`
    
    var a aluno.Aluno
    err := r.pool.QueryRow(ctx, query, email).Scan(&a.Id, &a.Nome, &a.Email, &a.DataNascimento)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, aluno.ErrAlunoNaoEncontrado
        }
        return nil, err
    }

    return &a, nil
}
```

**Exemplo: Provedor de Email**

```go
// internal/infra/email/sendgrid/provedor.go
package sendgrid

import (
    "context"
    "fmt"

    "github.com/sendgrid/sendgrid-go"
    "github.com/sendgrid/sendgrid-go/helpers/mail"

    "github.com/empresa/escola/internal/infra/email"
)

type Provedor struct {
    client *sendgrid.Client
    from   string
}

func NovoProvedor(apiKey, from string) *Provedor {
    return &Provedor{
        client: sendgrid.NewSendClient(apiKey),
        from:   from,
    }
}

func (p *Provedor) Enviar(ctx context.Context, msg email.Mensagem) error {
    message := mail.NewSingleEmail(
        mail.NewEmail("Escola", p.from),
        msg.Assunto,
        mail.NewEmail("", msg.Para),
        msg.Conteudo,
        msg.Conteudo,
    )

    response, err := p.client.Send(message)
    if err != nil {
        return fmt.Errorf("sendgrid: %w", err)
    }

    if response.StatusCode >= 400 {
        return fmt.Errorf("sendgrid retornou %d", response.StatusCode)
    }

    return nil
}
```

**Referências:**
- 📚 Robert C. Martin - Clean Architecture (Cap. 24: Frameworks and Drivers)
- 📚 Vaughn Vernon - Implementing Domain-Driven Design (Cap. 12: Repositories)

---

#### 📡 API (`internal/api/`)

**O que é:**  
Camada de **transporte**. Recebe requisições HTTP/gRPC, valida entrada, converte DTOs, chama Application services, retorna resposta.

**Pense assim:**  
*"Recebo JSON do mundo externo, valido formato, chamo o caso de uso correto, retorno HTTP status code adequado."*

**O que vai aqui:**
- ✅ Handlers HTTP (Gin, Echo, Chi)
- ✅ Middlewares (auth, logging, CORS)
- ✅ DTOs (Data Transfer Objects - structs para JSON)
- ✅ Validação de entrada (formato, campos obrigatórios)
- ✅ Conversão DTO → Domain Entity

**O que NÃO vai aqui:**
- ❌ Regras de negócio (isso é domain)
- ❌ Orquestração complexa (isso é app)
- ❌ Queries SQL (isso é infra)

**Exemplo escolar concreto:**

```go
// internal/api/handler/aluno_handler.go
package handler

import (
    "net/http"

    "github.com/gin-gonic/gin"

    "github.com/empresa/escola/internal/app/inscricao"
    "github.com/empresa/escola/internal/domain/aluno"
)

type AlunoHandler struct {
    processador *inscricao.Processador
}

func NovoAlunoHandler(processador *inscricao.Processador) *AlunoHandler {
    return &AlunoHandler{processador: processador}
}

// DTO de entrada
type CriarAlunoRequest struct {
    Nome           string `json:"nome" binding:"required"`
    Email          string `json:"email" binding:"required,email"`
    DataNascimento string `json:"data_nascimento" binding:"required"`
}

// POST /alunos
func (h *AlunoHandler) Criar(c *gin.Context) {
    var req CriarAlunoRequest
    
    // Validar JSON
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"erro": err.Error()})
        return
    }

    // Converter DTO → Domain Entity
    email, err := aluno.NovoEmail(req.Email)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"erro": "email inválido"})
        return
    }

    dataNasc, err := time.Parse("2006-01-02", req.DataNascimento)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"erro": "data inválida"})
        return
    }

    novoAluno := &aluno.Aluno{
        Id:             gerarID(),
        Nome:           req.Nome,
        Email:          email,
        DataNascimento: dataNasc,
    }

    // Chamar Application Service
    if err := h.processador.ProcessarInscricao(c.Request.Context(), novoAluno.Id, ""); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"erro": err.Error()})
        return
    }

    // Retornar resposta
    c.JSON(http.StatusCreated, gin.H{
        "id":    novoAluno.Id,
        "nome":  novoAluno.Nome,
        "email": novoAluno.Email,
    })
}
```

**Referências:**
- 🔗 [Presentation Layer - Martin Fowler](https://martinfowler.com/eaaCatalog/applicationController.html)

---

### Fluxo Completo: Request → Response

**Cenário:** Usuário cria matrícula via POST `/matriculas`

```
1. HTTP Request chega
   ↓
2. API Layer (internal/api/)
   - Valida JSON
   - Converte DTO → Domain Entity
   - Chama Application Service
   ↓
3. Application Layer (internal/app/)
   - Orquestra caso de uso
   - Chama Domain Service para validar regras
   - Persiste via Repository (interface)
   - Envia email via Provedor (interface)
   - Publica evento via Mensageria (interface)
   ↓
4. Domain Layer (internal/domain/)
   - Executa regra: aluno.PodeMatricular()
   - Retorna erro se inválido
   ↓
5. Infrastructure Layer (internal/infra/)
   - Repository salva no PostgreSQL
   - Provedor envia email via Sendgrid
   - Mensageria publica no RabbitMQ
   ↓
6. Application retorna sucesso/erro
   ↓
7. API Layer retorna HTTP 201 ou 400/500
```

**Diagrama de dependências:**

```
┌─────────────────────────────────────────┐
│              API Layer                  │
│         (HTTP Handlers)                 │
└────────────────┬────────────────────────┘
                 │ chama
                 ▼
┌─────────────────────────────────────────┐
│         Application Layer               │
│      (Casos de Uso / Orquestradores)    │
└────┬────────────────────────────────┬───┘
     │ usa                            │ usa
     ▼                                ▼
┌────────────────────┐    ┌──────────────────────┐
│   Domain Layer     │    │  Infrastructure      │
│ (Regras Negócio)   │    │  (DB, Email, Queue)  │
└────────────────────┘    └──────────────────────┘
     ▲                                │
     │ define interfaces              │
     └────────────────────────────────┘
              implementa
```

**Referências completas:**
- 📚 Robert C. Martin - Clean Architecture (2017)
- 📚 Eric Evans - Domain-Driven Design (2003) - Cap. 5-11: Tactical DDD
- 📚 Vaughn Vernon - Implementing Domain-Driven Design (2013)
- 🔗 [Applying Clean Architecture to Go](https://manuel.kiessling.net/2012/09/28/applying-the-clean-architecture-to-go-applications/)
- 🔗 [Domain Layer - Martin Fowler](https://martinfowler.com/eaaCatalog/domainModel.html)
- 🔗 [DDD Reference - Eric Evans](https://domainlanguage.com/wp-content/uploads/2016/05/DDD_Reference_2015-03.pdf)

---

## Regra de Dependências

**Fluxo de dependências (Clean Architecture Tática):**

```
API → Application → Domain
         ↓
   Infrastructure
```

**Regras:**
1. ✅ **Domain não depende de ninguém** (zero imports externos, zero dependências de infra/app)
2. ✅ **Application** depende apenas de **Domain** (orquestra casos de uso)
3. ✅ **Infrastructure** implementa interfaces de **Domain** (plugável)
4. ✅ **API** depende de **Application** e **Domain** (não de Infrastructure diretamente)

#### ✅ Recomendado
```go
// internal/domain/aluno/repositorio.go
package aluno

import "context"

// Interface NO domínio (sem dependência de infra)
type Repositorio interface {
    Salvar(contexto context.Context, aluno *Aluno) error
    BuscarPorID(contexto context.Context, id string) (*Aluno, error)
}

// internal/infra/persistencia/postgres/aluno_repositorio.go
package postgres

import (
    "context"

    "github.com/jackc/pgx/v5/pgxpool"

    "github.com/empresa/escola/internal/domain/aluno"
)

type RepositorioAluno struct {
    pool *pgxpool.Pool
}

// Implementa interface de domínio
func (r *RepositorioAluno) Salvar(contexto context.Context, a *aluno.Aluno) error {
    // Implementação PostgreSQL
}

func (r *RepositorioAluno) BuscarPorID(contexto context.Context, id string) (*aluno.Aluno, error) {
    // Implementação PostgreSQL
}
```

#### ❌ NÃO FAÇA
```go
// internal/domain/aluno/aluno.go
package aluno

import "github.com/jackc/pgx/v5"  // ❌ Domínio importando infra

type Aluno struct {
    Id   pgx.UUID  // ❌ Tipo de infra no domínio
    Nome string
}
```

---

## Organização de Pacotes por Feature (Vertical Slicing)

**Princípio:** Agrupar por funcionalidade/domínio, não por tipo técnico.

#### ❌ NÃO FAÇA - Organização por tipo técnico (horizontal)
```
internal/
├── models/           # ❌ Todos os models juntos
│   ├── aluno.go
│   ├── disciplina.go
│   └── matricula.go
├── repositories/     # ❌ Todos os repositories juntos
│   ├── aluno_repo.go
│   ├── disciplina_repo.go
│   └── matricula_repo.go
└── services/         # ❌ Todos os services juntos
    ├── aluno_service.go
    ├── disciplina_service.go
    └── matricula_service.go
```

**Problema:** 
- Dificulta encontrar tudo relacionado a uma feature
- Alto acoplamento entre features não relacionadas
- Dificuldade para extrair módulos independentes

#### ✅ Recomendado - Organização por feature (vertical)
```
internal/domain/
├── aluno/              # ✅ Tudo de Aluno junto
│   ├── aluno.go
│   ├── repositorio.go
│   ├── servico.go
│   └── erros.go
├── disciplina/         # ✅ Tudo de Disciplina junto
│   ├── disciplina.go
│   ├── repositorio.go
│   └── servico.go
└── matricula/          # ✅ Tudo de Matrícula junto
    ├── matricula.go
    ├── repositorio.go
    └── servico.go
```

**Vantagens:**
- Cohesão: tudo relacionado está próximo
- Baixo acoplamento: features independentes
- Fácil de extrair para microserviços

---

## Quando Criar Subpastas (Significado Semântico)

> ⚠️ **Importante:** Pacotes em Go têm significado semântico. Não crie pastas/pacotes genéricos (`types`, `utils`, `helpers`). Cada pacote deve ter **responsabilidade clara e específica**.

**Por que isso importa?** Em Go, o nome do pacote é parte da API pública. Quando você escreve `aluno.Repositorio`, o nome `aluno` já transmite contexto. Pacotes genéricos como `types.Aluno` ou `models.Student` desperdiçam esse espaço semântico — você teria `models.Student` ao invés de simplesmente `student.Student`.

**Regra:** Criar subpasta apenas quando houver **múltiplas implementações de uma interface** ou **agregação semântica clara**.

**Como pensar:** Pergunte-se:
1. "Este arquivo tem propósito único e claro?" → Mantenha no pacote raiz
2. "Tenho 3+ implementações diferentes desta interface?" → Considere subpastas
3. "Esta subpasta teria apenas 1 arquivo?" → Não crie

**Exemplo do mundo escolar:**
- `internal/domain/student/` → Tudo relacionado ao conceito "estudante"
  - `student.go` → Entidade Student
  - `repository.go` → Interface do repositório
  - `service.go` → Lógica de orquestração

Não crie `internal/domain/student/types/student.go` — o pacote `student` já indica que é sobre estudantes!

#### ⚠️ Evitar - Pastas desnecessárias
```
domain/aluno/
├── types/
│   └── aluno.go        # ❌ Apenas 1 arquivo, subpasta desnecessária
├── errors/
│   └── erros.go        # ❌ Apenas 1 arquivo
└── validators/
    └── validador.go    # ❌ Apenas 1 arquivo
```

#### ✅ Recomendado - Estrutura enxuta
```
domain/aluno/
├── aluno.go            # Entidade + value objects
├── repositorio.go      # Interface
├── servico.go          # Serviço de domínio
└── erros.go            # Erros de domínio
```

**Exceção:** Criar subpasta quando há **3+ implementações/arquivos relacionados**

```
infra/email/
├── provedor.go         # Interface
├── sendgrid/           # ✅ Subpasta justificada (implementação completa)
│   ├── provedor.go
│   ├── cliente.go
│   └── mapeamento.go
├── mailgun/            # ✅ Subpasta justificada (implementação completa)
│   ├── provedor.go
│   └── cliente.go
└── mailhog/            # ✅ Subpasta justificada (teste/dev)
    └── provedor.go
```

**Regra adicional:** **Não duplicar nomes de pacotes** mesmo que tecnicamente possível.

```
// ❌ EVITAR - Pacotes com mesmo nome em locais diferentes
internal/domain/aluno/repositorio.go     // package aluno
internal/infra/repositorio/aluno.go      // package repositorio

// Causa confusão nos imports:
import (
    "projeto/internal/domain/aluno"
    "projeto/internal/infra/repositorio"  // Qual aluno? Qual repositorio?
)

// ✅ MELHOR - Nomes únicos e semânticos
internal/domain/aluno/repositorio.go           // package aluno
internal/infra/persistencia/postgres/aluno.go  // package postgres
```

---

## Estrutura de cmd/ (Binários)

**Regra:** Cada binário em sua própria pasta, `main.go` mínimo (apenas composição).

#### ✅ Recomendado
```
cmd/
├── api/
│   └── main.go        # HTTP server
├── worker/
│   └── main.go        # Background worker
└── migrator/
    └── main.go        # Database migrations
```

**`main.go` deve apenas:**
1. Carregar configuração
2. Compor dependências (DI com Fx)
3. Iniciar servidor/worker

```go
// cmd/api/main.go
package main

import (
    "go.uber.org/fx"

    "github.com/empresa/escola/internal/api"
    "github.com/empresa/escola/internal/app/inscricao"
    "github.com/empresa/escola/internal/domain/aluno"
    "github.com/empresa/escola/internal/infra/config"
    "github.com/empresa/escola/internal/infra/persistencia/postgres"
)

func main() {
    fx.New(
        // Config
        config.Module,

        // Infrastructure
        postgres.Module,

        // Domain
        aluno.Module,

        // Application
        inscricao.Module,

        // API
        api.Module,

        // Start server
        fx.Invoke(api.Start),
    ).Run()
}
```

#### ❌ NÃO FAÇA - Lógica no main.go
```go
// cmd/api/main.go
func main() {
    // ❌ Lógica de negócio no main
    db, err := sql.Open("postgres", "connection-string")
    if err != nil {
        panic(err)
    }

    alunoRepo := postgres.NewAlunoRepo(db)
    alunoService := aluno.NewService(alunoRepo)
    alunoHandler := handler.NewAlunoHandler(alunoService)

    router := gin.Default()
    router.POST("/alunos", alunoHandler.Criar)
    router.Run(":8080")
}
```

---

## Organização de Testes

**Regra:** Testes no mesmo pacote com sufixo `_test.go`.

```
domain/aluno/
├── aluno.go
├── aluno_test.go           # Testes unitários
├── repositorio.go
├── repositorio_test.go
├── servico.go
└── servico_test.go
```

**Testes de integração e E2E:**
```
tests/
├── integration/
│   ├── aluno_test.go
│   └── matricula_test.go
└── e2e/
    ├── api_test.go
    └── workflow_test.go
```

**Build tags para separar tipos de teste:**
```go
// tests/integration/aluno_test.go
//go:build integration

package integration

import "testing"

func TestAlunoRepositorio_Integration(t *testing.T) {
    // Requer DB real
}
```

**Rodar:**
```bash
go test ./...                    # Apenas testes unitários
go test -tags=integration ./...  # Inclui testes de integração
```

**Referência:**
- 🔗 [Go Testing](https://go.dev/doc/tutorial/add-a-test) - Documentação oficial

---



---

**Próximo:** [Organização de Código](03-organizacao-codigo.md) | **Anterior:** [Nomenclatura](01-nomenclatura.md) | **Voltar para:** [Índice](README.md)

**Última atualização:** 03/11/2025 16:42
