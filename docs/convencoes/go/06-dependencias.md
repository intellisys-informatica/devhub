# Dependências e Módulos

> **"Go modules resolveu o inferno de dependências que era GOPATH."**

Antes de Go 1.11 (2018), gerenciar dependências era caótico: GOPATH obrigatório, sem versionamento, `vendor/` manual, ferramentas de terceiros (dep, glide) competindo. Go modules mudou tudo.

Agora você tem:
- **go.mod** → Manifesto declarativo (como package.json, requirements.txt)
- **go.sum** → Lockfile criptográfico (garante builds reproduzíveis)
- **Versionamento semântico obrigatório** → v1.2.3 segue SemVer
- **Minimal Version Selection** → Go escolhe a **menor** versão que satisfaz todos os requisitos (não a maior como npm/pip)

## Por que gerenciamento de dependências importa?

1. **Builds reproduzíveis** — `go.sum` garante que CI/prod usam exatamente as mesmas versões
2. **Segurança** — `go.sum` detecta dependências adulteradas (checksums não batem = falha)
3. **Atualizações controladas** — `go get -u` permite escolher entre minor/patch updates
4. **Sem conflito de versões** — MVS evita "dependency hell" (múltiplas versões da mesma lib)
5. **Auditoria** — `go list -m all` mostra TODA a árvore de dependências

Este guia cobre **apenas comandos nativos** — sem ferramentas de terceiros.

---

## Gerenciamento com go.mod

**Regra:** Usar comandos Go nativos para gerenciar dependências.

#### Comandos essenciais
```bash
# Inicializar módulo
go mod init github.com/empresa/escola

# Adicionar dependência
go get github.com/gin-gonic/gin@v1.9.1

# Atualizar dependência para versão específica
go get github.com/jackc/pgx/v5@v5.5.0

# Atualizar todas as dependências (minor/patch)
go get -u ./...

# Atualizar apenas patches
go get -u=patch ./...

# Remover dependências não utilizadas
go mod tidy

# Verificar integridade
go mod verify

# Download de dependências (para CI/CD)
go mod download

# Listar dependências
go list -m all

# Ver dependências diretas
go list -m -json all | jq 'select(.Main != true and .Indirect != true)'
```

#### go.mod exemplo
```go
module github.com/empresa/escola

go 1.21

require (
    github.com/gin-gonic/gin v1.9.1
    github.com/jackc/pgx/v5 v5.5.0
    github.com/redis/go-redis/v9 v9.3.0
    github.com/stretchr/testify v1.8.4
    go.uber.org/fx v1.20.1
    go.uber.org/zap v1.26.0
    gopkg.in/yaml.v3 v3.0.1
)

require (
    // Dependências indiretas (gerenciadas automaticamente)
    github.com/bytedance/sonic v1.9.1 // indirect
    github.com/chenzhuoyu/base64x v0.0.0-20221115062448-fe3a3abad311 // indirect
    // ...
)
```

#### go.sum
- **NÃO edite manualmente** o arquivo `go.sum`
- Committar junto com `go.mod`
- Garante reprodutibilidade das builds
- Contém checksums criptográficos das dependências

---

## Bibliotecas Recomendadas

| Categoria | Biblioteca | Versão | Descrição | Link |
|-----------|------------|--------|-----------|------|
| **HTTP Framework** | Gin | v1.9+ | Framework web performático e popular | [🔗 Gin](https://gin-gonic.com/docs/) |
| **Dependency Injection** | Fx | v1.20+ | Framework DI do Uber com lifecycle | [🔗 Uber Fx](https://uber-go.github.io/fx/) |
| **PostgreSQL Driver** | pgx/v5 | v5.5+ | Driver nativo PostgreSQL (melhor que lib/pq) | [🔗 pgx](https://pkg.go.dev/github.com/jackc/pgx/v5) |
| **Redis Client** | go-redis/v9 | v9.3+ | Cliente Redis completo | [🔗 go-redis](https://redis.uptrace.dev/) |
| **Testing** | testify | v1.8+ | Assertions e mocks para testes | [🔗 Testify](https://github.com/stretchr/testify) |
| **Validação** | ozzo-validation/v4 | v4.3+ | Validação estrutural e de regras | [🔗 ozzo-validation](https://github.com/go-ozzo/ozzo-validation) |
| **Logging** | zap | v1.26+ | Logger estruturado de alta performance | [🔗 Zap](https://pkg.go.dev/go.uber.org/zap) |
| **Migrations** | golang-migrate | v4.17+ | Migrações de banco de dados | [🔗 migrate](https://github.com/golang-migrate/migrate) |
| **YAML** | yaml.v3 | v3.0+ | Parser YAML oficial | [🔗 yaml.v3](https://pkg.go.dev/gopkg.in/yaml.v3) |
| **Mensageria** | amqp091-go | v1.9+ | Cliente RabbitMQ oficial | [🔗 amqp091-go](https://pkg.go.dev/github.com/rabbitmq/amqp091-go) |
| **UUID** | google/uuid | v1.5+ | Geração de UUIDs | [🔗 uuid](https://pkg.go.dev/github.com/google/uuid) |
| **Time** | carbon/v2 | v2.3+ | Manipulação de datas (alternativa ao time) | [🔗 carbon](https://github.com/golang-module/carbon) |
| **Contexto/Timeout** | context | stdlib | Propagação de contexto (nativo Go) | [🔗 context](https://pkg.go.dev/context) |
| **Errors** | errors | stdlib | Wrapping de erros com %w (nativo Go 1.13+) | [🔗 errors](https://pkg.go.dev/errors) |

---

## Versões Específicas

**Por que versões exatas importam:**

Go usa **Minimal Version Selection (MVS)** — escolhe a **menor** versão que satisfaz todos os requisitos. Diferente de npm/pip que pegam a **maior** versão disponível.

**Exemplo do problema com `@latest`:**

```bash
# ❌ PERIGOSO - instala versão mais recente
go get github.com/gin-gonic/gin@latest

# Hoje: instala v1.9.1 (funciona)
# Amanhã: instala v1.10.0 (quebra seu código com breaking change)
# CI/CD: falha em produção porque desenvolvedor testou com v1.9.1
```

**Solução:**

```bash
# ✅ RECOMENDADO - versão específica
go get github.com/gin-gonic/gin@v1.9.1

# ✅ RECOMENDADO - pin version no go.mod
require github.com/gin-gonic/gin v1.9.1
```

**Semantic Versioning (SemVer):**

| Versão | Mudança | Compatibilidade | Exemplo |
|--------|---------|-----------------|---------|
| **MAJOR** (v1 → v2) | Breaking changes | ❌ Incompatível | Remover método público |
| **MINOR** (v1.9 → v1.10) | Novas features | ✅ Compatível | Adicionar método novo |
| **PATCH** (v1.9.1 → v1.9.2) | Bug fixes | ✅ Compatível | Corrigir comportamento |

**Atualização segura:**

```bash
# Atualizar apenas patches (1.9.1 → 1.9.2)
go get -u=patch github.com/gin-gonic/gin

# Atualizar minor + patch (1.9.1 → 1.10.0, mas NÃO 2.0.0)
go get -u github.com/gin-gonic/gin

# Ver versões disponíveis
go list -m -versions github.com/gin-gonic/gin

# Atualizar TUDO (perigoso)
go get -u ./...
```

**Quando atualizar:**

- ✅ **Patches:** Sempre seguro (bug fixes)
- ⚠️ **Minor:** Testar antes (novas features podem ter bugs)
- ❌ **Major:** Nunca automático (breaking changes = reescrever código)

**Referências:**
- 🔗 [Minimal Version Selection](https://research.swtch.com/vgo-mvs) - Russ Cox (criador do Go modules)
- 🔗 [Semantic Versioning](https://semver.org/)

---

## Dependências Privadas

Para repositórios privados (GitHub, GitLab, Bitbucket):

```bash
# Configurar GOPRIVATE
export GOPRIVATE=github.com/empresa/*

# Git config para autenticação
git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"

# Ou via SSH
git config --global url."git@github.com:".insteadOf "https://github.com/"

# Adicionar ao .bashrc/.zshrc
echo 'export GOPRIVATE=github.com/empresa/*' >> ~/.zshrc
```

#### go.mod com dependências privadas
```go
module github.com/empresa/escola

go 1.21

require (
    github.com/empresa/shared-lib v1.2.3  // Dependência privada
    github.com/gin-gonic/gin v1.9.1       // Dependência pública
)
```

---

## Replace Directive (Desenvolvimento Local)

Para desenvolvimento local de módulos dependentes:

```go
// go.mod
module github.com/empresa/escola

go 1.21

require (
    github.com/empresa/shared-lib v1.2.3
)

// Desenvolvimento local
replace github.com/empresa/shared-lib => ../shared-lib

// Ou branch específica (temporário)
replace github.com/empresa/shared-lib => github.com/empresa/shared-lib dev-branch
```

**⚠️ IMPORTANTE:** Remover `replace` antes de commitar para produção.

---

## Vendor (Opcional)

Para garantir builds offline ou CI/CD sem rede:

```bash
# Criar pasta vendor/ com todas as dependências
go mod vendor

# Build usando vendor
go build -mod=vendor

# Adicionar ao .gitignore (se não quiser commitar)
vendor/
```

**Nota:** Vendor é opcional. Muitos projetos modernos não usam (confiam em `go.sum` e `GOPROXY`).

---

## Limpeza e Auditoria

```bash
# Remover dependências não utilizadas
go mod tidy

# Verificar vulnerabilidades
go list -json -m all | nancy sleuth

# Ou usar govulncheck (ferramenta oficial Go)
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...

# Listar dependências diretas e tamanhos
go list -m -json all | jq -r '.Path + " " + .Version'

# Ver grafo de dependências
go mod graph | grep '^github.com/empresa/escola'
```

---

## Exemplo Completo: Adicionar Nova Dependência

```bash
# 1. Adicionar import no código
# student_service.go
import "github.com/google/uuid"

func generateID() string {
    return uuid.New().String()
}

# 2. Build/test faz download automático
go build ./...
# ou
go test ./...

# 3. Limpar dependências não usadas
go mod tidy

# 4. Verificar go.mod
cat go.mod
# require (
#     github.com/google/uuid v1.5.0
#     ...
# )

# 5. Commit go.mod e go.sum
git add go.mod go.sum
git commit -m "feat: add uuid generation"
```

**Referências:**
- 🔗 [Go Modules Reference](https://go.dev/ref/mod) - Documentação oficial
- 🔗 [Go Module Tutorial](https://go.dev/doc/tutorial/create-module)
- 🔗 [Go Dependency Management](https://go.dev/doc/modules/managing-dependencies)

---



---

**Próximo:** [Exemplo: CRUD Completo](07-exemplo-crud-completo.md) | **Anterior:** [Boas Práticas Go](05-boas-praticas.md) | **Voltar para:** [Índice](README.md)

**Última atualização:** 03/11/2025 16:42
