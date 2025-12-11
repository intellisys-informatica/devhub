# Checklist de Code Review

> **"Code review não é crítica. É compartilhamento de conhecimento."**

Este checklist consolida **todas as convenções e boas práticas** dos arquivos anteriores em formato verificável. Use durante code review ou antes de abrir PR.

## Por que este checklist importa?

**Problema:** Reviewers gastam tempo revisando estilo básico ao invés de lógica de negócio.

**Solução:** Checklist automatiza verificação de padrões. Reviewer foca em:
- Arquitetura
- Lógica de negócio
- Edge cases
- Performance
- Segurança

**Como usar:**
1. **Antes de commit:** Autor verifica itens relevantes
2. **Durante PR:** Reviewer usa como guia sistemático
3. **Automação:** Integre verificações automatizáveis no CI (linters, testes, coverage)

---

## Nomenclatura

- [ ] **Idioma consistente** em todo o código (inglês OU português, nunca misturado)
- [ ] **Packages** em lowercase, singular, sem underscore
- [ ] **Structs** em PascalCase (exportados) ou camelCase (privados)
- [ ] **Campos ID** usando `Id` (não `ID`) para evitar conflito com métodos de interface
- [ ] **Interfaces** pequenas (1-5 métodos), sufixo `-er`/`-or` quando apropriado
- [ ] **Funções** começam com verbo (CreateStudent, GetStudent, UpdateEmail)
- [ ] **Construtores** com prefixo `New*` (NewStudent, NewService)
- [ ] **Variáveis** em camelCase, descritivas (evitar abreviações desnecessárias)
- [ ] **Booleanos** com prefixos is/has/can/should (inglês) ou esta/tem/pode/deve (português)
- [ ] **Constantes** em PascalCase (não UPPER_SNAKE_CASE)
- [ ] **Receptores** com 1 letra minúscula consistente (s, r, a, d)
- [ ] **Context** com nome completo: `ctx` (inglês) ou `contexto` (português)
- [ ] **Erros** com nome completo: `err` (inglês) ou `erro` (português)
- [ ] **Mutexes** com nome completo: `mutex` (não `mu`)
- [ ] **Erros sentinela** com prefixo `Err*` (inglês) ou `Erro*` (português)

---

## Estrutura de Pastas

- [ ] Segue **Standard Go Project Layout** (`cmd/`, `internal/`, `pkg/`)
- [ ] **Clean Architecture tática**: domain → app → infra → api
- [ ] **Domain** sem dependências externas (core business logic)
- [ ] **App** orquestra casos de uso (não precisa ser "puro")
- [ ] **Infra** implementa interfaces de domínio (DB, cache, HTTP clients)
- [ ] **API** contém controllers/handlers HTTP
- [ ] Fluxo de dependências: API → App → Domain ← Infra
- [ ] Packages com **significado semântico** (não `models/`, `utils/`, `helpers/`)
- [ ] Cada `cmd/*` tem seu próprio `main.go`
- [ ] Testes no mesmo package com sufixo `_test.go`

---

## Organização de Código

### Context
- [ ] Context sempre como **primeiro parâmetro**
- [ ] Context **nunca armazenado** em structs
- [ ] Context values usados com moderação (tipos privados para chaves)

### Errors
- [ ] Erros **encapsulados** com contexto: `fmt.Errorf("contexto: %w", err)`
- [ ] Uso de `errors.Is()` e `errors.As()` para verificação
- [ ] Erros sentinela definidos no package de domínio
- [ ] Erros não ignorados silenciosamente

### Early Return
- [ ] Preferência por **early return** ao invés de else desnecessário
- [ ] Redução de indentação excessiva
- [ ] Caminho feliz (happy path) sem muitos níveis de if

### Formatação
- [ ] Linhas com **máximo 80 caracteres** (flexível, não rígida)
- [ ] Assinaturas longas com **formatação vertical**
- [ ] Imports ordenados: stdlib → externos → internos

### Slices e Maps
- [ ] Preferir **nil slices** ao invés de slices vazios
- [ ] `len()` e `range` funcionam com nil

### Inicialização
- [ ] Structs inicializados com **campos nomeados**
- [ ] Construtores `New*` para validação

### Cleanup
- [ ] `defer` para cleanup (Close, Unlock, Rollback)
- [ ] Ordem de defer é LIFO (last in, first out)

### Concorrência
- [ ] Goroutines sincronizadas com `WaitGroup` ou `errgroup`
- [ ] Context usado para cancelamento
- [ ] Channels fechados pelo **produtor**
- [ ] Consumidor usa `range` para ler channels

---

## Padrões de Design

- [ ] **Repository Pattern**: Interface no domínio, implementação na infra
- [ ] **Service Layer**: Orquestração de operações, coordenação de repositórios
- [ ] **Dependency Injection**: Uso de Uber Fx para gerenciar lifecycle
- [ ] **Factory Pattern**: Construtores `New*` com validação
- [ ] **Strategy Pattern**: Comportamentos intercambiáveis via interfaces
- [ ] **Observer Pattern**: Event-driven com channels ou event bus
- [ ] Módulos Fx expostos via `var Module = fx.Module(...)`

---

## Interfaces e Tipos

- [ ] Interfaces **pequenas** (1-5 métodos)
- [ ] Interface Segregation: múltiplas interfaces pequenas ao invés de god interface
- [ ] **Accept interfaces, return structs**
- [ ] Parâmetros de função aceitam interfaces
- [ ] Retornos de função são structs concretos
- [ ] Interfaces compostas quando necessário

---

## Testes

- [ ] **Table-driven tests** com subtests (`t.Run`)
- [ ] Uso de **testify/require** para assertions críticas
- [ ] Uso de **testify/assert** para assertions não-críticas
- [ ] **Mocks** criados com `testify/mock`
- [ ] Coverage mínimo aceitável (defina valor: ex. 70%)
- [ ] Testes de integração separados (build tags ou sufixo `_integration_test.go`)
- [ ] Mocks verificados com `AssertExpectations(t)`

---

## Transações

- [ ] Sempre usar `defer` para rollback
- [ ] Pattern: `defer func() { if err != nil { tx.Rollback() } }()`
- [ ] Commit explícito ao final
- [ ] Helper `WithTransaction` para reutilização

---

## Configuração

- [ ] Arquivos de configuração em **YAML** (extensão `.yaml`, não `.yml`)
- [ ] Uso de `gopkg.in/yaml.v3` para parsing
- [ ] Valores default definidos no código
- [ ] Configuração carregada via função `Load(path string)`
- [ ] Environment variables para secrets (não hardcode)

---

## Dependências

- [ ] `go.mod` e `go.sum` commitados juntos
- [ ] Dependências com **versões específicas** (não `@latest`)
- [ ] `go mod tidy` executado antes de commit
- [ ] `go mod verify` para verificar integridade
- [ ] Dependências não utilizadas removidas
- [ ] `GOPRIVATE` configurado para repos privados
- [ ] `replace` directive removida antes de produção

---

## Performance

- [ ] Evitar alocações desnecessárias em hot paths
- [ ] Uso de `sync.Pool` para objetos reutilizáveis
- [ ] Indexes de banco de dados para queries frequentes
- [ ] Paginação em queries que retornam muitos resultados
- [ ] Cache (Redis) para dados acessados frequentemente
- [ ] Profiling com `pprof` quando necessário

---

## Segurança

- [ ] Validação de entrada em todas as APIs
- [ ] Sanitização de inputs do usuário
- [ ] Prepared statements (proteção contra SQL injection)
- [ ] Secrets não commitados (usar env vars)
- [ ] Logs não expõem dados sensíveis (passwords, tokens)
- [ ] HTTPS em produção
- [ ] Rate limiting em endpoints públicos
- [ ] CORS configurado corretamente

---

## Logging

- [ ] Uso de logger estruturado (`zap`)
- [ ] Níveis apropriados: Debug, Info, Warn, Error
- [ ] Context propagado para logs (request ID, user ID)
- [ ] Errors logados com stack trace quando relevante
- [ ] Logs não bloqueiam aplicação (async quando possível)

---

## HTTP/API

- [ ] Status codes corretos:
  - `200 OK`: Success
  - `201 Created`: Resource created
  - `204 No Content`: Success without body
  - `400 Bad Request`: Invalid input
  - `401 Unauthorized`: Authentication required
  - `403 Forbidden`: Authenticated but no permission
  - `404 Not Found`: Resource not found
  - `409 Conflict`: Duplicate/conflict
  - `500 Internal Server Error`: Server error
- [ ] Respostas JSON consistentes
- [ ] Erros retornam mensagem descritiva (não stacktrace em produção)
- [ ] Versionamento de API (`/api/v1/`, `/api/v2/`)
- [ ] Timeouts configurados
- [ ] Graceful shutdown implementado

---

## Documentação

- [ ] README.md com instruções de setup
- [ ] Comentários em código para lógica complexa
- [ ] Docstrings em funções/tipos exportados
- [ ] API documentada (OpenAPI/Swagger ou README)
- [ ] Changelog para versões (CHANGELOG.md)

---

## Git e CI/CD

- [ ] Commits atômicos (uma mudança por commit)
- [ ] Mensagens de commit descritivas (conventional commits)
- [ ] Branch strategy definida (gitflow, trunk-based)
- [ ] CI executa: lint, tests, build
- [ ] Cobertura de testes verificada em CI
- [ ] Dockerfile otimizado (multi-stage build)
- [ ] `.gitignore` configurado corretamente

---

## Resumo Estatístico

**Total de verificações:** 115+ itens

**Distribuição por categoria:**
- Nomenclatura: 15 itens
- Estrutura: 10 itens
- Organização: 26 itens
- Padrões: 7 itens
- Interfaces: 6 itens
- Testes: 7 itens
- Transações: 4 itens
- Configuração: 5 itens
- Dependências: 7 itens
- Performance: 6 itens
- Segurança: 8 itens
- Logging: 5 itens
- HTTP/API: 9 itens
- Documentação: 5 itens
- Git/CI: 7 itens

---

## Automação de Verificações

### Verificações Automatizáveis (via CI)

**Linters:**
```bash
# golangci-lint (agrega múltiplos linters)
golangci-lint run ./...

# Verificações específicas
gofmt -s -w .           # Formatação
go vet ./...            # Erros comuns
staticcheck ./...       # Análise estática
gosec ./...             # Segurança
```

**Testes:**
```bash
# Rodar testes com coverage
go test ./... -coverprofile=coverage.out

# Verificar coverage mínimo (70%)
go tool cover -func=coverage.out | grep total | awk '{print $3}' | sed 's/%//' | \
  awk '{if ($1 < 70) exit 1}'
```

**Dependências:**
```bash
# Verificar integridade
go mod verify

# Verificar vulnerabilidades
govulncheck ./...
```

**Exemplo de CI (GitHub Actions):**
```yaml
name: Go CI

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      - name: golangci-lint
        uses: golangci/golangci-lint-action@v3

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      - name: Test
        run: go test ./... -coverprofile=coverage.out
      - name: Check coverage
        run: |
          coverage=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | sed 's/%//')
          if (( $(echo "$coverage < 70" | bc -l) )); then
            echo "Coverage $coverage% is below 70%"
            exit 1
          fi
```

### Verificações Manuais (Code Review)

**Foco do reviewer:**
1. **Arquitetura**: Fluxo de dependências correto? Separação de camadas?
2. **Lógica de negócio**: Regras implementadas corretamente? Edge cases cobertos?
3. **Performance**: Queries N+1? Alocações desnecessárias? Indexes faltando?
4. **Segurança**: Validação de input? Secrets expostos? SQL injection?
5. **Manutenibilidade**: Código legível? Nomes claros? Comentários úteis?

---

## Workflow Sugerido

### Antes de Commit (Desenvolvedor)

1. **Auto-review:**
   - [ ] Rode `gofmt -s -w .` para formatação
   - [ ] Rode `go vet ./...` para verificar erros comuns
   - [ ] Rode testes: `go test ./...`
   - [ ] Verifique coverage: `go test -cover ./...`

2. **Checklist rápido:**
   - [ ] Código compila sem warnings
   - [ ] Testes passam localmente
   - [ ] Commits atômicos e bem descritos
   - [ ] `.gitignore` não commitou arquivos desnecessários

3. **Commit:**
   ```bash
   git add .
   git commit -m "feat: adiciona validação de email em Student"
   git push
   ```

### Durante PR (Reviewer)

1. **Automatizado (CI):**
   - ✅ Linters passam
   - ✅ Testes passam
   - ✅ Coverage >= 70%

2. **Manual (Checklist):**
   - Use este arquivo como referência
   - Foque em arquitetura e lógica (não estilo)
   - Deixe comentários construtivos

3. **Aprovação:**
   - ✅ Todos os itens críticos verificados
   - ✅ Discussões resolvidas
   - ✅ CI verde

---

## Dicas para Reviewers

### O que comentar

✅ **Comente:**
- Bugs potenciais
- Problemas de performance
- Vulnerabilidades de segurança
- Violações de arquitetura
- Lógica confusa que precisa de comentário
- Testes faltando para edge cases

❌ **Não comente (use linters):**
- Formatação (gofmt)
- Imports desordenados (goimports)
- Variáveis não utilizadas (go vet)
- Erros de estilo básico (golangci-lint)

### Como comentar

**Ruim:**
> "Isso está errado."

**Bom:**
> "Este código tem risco de SQL injection. Use prepared statements: `db.Query("SELECT * FROM users WHERE id = $1", userId)`"

**Ruim:**
> "Mude isso."

**Bom:**
> "Esta função faz 3 coisas diferentes. Considere separar em `ValidateStudent()`, `SaveStudent()` e `SendEmail()` para facilitar testes."

**Regra de ouro:** Seja específico, construtivo e educativo.

---



---

**Próximo:** [Referências](10-referencias.md) | **Anterior:** [Exemplo: Orquestração Avançada](08-exemplo-orquestracao-avancada.md) | **Voltar para:** [Índice](README.md)

**Última atualização:** 03/11/2025 16:42
