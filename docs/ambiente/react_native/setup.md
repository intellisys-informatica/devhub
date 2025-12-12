# Setup React Native + Expo + TypeScript

> Guia de configuração automática para projetos React Native com Expo

## 🚀 Início Rápido

**Script de criação de projetos React Native:**

Este script cria automaticamente **projetos completos do zero** usando Expo + React Native + TypeScript, instala todas as dependências com as versões mais recentes (NativeWind v4, Zustand v5, Zod v4), configura ferramentas e cria a estrutura de pastas seguindo as melhores práticas 2024/2025.

### Como usar

**Pré-requisitos:**
- Node.js 18+ instalado
- Git Bash ou terminal compatível (Windows/Linux/Mac)

**Executar o script:**

```bash
cd docs/ambiente/reactnative
./setup-react-native.sh
```

O script irá solicitar apenas o **nome do projeto** e então:

1. ✅ Criar projeto com Expo + TypeScript
2. ✅ Instalar todas as dependências (versões atualizadas 2024/2025)
3. ✅ Configurar NativeWind v4 (TailwindCSS para React Native)
4. ✅ Configurar TanStack Query v5 + Axios
5. ✅ Configurar Zustand v5 (estado global)
6. ✅ Configurar React Hook Form + Zod v4
7. ✅ Criar estrutura completa de pastas
8. ✅ Configurar TypeScript com path aliases (`@/*`)
9. ✅ Inicializar Git com commit inicial

Depois é só iniciar o desenvolvimento:

```bash
cd seu-projeto
npm start
```

---

## 📋 O que o Script Faz

### Instalações (13 etapas)

1. **Cria projeto Expo** - `npx create-expo-app` com template TypeScript
2. **Instala dependências base** - Pacotes essenciais do Expo
3. **Instala navegação** - Expo Router + React Navigation
4. **Instala NativeWind v4** - TailwindCSS v3.4+ + React Native Reanimated
5. **Instala HTTP/Estado** - TanStack Query v5 + Axios + Zustand v5 + React Hook Form + Zod v4
6. **Instala AsyncStorage** - Persistência de dados local
7. **Instala TypeScript types** - Tipagens do React/React Native

### Configurações (6 etapas)

8. **Cria estrutura de pastas** - `app/`, `src/`, `assets/` completos
9. **Configura NativeWind v4** - Tailwind + Babel + Metro + global.css
10. **Configura TypeScript** - Paths `@/*` + tipos do NativeWind
11. **Cria arquivos de configuração** - QueryClient, Axios, Stores, Schemas
12. **Configura app principal** - Layout com providers + página inicial
13. **Inicializa Git** - Repositório com commit inicial

---

## 🛠️ Stack Tecnológica

| Categoria | Ferramenta | Versão | Por quê? |
|-----------|-----------|--------|----------|
| **Framework** | Expo | Latest | Facilita configuração e builds |
| **Linguagem** | TypeScript | Latest | Type safety essencial |
| **Navegação** | Expo Router | Latest | Navegação baseada em arquivos |
| **Estilização** | NativeWind | v4.2+ | TailwindCSS para React Native |
| **HTTP/Cache** | TanStack Query | v5 | Gerenciamento inteligente de requisições |
| **HTTP Client** | Axios | Latest | Cliente HTTP configurável |
| **Formulários** | React Hook Form | Latest | Performance otimizada |
| **Validação** | Zod | v4 | Validação tipada |
| **Estado Global** | Zustand | v5 | Simples, zero boilerplate |
| **Storage** | AsyncStorage | Latest | Persistência local |
| **Animações** | Reanimated | Latest | Animações performáticas |
| **Build** | EAS Build | Latest | Builds na nuvem |

---

## 📁 Estrutura Criada

```
seu-projeto/
├── app/                          # Rotas (Expo Router)
│   ├── (auth)/                   # Grupo de autenticação
│   ├── (tabs)/                   # Grupo de tabs
│   ├── _layout.tsx               # Layout raiz + providers
│   └── index.tsx                 # Página inicial
│
├── src/
│   ├── components/               # Componentes reutilizáveis
│   │   ├── ui/                   # Componentes base
│   │   │   ├── Button.tsx        # 🆕 Botão com NativeWind
│   │   │   └── index.ts
│   │   ├── forms/                # Componentes de formulário
│   │   └── shared/               # Componentes compartilhados
│   │
│   ├── features/                 # Módulos por funcionalidade
│   │   └── (vazio - pronto para uso)
│   │
│   ├── hooks/                    # Hooks customizados
│   │
│   ├── lib/                      # Configurações de libs
│   │   └── queryClient.ts        # 🆕 Config TanStack Query
│   │
│   ├── services/                 # Serviços e API
│   │   └── api/
│   │       ├── axios.config.ts   # 🆕 Axios + interceptors
│   │       └── index.ts
│   │
│   ├── store/                    # Estado global (Zustand v5)
│   │   ├── authStore.ts          # 🆕 Store de autenticação
│   │   ├── themeStore.ts         # 🆕 Store de tema
│   │   └── index.ts
│   │
│   ├── schemas/                  # Schemas de validação (Zod v4)
│   │   ├── common.schema.ts      # 🆕 Schemas comuns
│   │   ├── auth.schema.ts        # 🆕 Schemas de auth
│   │   └── index.ts
│   │
│   ├── types/                    # TypeScript types globais
│   ├── utils/                    # Funções utilitárias
│   └── constants/                # Constantes da aplicação
│
├── assets/                       # Assets estáticos
│   ├── images/
│   ├── fonts/
│   └── icons/
│
├── global.css                    # 🆕 Estilos TailwindCSS
├── metro.config.js               # 🆕 Metro + NativeWind v4
├── babel.config.js               # 🆕 Babel + NativeWind v4
├── tailwind.config.js            # 🆕 Tailwind com preset NativeWind
├── nativewind-env.d.ts          # 🆕 Types do NativeWind
├── tsconfig.json                 # TypeScript + paths @/*
├── eas.json                      # 🆕 Config EAS Build
├── .env                          # 🆕 Variáveis de ambiente
└── .env.example                  # Template de env vars
```

---

## ⚙️ Configurações Automáticas

### NativeWind v4 (TailwindCSS)

O script configura completamente o NativeWind v4:

**Arquivos criados:**
- `global.css` - Diretivas do Tailwind
- `metro.config.js` - Metro com `withNativeWind()`
- `babel.config.js` - `jsxImportSource: "nativewind"`
- `tailwind.config.js` - Preset do NativeWind v4
- `nativewind-env.d.ts` - Tipos TypeScript

**Uso:**
```tsx
import { View, Text } from 'react-native';

export function Card() {
  return (
    <View className="bg-white p-4 rounded-lg shadow-md">
      <Text className="text-xl font-bold text-gray-800">
        Título
      </Text>
    </View>
  );
}
```

### TanStack Query v5

**Arquivo criado:** `src/lib/queryClient.ts`

Configurado com:
- `staleTime: 5 minutos`
- `retry: 2 tentativas`
- `refetchOnWindowFocus: false`

**Uso:**
```tsx
import { useQuery } from '@tanstack/react-query';
import { api } from '@/services/api';

export function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => api.get('/users').then(res => res.data)
  });
}
```

### Axios com Interceptors

**Arquivo criado:** `src/services/api/axios.config.ts`

Configurado com:
- Base URL do `.env`
- Timeout de 10 segundos
- Interceptor de autenticação (adiciona token)
- Interceptor de erro (logout em 401)
- Logs em desenvolvimento

**Uso:**
```tsx
import { api } from '@/services/api';

const response = await api.get('/users');
const users = response.data;
```

### Zustand v5 Stores

**Arquivos criados:**
- `src/store/authStore.ts` - Autenticação com persist
- `src/store/themeStore.ts` - Tema claro/escuro

**Uso:**
```tsx
import { useAuthStore } from '@/store';

export function Profile() {
  const user = useAuthStore(state => state.user);
  const logout = useAuthStore(state => state.logout);

  return (
    <View>
      <Text>Olá, {user?.name}</Text>
      <Button onPress={logout}>Sair</Button>
    </View>
  );
}
```

### Schemas Zod v4

**Arquivos criados:**
- `src/schemas/common.schema.ts` - Email, senha, nome
- `src/schemas/auth.schema.ts` - Login, registro

**Uso:**
```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { loginSchema } from '@/schemas';

export function LoginForm() {
  const { control, handleSubmit } = useForm({
    resolver: zodResolver(loginSchema)
  });

  // ...
}
```

### TypeScript Path Aliases

**Configurado no `tsconfig.json`:**
```json
{
  "paths": {
    "@/*": ["src/*"],
    "@/components/*": ["src/components/*"],
    "@/hooks/*": ["src/hooks/*"],
    "@/services/*": ["src/services/*"],
    "@/store/*": ["src/store/*"],
    "@/schemas/*": ["src/schemas/*"]
  }
}
```

**Uso:**
```tsx
import { Button } from '@/components/ui';
import { useAuthStore } from '@/store';
import { api } from '@/services/api';
```

---

## 🌐 Variáveis de Ambiente

**Arquivo criado:** `.env`

```env
EXPO_PUBLIC_API_URL=http://localhost:3000
EXPO_PUBLIC_API_TIMEOUT=10000
```

**Uso no código:**
```tsx
const API_URL = process.env.EXPO_PUBLIC_API_URL;
```

> ⚠️ **Importante:** Variáveis Expo devem ter prefixo `EXPO_PUBLIC_`

---

## 📱 Build e Deploy

### EAS Build

**Arquivo criado:** `eas.json`

Profiles configurados:
- **development** - Build de desenvolvimento
- **preview** - Build preview (APK para Android)
- **production** - Build de produção

**Comandos:**
```bash
# Instalar EAS CLI
npm install -g eas-cli

# Login
eas login

# Build de desenvolvimento
eas build --profile development --platform android

# Build de produção
eas build --profile production --platform all
```

---

## 🎯 Próximos Passos

Após executar o script:

1. **Entre no diretório:**
   ```bash
   cd seu-projeto
   ```

2. **Inicie o projeto:**
   ```bash
   npm start
   ```

3. **Escaneie o QR code** no app Expo Go

4. **Desenvolva suas features** na pasta `src/features/`

5. **Crie componentes** reutilizáveis em `src/components/`

6. **Configure variáveis** de ambiente no `.env`

---

## 📚 Documentação

- [Expo](https://docs.expo.dev/)
- [NativeWind v4](https://www.nativewind.dev/)
- [TanStack Query](https://tanstack.com/query/latest)
- [Zustand](https://docs.pmnd.rs/zustand)
- [React Hook Form](https://react-hook-form.com/)
- [Zod](https://zod.dev/)
- [Expo Router](https://docs.expo.dev/router/introduction/)

---

## 🔧 Troubleshooting

### Erro ao executar o script

**Problema:** `Permission denied` ou script não executa

**Solução:**
```bash
chmod +x setup-react-native.sh
dos2unix setup-react-native.sh  # Se estiver no Windows
```

### TypeScript errors com className

**Problema:** `Property 'className' does not exist`

**Solução:** Arquivo `nativewind-env.d.ts` deve estar na raiz

### Metro bundler não inicia

**Problema:** Erros ao iniciar com `npm start`

**Solução:**
```bash
# Limpar cache
npx expo start -c

# OU
rm -rf node_modules
npm install
```

### Erro de peer dependencies

**Problema:** Conflitos de versões ao instalar

**Solução:** O script já usa `--legacy-peer-deps` automaticamente

---

## 🆕 Diferenças da v4 (NativeWind)

Se você conhece NativeWind v2, aqui estão as principais mudanças:

| Item | v2 | v4 |
|------|----|----|
| **Config** | Plugin babel | Preset + babel + metro |
| **CSS** | Não tinha | `global.css` obrigatório |
| **Metro** | Não precisava | `metro.config.js` com `withNativeWind()` |
| **Import** | Não precisava | `import '../global.css'` no layout |
| **Types** | Não tinha | `nativewind-env.d.ts` obrigatório |
| **Reanimated** | Opcional | Dependência obrigatória |

---

## ✅ Checklist de Verificação

Após executar o script, verifique:

- [ ] Projeto criado em `./seu-projeto`
- [ ] 789 pacotes instalados sem erros
- [ ] Arquivo `global.css` existe na raiz
- [ ] Arquivo `metro.config.js` existe
- [ ] Arquivo `nativewind-env.d.ts` existe
- [ ] Pasta `src/` com subpastas criadas
- [ ] Arquivo `.env` criado
- [ ] Git inicializado com commit inicial
- [ ] TypeScript compila sem erros: `npx tsc --noEmit`
- [ ] Projeto inicia sem erros: `npm start`

---

**Última atualização:** 12/12/2024 14:30
