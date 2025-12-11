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

📖 **[Instruções completas de instalação](script-install.md)**

---

## O que o Script Faz

✅ **Cria projeto Vite** - `npm create vite@latest` com template react-ts
✅ **Instala dependências** - react-router-dom, react-hook-form, zod, axios
✅ **Configura Tailwind CSS v4** - Plugin Vite + configuração completa
✅ **Inicializa shadcn/ui** - `shadcn init` com configuração padrão
✅ **Path aliases** - Configura `@/*` no Vite e TypeScript
✅ **Estrutura de pastas** - Cria `app/`, `features/`, `shared/`, `mappers/`
✅ **Axios configurado** - Instância + service layer + interceptors
✅ **.env + tipagem** - Variáveis de ambiente com TypeScript
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
│   │   └── home/
│   │       ├── components/
│   │       ├── hooks/
│   │       ├── types/
│   │       └── mappers/      # 🆕 Transformadores de dados
│   ├── shared/           # Código compartilhado
│   │   ├── components/
│   │   │   ├── ui/      # shadcn/ui components
│   │   │   └── layout/
│   │   ├── lib/
│   │   │   └── axios.ts      # 🆕 Instância Axios configurada
│   │   ├── services/
│   │   │   └── api.ts        # 🆕 API Service Layer
│   │   ├── types/
│   │   │   └── api.types.ts  # 🆕 Types da API
│   │   └── mappers/          # 🆕 Mappers globais
│   ├── vite-env.d.ts         # 🆕 Tipagem de env vars
│   └── ...
├── .env                      # 🆕 Variáveis de ambiente
├── vite.config.ts            # Vite + Tailwind + path aliases
├── tsconfig.json
└── package.json
```

---

## Configuração do Axios

O script configura automaticamente o Axios:

### Arquivos criados

**`src/shared/lib/axios.ts`** - Instância configurada com:
- Base URL do `.env`
- Timeout de 10s
- Interceptors para logs (dev)
- Headers de autenticação

**`src/shared/services/api.ts`** - Service layer com métodos:
- `get<T>()`, `post<T>()`, `put<T>()`, `patch<T>()`, `delete<T>()`
- Retorna diretamente o `.data`

**`src/vite-env.d.ts`** - Tipagem TypeScript para env vars

### Uso

```typescript
import { apiService } from '@/shared/services/api'

const users = await apiService.get<User[]>('/users')
```

---

## Mappers

O script cria pastas `mappers/` para transformação de dados:

### Onde usar
- **`features/*/mappers/`** - Transformadores específicos da feature
- **`shared/mappers/`** - Transformadores reutilizáveis

### Exemplo
```typescript
// features/students/mappers/student.mapper.ts
export const studentMapper = {
  toDomain: (api: StudentApiResponse): Student => ({
    id: api.student_id,
    name: api.full_name,
  }),
}
```

---

**Última atualização:** 10/10/2025 16:25
