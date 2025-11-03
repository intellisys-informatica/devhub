# Referências

> **"Não reinvente a roda. Mas entenda como ela funciona antes de usá-la."**

Este arquivo consolida **recursos externos** que fundamentam as práticas documentadas neste guia. Use como ponto de partida para aprofundamento.

## Como Usar Este Guia de Referências

### Por Prioridade

**🔥 Essenciais (comece aqui):**
- Effective Go
- Go Code Review Comments
- Uber Go Style Guide
- Standard Go Project Layout

**📚 Aprofundamento:**
- The Go Programming Language (livro)
- Clean Architecture + DDD (conceitos)
- Bibliotecas específicas (conforme necessidade)

**🎯 Específicos:**
- Performance (quando otimizar)
- Concorrência (além do básico)
- Observability (produção)

### Por Necessidade

| Preciso... | Veja... |
|-----------|---------|
| Aprender Go do zero | Go Official Documentation → Getting Started |
| Entender convenções | Effective Go + Code Review Comments |
| Estruturar projeto grande | Standard Go Project Layout + Clean Architecture |
| Melhorar code review | Uber/Google Style Guides + Checklist (arquivo 09) |
| Escolher bibliotecas | Seção 9.4 (Bibliotecas e Frameworks) |
| Otimizar performance | Seção 9.7 (Performance) |
| Testar adequadamente | Seção 9.5 (Testing e Quality) |

---

## Documentação Oficial Go

#### Linguagem e Fundamentos
- 🔗 [Go Official Documentation](https://go.dev/doc/) - Documentação oficial completa
- 🔗 [Effective Go](https://go.dev/doc/effective_go) - Guia idiomático essencial
- 🔗 [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments) - Convenções da equipe Go
- 🔗 [Go Modules Reference](https://go.dev/ref/mod) - Referência completa de módulos
- 🔗 [Go Blog](https://go.dev/blog/) - Artigos oficiais sobre Go

#### Bibliotecas Standard
- 🔗 [context](https://pkg.go.dev/context) - Propagação de contexto e cancelamento
- 🔗 [errors](https://pkg.go.dev/errors) - Manipulação de erros (Go 1.13+)
- 🔗 [fmt](https://pkg.go.dev/fmt) - Formatação de I/O
- 🔗 [time](https://pkg.go.dev/time) - Manipulação de tempo e duração
- 🔗 [sync](https://pkg.go.dev/sync) - Primitivas de sincronização

#### Tutoriais Oficiais
- 🔗 [Getting Started](https://go.dev/doc/tutorial/getting-started) - Primeiro projeto Go
- 🔗 [Create a Module](https://go.dev/doc/tutorial/create-module) - Criação de módulos
- 🔗 [Working with Errors](https://go.dev/blog/go1.13-errors) - Error wrapping (Go 1.13)
- 🔗 [Error Handling](https://go.dev/blog/error-handling-and-go) - Boas práticas

---

## Guias de Estilo

**Por que importa:** Estes guias consolidam anos de experiência de grandes empresas. Muitas práticas deste documento vêm deles.

**Prioridade de leitura:**
1. **Uber Go Style Guide** (mais completo)
2. **Effective Go** (fundação oficial)
3. **Go Code Review Comments** (convenções práticas)
4. **Google Go Style Guide** (complementar)

- 🔗 [Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md) - Guia completo do Uber (altamente recomendado)
- 🔗 [Google Go Style Guide](https://google.github.io/styleguide/go/) - Convenções do Google
- 🔗 [Go Proverbs](https://go-proverbs.github.io/) - Princípios idiomáticos
- 🔗 [Go Best Practices](https://peter.bourgon.org/go-best-practices-2016/) - Peter Bourgon
- 🔗 [Practical Go](https://dave.cheney.net/practical-go/presentations/qcon-china.html) - Dave Cheney

---

## Arquitetura e Design

**Alinhamento com este guia:**
- Este documento usa **Clean Architecture tática** (pragmática, não purista)
- Foco em **DDD Tactical Patterns** (Capítulos 5-11 do Evans)
- **Repository, Service Layer, Factory** são patterns chave aqui

### Clean Architecture
- 📚 **Robert C. Martin** - [Clean Architecture: A Craftsman's Guide to Software Structure and Design](https://www.amazon.com/Clean-Architecture-Craftsmans-Software-Structure/dp/0134494164)
- 🔗 [The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) - Artigo original
- 🔗 [Applying Clean Architecture to Go](https://manuel.kiessling.net/2012/09/28/applying-the-clean-architecture-to-go-applications/)

#### Domain-Driven Design (DDD)
- 📚 **Eric Evans** - [Domain-Driven Design: Tackling Complexity in the Heart of Software](https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215)
  - Especialmente **Capítulos 5-11** (Tactical Patterns)
- 📚 **Vaughn Vernon** - [Implementing Domain-Driven Design](https://www.amazon.com/Implementing-Domain-Driven-Design-Vaughn-Vernon/dp/0321834577)
- 🔗 [DDD Reference](https://www.domainlanguage.com/ddd/reference/) - Resumo oficial

#### Design Patterns
- 📚 **Gang of Four** - [Design Patterns: Elements of Reusable Object-Oriented Software](https://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented/dp/0201633612)
- 🔗 [Refactoring Guru - Design Patterns](https://refactoring.guru/design-patterns) - Guia visual interativo
- 🔗 [Go Patterns](https://github.com/tmrts/go-patterns) - Implementações em Go

#### Estrutura de Projetos
- 🔗 [Standard Go Project Layout](https://github.com/golang-standards/project-layout) - Layout padrão da comunidade
- 🔗 [Go Project Structure](https://github.com/golang-standards/project-layout/blob/master/README.md)

**Prioridade de leitura:**
1. **Domain-Driven Design (Evans)** - Capítulos 5-11 (Tactical Patterns) são essenciais, Strategic Patterns (Cap 14-16) opcionais
2. **Clean Architecture (Martin)** - Camadas de dependência, mas lembre: "tática, não dogmática"
3. **Standard Go Project Layout** - Estrutura base, mas adapte ao seu contexto
4. **Design Patterns (GoF)** - Repository, Factory, Strategy são os mais usados em Go
5. **Implementing DDD (Vernon)** - Referência para implementação real, mas adapte para Go

---

## Bibliotecas e Frameworks

**Critério de seleção:** Maturidade, performance, idiomaticidade Go.  
Bibliotecas listadas aqui são as **recomendadas neste guia** (veja seção 6).

### HTTP Frameworks
- 🔗 [Gin](https://gin-gonic.com/docs/) - Framework web performático **(usado neste guia)**
- 🔗 [Echo](https://echo.labstack.com/) - Framework minimalista
- 🔗 [Fiber](https://docs.gofiber.io/) - Express-like framework

### Dependency Injection
- 🔗 [Uber Fx](https://uber-go.github.io/fx/) - Framework DI com lifecycle **(usado neste guia)**
- 🔗 [Fx Examples](https://github.com/uber-go/fx/tree/master/examples)
- 🔗 [Wire](https://github.com/google/wire) - Gerador de código para DI

### Database Drivers
- 🔗 [pgx/v5](https://pkg.go.dev/github.com/jackc/pgx/v5) - Driver PostgreSQL nativo **(usado neste guia)**
- 🔗 [pgx Tutorial](https://github.com/jackc/pgx/wiki/Getting-started-with-pgx)
- 🔗 [sqlx](https://github.com/jmoiron/sqlx) - Extensions para database/sql

### Cache e Mensageria
- 🔗 [go-redis/v9](https://redis.uptrace.dev/) - Cliente Redis **(usado neste guia)**
- 🔗 [amqp091-go](https://pkg.go.dev/github.com/rabbitmq/amqp091-go) - RabbitMQ oficial **(usado neste guia)**
- 🔗 [Sarama](https://github.com/IBM/sarama) - Cliente Kafka

### Validação
- 🔗 [ozzo-validation/v4](https://github.com/go-ozzo/ozzo-validation) - Validação estrutural **(usado neste guia)**
- 🔗 [validator/v10](https://github.com/go-playground/validator) - Validação por tags

### Logging
- 🔗 [Zap](https://pkg.go.dev/go.uber.org/zap) - Logger estruturado de alta performance **(usado neste guia)**
- 🔗 [Zap Documentation](https://github.com/uber-go/zap/blob/master/README.md)
- 🔗 [Logrus](https://github.com/sirupsen/logrus) - Logger estruturado popular

### Testing
- 🔗 [Testify](https://github.com/stretchr/testify) - Assertions e mocks **(usado neste guia)**
- 🔗 [Testify Mock](https://pkg.go.dev/github.com/stretchr/testify/mock)
- 🔗 [GoMock](https://github.com/golang/mock) - Framework de mocking oficial
- 🔗 [httptest](https://pkg.go.dev/net/http/httptest) - Testing HTTP (stdlib)

### Migrations
- 🔗 [golang-migrate](https://github.com/golang-migrate/migrate) - Database migrations **(usado neste guia)**
- 🔗 [goose](https://github.com/pressly/goose) - Database migration tool

### Configuração
- 🔗 [yaml.v3](https://pkg.go.dev/gopkg.in/yaml.v3) - Parser YAML oficial **(usado neste guia)**
- 🔗 [Viper](https://github.com/spf13/viper) - Configuração completa (YAML/JSON/env)

### Utilities
- 🔗 [uuid](https://pkg.go.dev/github.com/google/uuid) - Geração de UUIDs
- 🔗 [carbon/v2](https://github.com/golang-module/carbon) - Manipulação de datas
- 🔗 [lo](https://github.com/samber/lo) - Utilities funcionais (lodash-like)

**Observação importante:** As bibliotecas marcadas com **(usado neste guia)** são as escolhas documentadas nos exemplos práticos (seções 7-8). Outras opções são válidas, mas estas têm suporte completo na documentação.

---

## Testing e Quality

**Por que importa:** Testes não são "nice to have". São documentação viva, rede de segurança e ferramenta de design.

### Testing
- 🔗 [Table Driven Tests](https://go.dev/wiki/TableDrivenTests) - Go Wiki oficial
- 🔗 [Go Testing Tutorial](https://go.dev/doc/tutorial/add-a-test)
- 🔗 [Advanced Testing with Go](https://www.youtube.com/watch?v=8hQG7QlcLBk) - Mitchell Hashimoto (Video)
- 🔗 [Learn Go with Tests](https://quii.gitbook.io/learn-go-with-tests/) - TDD em Go

**Abordagem de testes neste guia:**
- **Table-Driven Tests** são o padrão
- **Mocks via Testify** (não GoMock) - mais idiomático
- **Cobertura >80%** é meta, não obrigação cega
- Veja exemplos práticos nas seções 7-8

### Code Quality
- 🔗 [golangci-lint](https://golangci-lint.run/) - Meta-linter **(usado neste guia, veja seção 9)**
- 🔗 [staticcheck](https://staticcheck.io/) - Análise estática avançada
- 🔗 [go vet](https://pkg.go.dev/cmd/vet) - Ferramenta oficial de análise

### Coverage e Profiling
- 🔗 [Go Code Coverage](https://go.dev/blog/cover) - Cobertura de testes
- 🔗 [pprof](https://pkg.go.dev/net/http/pprof) - Profiling de performance
- 🔗 [Profiling Go Programs](https://go.dev/blog/pprof) - Blog oficial

### Security
- 🔗 [govulncheck](https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck) - Scanner de vulnerabilidades oficial
- 🔗 [gosec](https://github.com/securego/gosec) - Security checker
- 🔗 [nancy](https://github.com/sonatype-nexus-community/nancy) - Dependency vulnerability scanner

---

## Concorrência

**Por que importa:** Concorrência é vantagem competitiva do Go. Mas mal usada vira pesadelo de race conditions.

**Regras de ouro deste guia:**
- **Context sempre primeiro parâmetro** (veja seção 3)
- **errgroup para goroutines coordenadas** (não `sync.WaitGroup` diretamente)
- **Channels para comunicação, não compartilhamento de memória**

### Recursos essenciais:
### Recursos essenciais:
- 🔗 [Go Concurrency Patterns](https://go.dev/blog/pipelines) - Pipelines e cancelamento
- 🔗 [Advanced Concurrency Patterns](https://go.dev/blog/io2013-talk-concurrency) - Rob Pike (Video)
- 🔗 [Effective Go - Concurrency](https://go.dev/doc/effective_go#concurrency)
- 🔗 [errgroup](https://pkg.go.dev/golang.org/x/sync/errgroup) - Goroutines com error handling **(usado neste guia)**
- 🔗 [Context and Cancellation](https://go.dev/blog/context) - Blog oficial
- 📚 **Katherine Cox-Buday** - [Concurrency in Go](https://www.oreilly.com/library/view/concurrency-in-go/9781491941294/)

**Prioridade de leitura:**
1. **Effective Go - Concurrency** - Fundação (goroutines, channels)
2. **errgroup docs** - Pattern recomendado neste guia
3. **Context and Cancellation** - Essencial para APIs e timeouts
4. **Go Concurrency Patterns** - Pipelines (intermediário)
5. **Advanced Concurrency Patterns (Rob Pike)** - Avançado, mas transformador

---

## Performance

**Quando otimizar:** Depois de medir. "Premature optimization is the root of all evil" (Knuth).

**Ferramentas deste guia:**
- `pprof` para CPU/memory profiling (veja seção 5)
- `benchstat` para comparação de benchmarks
- `go test -bench` para benchmarking

### Recursos essenciais:
### Recursos essenciais:
- 🔗 [Go Performance Tips](https://github.com/dgryski/go-perfbook) - Performance book
- 🔗 [High Performance Go Workshop](https://dave.cheney.net/high-performance-go-workshop/gopherchina-2019.html) - Dave Cheney
- 🔗 [Memory Optimization](https://segment.com/blog/allocation-efficiency-in-high-performance-go-services/)
- 🔗 [Benchmarking](https://dave.cheney.net/2013/06/30/how-to-write-benchmarks-in-go)

**Prioridade de leitura:**
1. **Benchmarking (Dave Cheney)** - Aprenda a medir primeiro
2. **Go Performance Tips** - Referência completa
3. **High Performance Go Workshop** - Deep dive
4. **Memory Optimization (Segment)** - Casos reais

---

## Deployment e DevOps

**Filosofia deste guia:**
- **Multi-stage builds** para imagens Docker mínimas
- **Distroless** em produção (não Alpine, não scratch)
- **CI sempre roda linters + tests + security checks** (veja seção 9)

### Docker
- 🔗 [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- 🔗 [Distroless Images](https://github.com/GoogleContainerTools/distroless) - Imagens mínimas **(recomendado neste guia)**

### CI/CD
- 🔗 [GitHub Actions for Go](https://github.com/actions/setup-go)
- 🔗 [GitLab CI Go Example](https://docs.gitlab.com/ee/ci/examples/test-and-deploy-go-project.html)

**Veja exemplo de CI completo (linters + tests + security) na seção 9 - Checklist.**

### Observability
- 🔗 [OpenTelemetry Go](https://opentelemetry.io/docs/instrumentation/go/) - Tracing e metrics
- 🔗 [Prometheus Client](https://github.com/prometheus/client_golang) - Metrics
- 🔗 [Grafana](https://grafana.com/docs/)

---

## Comunidade e Recursos

**Por que importa:** Go tem comunidade ativa e acolhedora. Use isso a seu favor.

### Fóruns e Discussões
- 🔗 [Go Forum](https://forum.golangbridge.org/)
- 🔗 [Gophers Slack](https://gophers.slack.com/) - [Invite](https://invite.slack.golangbridge.org/)
- 🔗 [Reddit r/golang](https://www.reddit.com/r/golang/)
- 🔗 [Go Brasil - Telegram](https://t.me/go_br) - Comunidade brasileira

### Newsletters
- 🔗 [Golang Weekly](https://golangweekly.com/)
- 🔗 [Go Newsletter](https://gonewsletter.com/)

### Podcasts
- 🔗 [Go Time](https://changelog.com/gotime) - Podcast oficial da comunidade

### Videos e Conferências
- 🔗 [GopherCon](https://www.gophercon.com/) - Conferência anual
- 🔗 [Justforfunc](https://www.youtube.com/c/JustForFunc) - Francesc Campoy
- 🔗 [Gopher Academy](https://www.youtube.com/c/GopherAcademy)

**Recomendações:**
- **Go Brasil - Telegram** para dúvidas em português
- **Gophers Slack** para discussões técnicas profundas
- **Golang Weekly** para se manter atualizado (curadoria excelente)
- **Go Time podcast** para commutes/treinos

---

## Livros Recomendados

**Ordem de leitura sugerida para quem está começando:**
1. **The Go Programming Language** (base sólida)
2. **Concurrency in Go** (dominar goroutines/channels)
3. **Domain-Driven Design** Cap. 5-11 (design tático)
4. **Clean Architecture** (estrutura de projetos)

### Go Específico
- 📚 **Alan A. A. Donovan, Brian W. Kernighan** - [The Go Programming Language](https://www.gopl.io/) ⭐ **Essencial**
- 📚 **Jon Bodner** - [Learning Go: An Idiomatic Approach to Real-World Go Programming](https://www.oreilly.com/library/view/learning-go/9781492077206/)
- 📚 **Mat Ryer** - [Go Programming Blueprints](https://www.packtpub.com/product/go-programming-blueprints-second-edition/9781786468949)

### Arquitetura e Design
- 📚 **Robert C. Martin** - Clean Architecture (já mencionado na seção Arquitetura e Design)
- 📚 **Eric Evans** - Domain-Driven Design (já mencionado na seção Arquitetura e Design)
- 📚 **Martin Fowler** - [Patterns of Enterprise Application Architecture](https://martinfowler.com/books/eaa.html)
- 📚 **Sam Newman** - [Building Microservices](https://www.oreilly.com/library/view/building-microservices-2nd/9781492034018/)

### Testes
- 📚 **Kent Beck** - [Test Driven Development: By Example](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)

---

## Artigos e Blog Posts Essenciais

**Atenção:** Artigos marcados com ⚠️ contêm **opiniões controversas**. Leia criticamente.

### Patterns e Design
**Atenção:** Artigos marcados com ⚠️ contêm **opiniões controversas**. Leia criticamente.

### Patterns e Design
- 🔗 [Functional Options Pattern](https://dave.cheney.net/2014/10/17/functional-options-for-friendly-apis) - Dave Cheney ⭐ **Usado neste guia**
- 🔗 [Interface Design](https://rakyll.org/interface-pollution/) - Rakyll ⚠️ **"Accept interfaces, return structs" tem exceções**
- 🔗 [Organize Go Code](https://rakyll.org/style-packages/) - Rakyll

### Performance
- 🔗 [Don't Force Allocations](https://segment.com/blog/allocation-efficiency-in-high-performance-go-services/) - Segment ⭐

### Error Handling
- 🔗 [Error Handling Best Practices](https://earthly.dev/blog/golang-errors/) ⭐

### Project Structure
- 🔗 [Project Structure Best Practices](https://www.gobeyond.dev/standard-package-layout/) ⚠️ **Veja seção 2 deste guia para contexto**

**Por que os avisos (⚠️)?**
- **Interface Design (Rakyll):** Artigo excelente, mas "accept interfaces, return structs" não é regra absoluta. Repositórios podem retornar interfaces para testabilidade (veja seção 4).
- **Project Structure:** Artigo bom, mas críticas ao Standard Layout devem ser contextualizadas. Este guia usa layout tático (veja seção 2).

---

## Tools

**Ferramentas essenciais do dia a dia:**

### Development
- 🔗 [VS Code Go Extension](https://marketplace.visualstudio.com/items?itemName=golang.go) ⭐ **Recomendado**
- 🔗 [GoLand](https://www.jetbrains.com/go/) - IDE JetBrains (pago, mas poderoso)
- 🔗 [air](https://github.com/cosmtrek/air) - Live reload **(usado neste guia)**

### CLI Tools
- 🔗 [gofmt](https://pkg.go.dev/cmd/gofmt) - Formatação de código (oficial, automático)
- 🔗 [goimports](https://pkg.go.dev/golang.org/x/tools/cmd/goimports) - Organização de imports (automático)
- 🔗 [golangci-lint](https://golangci-lint.run/) - Meta-linter **(usado neste guia, veja seção 9)**

**Setup mínimo recomendado:**
1. VS Code + Go Extension (ou GoLand)
2. `goimports` configurado para rodar on-save
3. `golangci-lint` no CI (veja exemplo na seção 9)
4. `air` para desenvolvimento local

---

## Recursos Citados Neste Guia

Esta seção lista as referências **diretamente mencionadas** nas seções 1-9 deste documento, para facilitar lookup.

| Recurso | Seções que citam | Prioridade |
|---------|-----------------|------------|
| **Uber Go Style Guide** | 1, 5, 9 | ⭐⭐⭐ Essencial |
| **Effective Go** | 1, 3, 5 | ⭐⭐⭐ Essencial |
| **Standard Go Project Layout** | 2 | ⭐⭐⭐ Essencial |
| **Domain-Driven Design (Evans)** | 2, 4 | ⭐⭐ Importante (Cap 5-11) |
| **Clean Architecture (Martin)** | 2, 4 | ⭐⭐ Importante |
| **Uber Fx** | 4, 5, 7, 8 | ⭐⭐⭐ Essencial (DI padrão) |
| **pgx/v5** | 5, 6, 7 | ⭐⭐⭐ Essencial (PostgreSQL) |
| **Testify** | 5, 6, 7, 8 | ⭐⭐⭐ Essencial (Testes) |
| **ozzo-validation/v4** | 5, 6 | ⭐⭐ Importante |
| **Gin** | 6, 7 | ⭐⭐ Importante (HTTP) |
| **Zap** | 6 | ⭐⭐ Importante (Logging) |
| **golang-migrate** | 6, 7 | ⭐⭐ Importante (Migrations) |
| **golangci-lint** | 9 | ⭐⭐⭐ Essencial (CI) |
| **errgroup** | 3, 8 | ⭐⭐ Importante (Concorrência) |
| **Functional Options Pattern** | 4, 5 | ⭐ Recomendado |

---

## Conclusão

Este documento consolida padrões, convenções e boas práticas para projetos Go backend de médio e grande porte, baseado em:

- **Análise do projeto inotify** (convenções reais)
- **Clean Architecture tática** (pragmatismo sobre purismo)
- **Domain-Driven Design tático** (patterns práticos)
- **Guias oficiais Go** (Effective Go, Code Review Comments)
- **Guias da indústria** (Uber, Google)

### Princípios-Chave

1. **Consistência idiomática**: Siga as convenções Go (não invente)
2. **Clareza sobre cleverness**: Código legível > código "inteligente"
3. **Pragmatismo tático**: Adapte arquitetura ao contexto (não dogma)
4. **Simplicidade intencional**: Resolva problemas atuais, não futuros imaginários
5. **Testes como documentação**: Table-driven tests mostram comportamento esperado

### Adaptação ao Contexto

Este guia é uma **base sólida**, não uma lei imutável:

- **Projetos pequenos**: Estrutura simplificada pode ser suficiente
- **Projetos legados**: Migração incremental é válida
- **Equipes iniciantes**: Comece simples, evolua com maturidade
- **Domínios específicos**: Adapte patterns ao problema real

---

**Versão:** 1.0  
**Última atualização:** Novembro 2025  
**Licença:** MIT

---

**Contribuições e Feedback:**  
Este documento é vivo. Sugestões de melhorias são bem-vindas através de pull requests ou issues no repositório do projeto.


---

**Anterior:** [Checklist de Code Review](09-checklist.md) | **Voltar para:** [Índice](README.md)

**Última atualização:** 03/11/2025 16:42
