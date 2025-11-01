# Setup React + TypeScript

> Guia de configuração inicial para projetos React + TypeScript

## 🚀 Início Rápido

**Script de criação de projetos React:**

Este script cria automaticamente **projetos completos do zero** usando Vite + React + TypeScript, instala todas as dependências (react-router-dom, axios, tailwind, shadcn/ui), configura ferramentas e cria a estrutura de pastas seguindo os padrões do time.

### Instalação do Script (Recomendado)

#### Para Bash
```bash
curl -fsSL https://raw.githubusercontent.com/intellisys-informatica/devhub/main/docs/ambiente/reactjs/assets/install.sh | bash
```

#### Para Zsh
```bash
curl -fsSL https://raw.githubusercontent.com/intellisys-informatica/devhub/main/docs/ambiente/reactjs/assets/install.sh | zsh
```

### Como usar

Crie o projeto completo com um único comando:

```bash
create-react-ts meu-projeto
```

O script irá:
1. ✅ Criar projeto com Vite + React + TypeScript
2. ✅ Instalar todas as dependências (react-router-dom, axios, tailwind, shadcn/ui, etc)
3. ✅ Configurar Tailwind CSS v4 + shadcn/ui
4. ✅ Criar estrutura de pastas (`app/`, `features/`, `shared/`)
5. ✅ Configurar path aliases (`@/*`)
6. ✅ Inicializar Git + Git Flow

Depois é só iniciar o desenvolvimento:

```bash
cd meu-projeto
npm run dev
```

### Instalação Manual

📥 **[Download do Script](docs/ambiente/reactjs/assets/create-react-vite.sh)**

📖 **[Instruções completas de instalação](./script-install.md)**

---

## O que o Script Faz

✅ **Cria projeto Vite** - `npm create vite@latest` com template react-ts
✅ **Instala dependências** - react-router-dom, react-hook-form, zod, axios
✅ **Configura Tailwind CSS v4** - Plugin Vite + configuração completa
✅ **Inicializa shadcn/ui** - `shadcn init` com configuração padrão
✅ **Path aliases** - Configura `@/*` no Vite e TypeScript
✅ **Estrutura de pastas** - Cria `app/`, `features/`, `shared/`
✅ **Git Flow** - Inicializa com branches `main` e `develop`
✅ **Arquivos de exemplo** - Cria componentes e types de exemplo

---

## Estrutura Criada

```
meu-projeto/
├── src/
│   ├── app/              # Configuração da aplicação
│   │   ├── providers/
│   │   ├── routes/
│   │   └── styles/
│   ├── features/         # Módulos por funcionalidade
│   │   └── students/
│   │       ├── components/
│   │       ├── hooks/
│   │       └── types/
│   ├── shared/           # Código compartilhado
│   │   ├── components/
│   │   │   ├── ui/      # shadcn/ui components
│   │   │   └── layout/
│   │   ├── lib/
│   │   ├── services/
│   │   └── types/
│   └── ...
├── vite.config.ts        # Vite + Tailwind + path aliases
├── tsconfig.json
└── package.json
```

---

**Última atualização:** 10/10/2025 08:39
