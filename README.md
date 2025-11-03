# 🤖 Intellisys DevHub - Guia de Desenvolvimento

Guia completo para desenvolvimento colaborativo com IA e Git.

![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Deployed-success)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?logo=javascript&logoColor=black)

## 📖 Sobre

**Intellisys DevHub** é uma documentação interativa e moderna que serve como guia de referência para equipes de desenvolvimento. Contém:

- 🛠️ **Ambiente de Desenvolvimento** - Setup completo e ferramentas essenciais
- 📝 **Padrões de Código** - Convenções e boas práticas
- 🔀 **Git & Versionamento** - Regras de commits, branches e changelog
- 🤖 **Trabalho com IA** - Boas práticas e guia de prompts
- ⚙️ **Configurações** - Templates para VSCode, ESLint, Prettier
- 📁 **Organização de Projeto** - Estrutura de pastas e arquitetura

## 🚀 Demo

Acesse: [https://intellisys-informatica.github.io/devhub](https://intellisys-informatica.github.io/devhub)

## ✨ Características

- ✅ 100% HTML, CSS e JavaScript puro (sem frameworks)
- ✅ Renderização de Markdown em tempo real
- ✅ Navegação dinâmica e busca
- ✅ Dark mode
- ✅ Responsivo (mobile-first)
- ✅ Syntax highlighting para código
- ✅ Table of Contents automático
- ✅ GitHub Pages ready

## 📂 Estrutura do Projeto

```
devhub/
├── index.html              # Página principal
├── css/
│   ├── style.css          # Estilos principais
│   └── markdown.css       # Estilos para Markdown
├── js/
│   ├── app.js             # Aplicação principal
│   ├── markdown-renderer.js # Renderizador MD
│   └── navigation.js      # Sistema de navegação
├── docs/
│   ├── manifest.json      # Índice de documentos
│   ├── ambiente/          # Docs de ambiente
│   ├── padroes/           # Padrões de código
│   ├── git/               # Git e versionamento
│   ├── ia/                # Trabalho com IA
│   └── config/            # Configurações
└── config/                # Templates de configuração
    ├── .vscode/
    ├── .eslintrc.json
    ├── .prettierrc
    └── .gitignore
```

## 🎯 Como Usar

### 1. Clone o repositório

```bash
git clone git@github.com:intellisys-informatica/devhub.git
cd devhub
```

### 2. Abra o projeto

Simplesmente abra o `index.html` em um navegador ou use um servidor local:

```bash
# Python
python -m http.server 8000

# Node.js
npx serve

# VSCode Live Server
# Instale a extensão e clique em "Go Live"
```

### 3. Acesse

Navegue para `http://localhost:8000`

## 📝 Adicionando Documentação

### Passo 1: Criar arquivo Markdown

Crie um arquivo `.md` na pasta apropriada em `docs/`:

```bash
docs/
└── sua-categoria/
    └── novo-documento.md
```

### Passo 2: Atualizar manifest.json

Adicione a entrada no `docs/manifest.json`:

```json
{
  "categories": [
    {
      "id": "sua-categoria",
      "title": "Sua Categoria",
      "icon": "📚",
      "docs": [
        {
          "id": "novo-doc",
          "title": "Novo Documento",
          "description": "Descrição do documento",
          "file": "sua-categoria/novo-documento.md"
        }
      ]
    }
  ]
}
```

### Passo 3: Pronto!

A página será atualizada automaticamente com o novo documento.

## 🎨 Customização

### Alterar tema

Edite as variáveis CSS em `css/style.css`:

```css
:root {
  --accent-color: #0969da;  /* Cor principal */
  --bg-primary: #ffffff;     /* Fundo principal */
  /* ... */
}
```

### Adicionar categoria

Adicione nova categoria no `manifest.json` e crie a pasta correspondente em `docs/`.

## 🌐 Deploy no GitHub Pages

### 1. Configurar repositório

```bash
# Inicializar Git (se ainda não estiver)
git init
git add .
git commit -m "Initial commit"

# Adicionar remote
git remote add origin git@github.com:intellisys-informatica/devhub.git
git push -u origin main
```

### 2. Ativar GitHub Pages

1. Vá em **Settings** → **Pages**
2. Em **Source**, selecione `main` branch
3. Clique em **Save**

### 3. Acessar

Seu site estará disponível em:
`https://intellisys-informatica.github.io/devhub`

## 🛠️ Tecnologias

- **[marked.js](https://marked.js.org/)** - Parser Markdown
- **[highlight.js](https://highlightjs.org/)** - Syntax highlighting
- **Vanilla JavaScript** - Sem frameworks
- **CSS Grid/Flexbox** - Layout responsivo

## 📄 Licença

MIT License - sinta-se livre para usar e modificar.

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'feat: adicionar MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## 📧 Contato

Se tiver dúvidas ou sugestões, abra uma [issue](https://github.com/intellisys-informatica/devhub/issues).

---

**Feito com ❤️ para desenvolvedores**
