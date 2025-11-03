# Padrões Go Backend - Guia Completo

> **Do básico ao avançado:** Convenções, arquitetura e boas práticas para projetos backend Go de médio e grande porte

---

## 🤖 Diretrizes para Agentes de IA

📥 **[Download: Diretrizes Go para Agentes de IA](docs/convencoes/go/assets/CLAUDE.md)**

---

## 📖 Introdução

Bem-vindo ao guia de padrões Go Backend. Este material nasceu da análise do projeto **inotify** (sistema de notificações multi-canal) e consolidou práticas de projetos reais com referências da comunidade Go e da indústria.

### Por Que Este Guia Existe?

Go é uma linguagem opinativa, mas deixa espaço para decisões de design em projetos complexos. Este guia responde perguntas comuns:

- **Estrutura:** Como organizar um projeto com múltiplos domínios?
- **Arquitetura:** Clean Architecture é obrigatória? Como usar DDD sem overhead?
- **Código:** Onde fica a linha entre "idiomático" e "engenharia excessiva"?
- **Dependências:** Quais bibliotecas escolher num ecossistema fragmentado?
- **Testes:** Como testar sistemas com DB, cache, filas e APIs externas?

### Para Quem É Este Guia?

- **Júnior → Pleno:** Quer estruturar projetos com qualidade e aprender padrões reais
- **Pleno → Sênior:** Busca consolidar conhecimento e ter material de referência para code review
- **Tech Leads:** Precisa padronizar práticas no time e reduzir débito técnico
- **Desenvolvedores de outras linguagens:** Migrando para Go e quer evitar anti-patterns

### O Que Você Vai Encontrar?

**10 documentos progressivos** cobrindo:
1. **Fundamentos** (nomenclatura, estrutura, organização)
2. **Arquitetura** (patterns, DI, estratégias)
3. **Desenvolvimento prático** (dependências, 2 exemplos completos)
4. **Qualidade** (checklist de review, referências anotadas)

**Cada seção explica:**
- ✅ **O que fazer** (boas práticas)
- ❌ **O que evitar** (anti-patterns comuns)
- 🤔 **Por que** (contexto e trade-offs)
- 💡 **Exemplos reais** (código que funciona)

### Filosofia do Guia

Este **não é um manual dogmático**. Os padrões aqui são:

- **Pragmáticos:** Arquitetura serve o problema, não o contrário
- **Idiomáticos:** Go first - adaptamos conceitos de outras linguagens à realidade Go
- **Contextualizados:** Cada decisão tem trade-offs explicados
- **Evolutivos:** Comece simples, adicione complexidade quando necessário

**Regra de ouro:** "Make it work, make it right, make it fast" - nessa ordem.

---

## 📚 Índice Completo

### 📘 Parte I: Fundamentos

#### 1. [Nomenclatura](01-nomenclatura.md)
**O que você aprenderá:**
- Idioma do código (inglês vs português)
- Convenções Go: packages, structs, interfaces, funções
- Nomes de variáveis, constantes e erros
- Receptores e mutexes

**Para quem:** Todos. Nomenclatura é base para código legível.

#### 2. [Estrutura de Pastas](02-estrutura-pastas.md)
**O que você aprenderá:**
- Standard Go Project Layout (com crítica construtiva)
- Clean Architecture **tática** (não purista)
- Regra de dependências entre camadas
- Organização por feature vs por tipo
- Estrutura `cmd/`, `internal/`, `pkg/`

**Para quem:** Todos. Estrutura errada gera refatorações caras depois.

#### 3. [Organização de Código](03-organizacao-codigo.md)
**O que você aprenderá:**
- Context propagation (context.Context sempre primeiro parâmetro)
- Error handling idiomático (wrapping, early return)
- Nil slices, defer, goroutines, channels
- Padrões de concorrência segura

**Para quem:** Todos. Erros aqui geram bugs sutis em produção.

---

### 🏗️ Parte II: Arquitetura e Design

#### 4. [Padrões de Design](04-padroes-design.md)
**O que você aprenderá:**
- Repository Pattern (com e sem interfaces)
- Service Layer (quando usar, quando evitar)
- Dependency Injection com Fx (pattern recomendado neste guia)
- Factory, Strategy, Observer
- Trade-offs de cada pattern

**Para quem:** Pleno+. Júniores: foquem em Repository e Service Layer primeiro.

#### 5. [Boas Práticas Go](05-boas-praticas.md)
**O que você aprenderá:**
- Interfaces pequenas ("accept interfaces, return structs" com nuances)
- Table-driven tests (padrão Go)
- Testify para assertions e mocks
- Transações de banco de dados
- Configuração YAML vs env vars

**Para quem:** Todos. Práticas que diferenciam código Go amador de profissional.

---

### 💻 Parte III: Desenvolvimento Prático

#### 6. [Dependências e Módulos](06-dependencias.md)
**O que você aprenderá:**
- go.mod e go.sum (versionamento)
- Bibliotecas recomendadas (HTTP, DB, DI, validação, cache, mensageria)
- Critérios de seleção de dependências
- Dependências privadas, vendor, limpeza

**Para quem:** Todos. Escolhas ruins aqui custam caro (segurança, performance, manutenção).

#### 7. [Exemplo: CRUD Completo](07-exemplo-crud-completo.md)
**O que você aprenderá:**
- CRUD básico: Student (Create, Read, Update, Delete)
- Camadas: Domain → Repository → Service → Controller
- PostgreSQL com pgx/v5
- Migrações com golang-migrate
- Testes com Testify
- Docker Compose para rodar localmente
- Troubleshooting e próximos passos

**Para quem:** Júnior/Pleno. **Comece aqui** para ver código funcionando.

#### 8. [Exemplo: Orquestração Avançada](08-exemplo-orquestracao-avancada.md)
**O que você aprenderá:**
- 4 agregados: Student, Course, Enrollment, Payment
- **Saga Pattern** com compensação (rollback distribuído)
- **Circuit Breaker** para Stripe API
- **Idempotência** com Redis
- Coordenação: PostgreSQL + Stripe + Redis + RabbitMQ
- Testes com 7 mocks
- Comparação CRUD vs Orquestração (tabela de complexidade)

**Para quem:** Pleno/Sênior. Sistema real com falhas distribuídas.

---

### ✅ Parte IV: Qualidade e Referências

#### 9. [Checklist de Code Review](09-checklist.md)
**O que você aprenderá:**
- 15 categorias, 115+ verificações
- Automação (golangci-lint, CI com GitHub Actions)
- Workflow de review (developer + reviewer)
- Como comentar em PRs (bons e maus exemplos)
- Estatísticas (cobertura, complexidade, race conditions)

**Para quem:** Todos. Code review não é crítica, é compartilhamento de conhecimento.

#### 10. [Referências](10-referencias.md)
**O que você aprenderá:**
- Documentação oficial Go
- Guias de estilo (Uber, Google, Effective Go)
- Arquitetura (Clean Arch, DDD, GoF Patterns)
- Bibliotecas (anotadas com "usado neste guia")
- Testing, concorrência, performance
- Livros, artigos (com avisos de opiniões controversas)
- Ferramentas (VS Code, golangci-lint, air)
- Tabela de recursos citados nas seções 1-9

**Para quem:** Todos. Referência consolidada e anotada (não só lista de links).

---

## 🎯 Como Usar Este Guia

### 🚀 Trilha Para Iniciantes (Júnior)

**Objetivo:** Escrever código Go idiomático e estruturar projetos básicos.

1. **Leia sequencialmente:** 01 → 02 → 03 (fundamentos)
2. **Pratique:** 07 (CRUD completo) - rode localmente, quebre, conserte
3. **Estude patterns:** 04 (foque em Repository e Service Layer)
4. **Aprenda boas práticas:** 05 (table-driven tests, transações)
5. **Use o checklist:** 09 (antes de commitar código)

**Tempo estimado:** 2-3 semanas (com prática).

### 📈 Trilha Para Plenos

**Objetivo:** Dominar arquitetura, orquestração e patterns avançados.

1. **Revise fundamentos:** 01-03 (identificar gaps)
2. **Domine patterns:** 04 (todos os patterns, trade-offs)
3. **Estude orquestração:** 08 (Saga, Circuit Breaker, Idempotência)
4. **Apronfunde:** 06 (critérios de seleção de libs), 05 (testes avançados)
5. **Participe de reviews:** 09 (seja reviewer, não só reviewee)
6. **Explore referências:** 10 (livros DDD Cap 5-11, Concurrency in Go)

**Tempo estimado:** 3-4 semanas.

### 🎓 Trilha Para Sêniores/Tech Leads

**Objetivo:** Padronizar time, conduzir arquitetura, educar.

1. **Audite código atual:** Use 09 (checklist) no codebase existente
2. **Defina padrões do time:** Adapte 01-06 ao contexto do projeto
3. **Conduza code reviews educativas:** 09 (como comentar, princípios)
4. **Implemente CI robusto:** 09 (exemplo GitHub Actions)
5. **Mentore:** Use exemplos 07-08 para ensinar júniores/plenos
6. **Mantenha-se atualizado:** 10 (newsletters, comunidade)

**Tempo estimado:** Contínuo (guia como referência).

### 📋 Uso Rápido (Consulta Pontual)

**Precisa de algo específico?** Índice direto:

| Precisa de | Vá para |
|------------|---------|
| Nomear struct, função, pacote | [01-nomenclatura.md](01-nomenclatura.md) |
| Estruturar projeto novo | [02-estrutura-pastas.md](02-estrutura-pastas.md) |
| Error handling, context | [03-organizacao-codigo.md](03-organizacao-codigo.md) |
| Repository, DI, patterns | [04-padroes-design.md](04-padroes-design.md) |
| Testes, transações, config | [05-boas-praticas.md](05-boas-praticas.md) |
| Escolher biblioteca HTTP/DB | [06-dependencias.md](06-dependencias.md) |
| Ver CRUD funcionando | [07-exemplo-crud-completo.md](07-exemplo-crud-completo.md) |
| Saga, Circuit Breaker | [08-exemplo-orquestracao-avancada.md](08-exemplo-orquestracao-avancada.md) |
| Revisar PR | [09-checklist.md](09-checklist.md) |
| Links para docs oficiais | [10-referencias.md](10-referencias.md) |

---

## 🔑 Princípios-Chave Deste Guia

Estes princípios guiam **todas** as decisões de design documentadas:

### 1. Consistência Idiomática
**"Faça do jeito Go, não do jeito que você conhece de outra linguagem"**

- Use `camelCase`, não `snake_case`
- Retorne `error`, não exceções
- Aceite interfaces, retorne structs (com nuances)
- Prefira composição sobre herança (Go nem tem herança)

### 2. Clareza Sobre Cleverness
**"Código legível > código 'inteligente'"**

- Variável `userRepository` é melhor que `ur`
- Função de 10 linhas > função de 100 linhas "eficiente"
- Early return > nested if gigante
- Comentários explicam "por quê", não "o quê"

### 3. Pragmatismo Tático
**"Arquitetura serve o problema, não o contrário"**

- Projeto de 3 entidades não precisa de CQRS
- Clean Architecture **tática** (não 8 camadas puristas)
- DDD **Tactical Patterns** (não Strategic Design completo)
- CRUD simples não precisa de Service Layer

### 4. Simplicidade Intencional
**"Resolva problemas atuais, não futuros imaginários"**

- YAGNI (You Aren't Gonna Need It)
- Evite abstrações prematuras
- Comece com código direto, refatore quando houver 3+ casos similares
- Não otimize antes de medir

### 5. Testes Como Documentação
**"Table-driven tests mostram comportamento esperado"**

- Testes mostram **como usar** o código
- Nomes descritivos: `TestCreateStudent_DuplicateEmail_ReturnsError`
- Arrange-Act-Assert (Given-When-Then)
- Mocks com Testify (idiomático)

---

## 🧭 Navegação Entre Documentos

Cada documento tem:
- **Links de navegação:** `← Anterior | Próximo →`
- **Voltar ao índice:** Link para este README
- **Seções internas:** Índice local no topo

**Recomendação:** Leia no VS Code ou GitHub para aproveitar links clicáveis.

---

## 📊 Sobre Este Guia

### Base Técnica
- **Projeto de referência:** inotify (sistema de notificações multi-canal)
- **Clean Architecture:** Pragmática (domain → app → infra → api)
- **DDD:** Tactical Patterns (Cap 5-11 do Evans)
- **Guias oficiais:** Effective Go, Code Review Comments
- **Guias da indústria:** Uber Go Style Guide, Google Go Style Guide

### Abordagem Pedagógica
- **Não prescritivo:** Explica trade-offs, não impõe soluções
- **Contextualizado:** Exemplos reais (não "Foo/Bar")
- **Progressivo:** Do simples (CRUD) ao complexo (Saga Pattern)
- **Crítico:** Avisos sobre opiniões controversas em artigos externos

### Domínio dos Exemplos
**Sistema escolar** (Student, Course, Enrollment, Payment) por:
- Familiaridade: todos entendem matrícula em curso
- Complexidade gradual: CRUD simples → orquestração multi-agregado
- Realismo: problemas reais (pagamento falha, rollback distribuído)

---

## 🤝 Contribuições e Feedback

Este guia é **vivo e colaborativo**. Contribuições são bem-vindas:

### Como Contribuir
1. **Issues:** Relate erros, sugestões, seções confusas
2. **Pull Requests:** Correções, exemplos adicionais, melhorias
3. **Discussões:** Compartilhe experiências de uso deste guia

### O Que Não Aceitamos
- Opiniões não fundamentadas ("nunca use X porque sim")
- Dogmas de arquitetura ("sempre use CQRS")
- Exemplos artificiais sem contexto real

### Mantedores
Este guia é mantido pela equipe do projeto inotify. Revisões passam por validação técnica e pedagógica.

---

## 📜 Licença e Uso

**Licença:** MIT - Use livremente em projetos comerciais e educacionais.

**Atribuição:** Não obrigatória, mas apreciada se referenciar este guia.

---

## 📅 Versionamento

- **Versão atual:** 1.0
- **Última atualização:** Novembro 2025
- **Go version target:** 1.21+

**Changelog:** Futuras versões terão changelog detalhado.

---

## 🌟 Comece Agora

Escolha sua trilha:

- **Iniciante?** → [01. Nomenclatura](01-nomenclatura.md)
- **Quer ver código?** → [07. Exemplo CRUD](07-exemplo-crud-completo.md)
- **Busca referências?** → [10. Referências](10-referencias.md)
- **Vai revisar PR?** → [09. Checklist](09-checklist.md)

**Boa jornada! 🚀**

**Última atualização:** 03/11/2025 16:42
