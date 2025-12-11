# 📂 Estrutura do Projeto DevHub

## Árvore de Diretórios

```
devhub/
│
├── 📄 index.html                    # Página principal (ABRA ESTE)
├── 📄 README.md                     # Documentação do projeto
├── 📄 GUIA_DE_USO.md               # Instruções de uso
├── 📄 .gitignore                   # Arquivos ignorados pelo Git
│
├── 📁 css/
│   ├── style.css                   # Estilos principais da UI
│   └── markdown.css                # Estilos para conteúdo Markdown
│
├── 📁 js/
│   ├── app.js                      # Aplicação principal
│   ├── markdown-renderer.js        # Renderizador de Markdown
│   └── navigation.js               # Sistema de navegação
│
├── 📁 docs/                        # ← ADICIONE DOCUMENTAÇÃO AQUI
│   ├── manifest.json               # Índice de documentos
│   │
│   ├── 📁 ambiente/
│   │   ├── setup-inicial.md        # Setup do ambiente
│   │   └── ferramentas.md          # Ferramentas essenciais
│   │
│   ├── 📁 padroes/
│   │   ├── javascript.md           # Padrões JS/TS
│   │   ├── css.md                  # Padrões CSS/SCSS
│   │   └── nomenclatura.md         # Convenções de nomes
│   │
│   ├── 📁 git/
│   │   ├── commits.md              # Conventional Commits
│   │   ├── branches.md             # Git Flow
│   │   └── changelog.md            # Como escrever changelogs
│   │
│   ├── 📁 ia/
│   │   ├── boas-praticas.md        # Trabalho com IA
│   │   └── prompts.md              # Guia de prompts
│   │
│   └── 📁 config/
│       ├── vscode.md               # Configuração VSCode
│       ├── eslint.md               # Configuração ESLint
│       └── prettier.md             # Configuração Prettier
│
├── 📁 config/                      # Templates de configuração
│   ├── 📁 .vscode/
│   │   ├── settings.json           # Configurações VSCode
│   │   └── extensions.json         # Extensões recomendadas
│   ├── .eslintrc.json              # Config ESLint
│   ├── .prettierrc                 # Config Prettier
│   └── .gitignore                  # Template gitignore
│
└── 📁 assets/                      # Imagens e recursos estáticos
    └── .gitkeep
```

## 📊 Estatísticas

- **Total de arquivos HTML**: 1
- **Total de arquivos CSS**: 2
- **Total de arquivos JavaScript**: 3
- **Total de documentos Markdown**: 18
- **Total de categorias**: 6
- **Total de templates de config**: 5

## 🎯 Arquivos Principais

### Para Usuários

- **index.html** - Abra este arquivo para ver o site
- **GUIA_DE_USO.md** - Leia para instruções completas
- **docs/manifest.json** - Edite para adicionar documentos

### Para Desenvolvedores

- **js/app.js** - Lógica principal da aplicação
- **js/markdown-renderer.js** - Renderização de Markdown
- **js/navigation.js** - Sistema de navegação
- **css/style.css** - Estilos customizáveis

## 📝 Documentação Disponível

### 🛠️ Ambiente de Desenvolvimento (2 docs)
- Setup Inicial
- Ferramentas Essenciais

### 📝 Padrões de Código (3 docs)
- JavaScript/TypeScript
- CSS/SCSS
- Nomenclatura

### 🔀 Git & Versionamento (3 docs)
- Regras de Commits
- Estratégia de Branches
- Changelog

### 🤖 Trabalho com IA (2 docs)
- Boas Práticas
- Guia de Prompts

### ⚙️ Configurações (3 docs)
- VSCode
- ESLint
- Prettier

### 📁 Organização de Projeto (2 docs)
- Estrutura de Pastas
- Arquitetura

## 🚀 Como Começar

1. **Abrir o projeto**:
   - Abra `index.html` no navegador
   - Ou use um servidor local: `python -m http.server 8000`

2. **Explorar**:
   - Navegue pelo menu lateral
   - Use a busca para encontrar conteúdo
   - Alterne entre modo claro/escuro

3. **Personalizar**:
   - Edite `css/style.css` para mudar cores
   - Adicione documentos em `docs/`
   - Atualize `docs/manifest.json`

4. **Deploy**:
   - Suba para GitHub
   - Ative GitHub Pages
   - Compartilhe a URL com seu time

## 🔧 Tecnologias

- **HTML5** - Estrutura
- **CSS3** - Estilização (Grid, Flexbox, Custom Properties)
- **JavaScript ES6+** - Funcionalidade
- **marked.js** - Parser Markdown
- **highlight.js** - Syntax highlighting

## ✨ Funcionalidades

- ✅ Renderização de Markdown em tempo real
- ✅ Navegação dinâmica com categorias
- ✅ Busca de documentos
- ✅ Dark mode
- ✅ Responsivo (mobile-first)
- ✅ Table of contents automático
- ✅ Syntax highlighting
- ✅ Copy button para código
- ✅ Breadcrumb navigation
- ✅ GitHub Pages ready

## 📖 Leitura Recomendada

1. [GUIA_DE_USO.md](GUIA_DE_USO.md) - Para começar
2. [README.md](README.md) - Visão geral do projeto
3. [docs/manifest.json](docs/manifest.json) - Estrutura de dados

## 🎨 Customização Rápida

### Mudar cor principal
`css/style.css` linha 6:
```css
--accent-color: #0969da; /* Sua cor aqui */
```

### Mudar logo
`index.html` linha 29:
```html
<h1 class="logo">🤖 Seu Nome</h1>
```

### Adicionar documento
1. Crie arquivo em `docs/categoria/`
2. Adicione entrada no `manifest.json`
3. Recarregue a página

---

**Projeto criado e pronto para uso! 🎉**

Data de criação: 2025-10-06
