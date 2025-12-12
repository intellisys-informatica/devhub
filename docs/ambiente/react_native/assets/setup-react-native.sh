#!/bin/bash

# ========================================
# Script de Setup Automático React Native
# Baseado no Guia React Native Setup 2024/2025
# Versões Atualizadas: NativeWind v4, Zustand v5, Zod v4
# ========================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções auxiliares
print_step() {
    echo -e "${BLUE}➜ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Banner
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   React Native Setup - Configuração Automática          ║
║   Stack: Expo + TypeScript + TanStack Query + Zustand   ║
║   NativeWind v4 + Versões Atualizadas 2024/2025         ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# ========================================
# Coleta de Informações
# ========================================

echo -e "${YELLOW}Nome do projeto:${NC}\n"

read -p "Nome do projeto (ex: meu-app): " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    print_error "Nome do projeto é obrigatório!"
    exit 1
fi

# Valores hardcoded
API_URL="http://localhost:3000"
API_TIMEOUT="10000"

echo ""

# ========================================
# 1. Criar Projeto Expo
# ========================================

print_step "1/13 Criando projeto Expo..."
npx create-expo-app@latest "$PROJECT_NAME" --template blank-typescript --no-install
cd "$PROJECT_NAME"
print_success "Projeto criado"

# ========================================
# 2. Instalar Dependências Base
# ========================================

print_step "2/13 Instalando dependências base..."
npm install --legacy-peer-deps
print_success "Dependências base instaladas"

# ========================================
# 3. Instalar Navegação
# ========================================

print_step "3/13 Instalando navegação..."
npx expo install expo-router react-native-screens react-native-safe-area-context -- --legacy-peer-deps
print_success "Navegação instalada"

# ========================================
# 4. Instalar NativeWind v4 + Reanimated
# ========================================

print_step "4/13 Instalando NativeWind v4, TailwindCSS e Reanimated..."
npm install nativewind --legacy-peer-deps
npm install --save-dev tailwindcss@^3.4.17 --legacy-peer-deps
npx expo install react-native-reanimated -- --legacy-peer-deps
print_success "NativeWind v4 instalado"

# ========================================
# 5. Instalar HTTP, Estado e Validação
# ========================================

print_step "5/13 Instalando TanStack Query, Axios, Zustand v5, React Hook Form e Zod v4..."
npm install @tanstack/react-query axios zustand@5 react-hook-form zod@4 @hookform/resolvers --legacy-peer-deps
print_success "HTTP, estado e validação instalados"

# ========================================
# 6. Instalar Storage
# ========================================

print_step "6/13 Instalando AsyncStorage..."
npx expo install @react-native-async-storage/async-storage -- --legacy-peer-deps
print_success "Storage instalado"

# ========================================
# 7. Instalar TypeScript Types
# ========================================

print_step "7/13 Instalando TypeScript types..."
npm install -D @types/react @types/react-native --legacy-peer-deps
print_success "TypeScript types instalados"

# ========================================
# 8. Criar Estrutura de Pastas
# ========================================

print_step "8/13 Criando estrutura de pastas..."
mkdir -p app/{auth,tabs}
mkdir -p src/{components/{ui,forms,shared},features,hooks,services/api,store,schemas,types,utils,constants,lib}
mkdir -p assets/{images,fonts,icons}
print_success "Estrutura criada"

# ========================================
# 9. Configurar NativeWind v4
# ========================================

print_step "9/13 Configurando NativeWind v4..."

# Tailwind Config com preset do NativeWind v4
cat > tailwind.config.js << 'TAILWIND_EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./App.{js,jsx,ts,tsx}",
    "./app/**/*.{js,jsx,ts,tsx}",
    "./src/**/*.{js,jsx,ts,tsx}"
  ],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {},
  },
  plugins: [],
}
TAILWIND_EOF

# Global CSS para NativeWind v4
cat > global.css << 'CSS_EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
CSS_EOF

# Babel Config para NativeWind v4
cat > babel.config.js << 'BABEL_EOF'
module.exports = function (api) {
  api.cache(true);
  return {
    presets: [
      ["babel-preset-expo", { jsxImportSource: "nativewind" }],
      "nativewind/babel",
    ],
  };
};
BABEL_EOF

# Metro Config para NativeWind v4
cat > metro.config.js << 'METRO_EOF'
const { getDefaultConfig } = require("expo/metro-config");
const { withNativeWind } = require('nativewind/metro');

const config = getDefaultConfig(__dirname);

module.exports = withNativeWind(config, { input: './global.css' });
METRO_EOF

print_success "NativeWind v4 configurado"

# ========================================
# 10. Configurar TypeScript
# ========================================

print_step "10/13 Configurando TypeScript..."

cat > tsconfig.json << 'TS_EOF'
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "strict": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@/components/*": ["src/components/*"],
      "@/hooks/*": ["src/hooks/*"],
      "@/services/*": ["src/services/*"],
      "@/store/*": ["src/store/*"],
      "@/utils/*": ["src/utils/*"],
      "@/types/*": ["src/types/*"],
      "@/schemas/*": ["src/schemas/*"],
      "@/lib/*": ["src/lib/*"],
      "@/constants/*": ["src/constants/*"]
    }
  },
  "include": ["**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
TS_EOF

# NativeWind Types
cat > nativewind-env.d.ts << 'NATIVEWIND_TYPES_EOF'
/// <reference types="nativewind/types" />
NATIVEWIND_TYPES_EOF

print_success "TypeScript configurado"

# ========================================
# 11. Criar QueryClient
# ========================================

print_step "11/13 Criando arquivos de configuração..."

cat > src/lib/queryClient.ts << 'QUERY_EOF'
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutos
      retry: 2,
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: 1,
    },
  },
});
QUERY_EOF

# ========================================
# 12. Configurar Axios
# ========================================

cat > src/services/api/axios.config.ts << AXIOS_EOF
import axios from 'axios';
import { useAuthStore } from '@/store/authStore';

const api = axios.create({
  baseURL: process.env.EXPO_PUBLIC_API_URL || '${API_URL}',
  timeout: ${API_TIMEOUT},
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor para adicionar token
api.interceptors.request.use(
  (config) => {
    const token = useAuthStore.getState().token;
    if (token) {
      config.headers.Authorization = \`Bearer \${token}\`;
    }

    if (__DEV__) {
      console.log('[API Request]', config.method?.toUpperCase(), config.url);
    }

    return config;
  },
  (error) => {
    if (__DEV__) {
      console.error('[API Request Error]', error);
    }
    return Promise.reject(error);
  }
);

// Interceptor para tratamento de erros
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expirado ou inválido
      useAuthStore.getState().logout();
    }

    if (__DEV__) {
      console.error('[API Response Error]', error.response?.status, error.message);
    }

    return Promise.reject(error);
  }
);

export default api;
AXIOS_EOF

cat > src/services/api/index.ts << 'API_INDEX_EOF'
export { default as api } from './axios.config';
API_INDEX_EOF

# ========================================
# 13. Criar Zustand v5 Stores
# ========================================

cat > src/store/authStore.ts << 'AUTH_STORE_EOF'
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface User {
  id: string;
  name: string;
  email: string;
}

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  setAuth: (user: User, token: string) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      setAuth: (user, token) => set({ user, token, isAuthenticated: true }),
      logout: () => set({ user: null, token: null, isAuthenticated: false }),
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
AUTH_STORE_EOF

cat > src/store/themeStore.ts << 'THEME_STORE_EOF'
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

type Theme = 'light' | 'dark';

interface ThemeState {
  theme: Theme;
  toggleTheme: () => void;
  setTheme: (theme: Theme) => void;
}

export const useThemeStore = create<ThemeState>()(
  persist(
    (set) => ({
      theme: 'light',
      toggleTheme: () => set((state) => ({
        theme: state.theme === 'light' ? 'dark' : 'light'
      })),
      setTheme: (theme) => set({ theme }),
    }),
    {
      name: 'theme-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
THEME_STORE_EOF

cat > src/store/index.ts << 'STORE_INDEX_EOF'
export { useAuthStore } from './authStore';
export { useThemeStore } from './themeStore';
STORE_INDEX_EOF

# ========================================
# 14. Criar Schemas de Validação (Zod v4)
# ========================================

cat > src/schemas/common.schema.ts << 'COMMON_SCHEMA_EOF'
import { z } from 'zod';

export const emailSchema = z
  .string()
  .min(1, 'E-mail é obrigatório')
  .email('E-mail inválido');

export const passwordSchema = z
  .string()
  .min(6, 'Senha deve ter no mínimo 6 caracteres');

export const nameSchema = z
  .string()
  .min(3, 'Nome deve ter no mínimo 3 caracteres');
COMMON_SCHEMA_EOF

cat > src/schemas/auth.schema.ts << 'AUTH_SCHEMA_EOF'
import { z } from 'zod';
import { emailSchema, passwordSchema, nameSchema } from './common.schema';

export const loginSchema = z.object({
  email: emailSchema,
  password: passwordSchema,
});

export const registerSchema = loginSchema.extend({
  name: nameSchema,
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Senhas não coincidem',
  path: ['confirmPassword'],
});

export type LoginInput = z.infer<typeof loginSchema>;
export type RegisterInput = z.infer<typeof registerSchema>;
AUTH_SCHEMA_EOF

cat > src/schemas/index.ts << 'SCHEMA_INDEX_EOF'
export * from './common.schema';
export * from './auth.schema';
SCHEMA_INDEX_EOF

# ========================================
# 15. Criar Componentes UI
# ========================================

cat > src/components/ui/Button.tsx << 'BUTTON_EOF'
import React from 'react';
import { TouchableOpacity, Text, ActivityIndicator, TouchableOpacityProps } from 'react-native';

interface ButtonProps extends TouchableOpacityProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary' | 'outline';
  isLoading?: boolean;
}

export function Button({
  children,
  variant = 'primary',
  isLoading,
  disabled,
  ...props
}: ButtonProps) {
  const baseClass = 'py-3 px-6 rounded-lg items-center justify-center';
  const variantClass = {
    primary: 'bg-blue-600',
    secondary: 'bg-gray-600',
    outline: 'bg-transparent border-2 border-blue-600',
  };

  return (
    <TouchableOpacity
      className={`${baseClass} ${variantClass[variant]} ${disabled ? 'opacity-50' : ''}`}
      disabled={disabled || isLoading}
      {...props}
    >
      {isLoading ? (
        <ActivityIndicator color="white" />
      ) : (
        <Text className={`font-semibold ${variant === 'outline' ? 'text-blue-600' : 'text-white'}`}>
          {children}
        </Text>
      )}
    </TouchableOpacity>
  );
}
BUTTON_EOF

cat > src/components/ui/index.ts << 'UI_INDEX_EOF'
export { Button } from './Button';
UI_INDEX_EOF

print_success "Arquivos de configuração criados"

# ========================================
# 16. Configurar App Principal com NativeWind v4
# ========================================

print_step "12/13 Configurando app principal..."

cat > app/_layout.tsx << 'LAYOUT_EOF'
import '../global.css';
import { Stack } from 'expo-router';
import { QueryClientProvider } from '@tanstack/react-query';
import { queryClient } from '@/lib/queryClient';

export default function RootLayout() {
  return (
    <QueryClientProvider client={queryClient}>
      <Stack>
        <Stack.Screen name="index" options={{ title: 'Home' }} />
      </Stack>
    </QueryClientProvider>
  );
}
LAYOUT_EOF

cat > app/index.tsx << 'INDEX_EOF'
import { View, Text } from 'react-native';
import { Button } from '@/components/ui';

export default function Home() {
  return (
    <View className="flex-1 items-center justify-center bg-white">
      <Text className="text-3xl font-bold text-gray-800 mb-4">
        Bem-vindo! 🎉
      </Text>
      <Text className="text-gray-600 mb-8 text-center px-6">
        Seu projeto React Native está configurado e pronto para uso
      </Text>
      <Button onPress={() => alert('Funcionando!')}>
        Testar Botão
      </Button>
    </View>
  );
}
INDEX_EOF

# ========================================
# 17. Configurar Variáveis de Ambiente
# ========================================

cat > .env << ENV_EOF
EXPO_PUBLIC_API_URL=${API_URL}
EXPO_PUBLIC_API_TIMEOUT=${API_TIMEOUT}
ENV_EOF

cat > .env.example << 'ENV_EXAMPLE_EOF'
EXPO_PUBLIC_API_URL=http://localhost:3000
EXPO_PUBLIC_API_TIMEOUT=10000
ENV_EXAMPLE_EOF

# Adicionar .env ao .gitignore
if ! grep -q "^\.env$" .gitignore 2>/dev/null; then
    echo ".env" >> .gitignore
fi

# ========================================
# 18. Configurar EAS Build
# ========================================

cat > eas.json << 'EAS_EOF'
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "android": {
        "buildType": "apk"
      }
    },
    "production": {
      "autoIncrement": true
    }
  },
  "submit": {
    "production": {}
  }
}
EAS_EOF

# ========================================
# 19. Atualizar app.json
# ========================================

# Adicionar scheme e plugin reanimated ao app.json
if command -v jq &> /dev/null; then
    jq '.expo.scheme = "'${PROJECT_NAME}'" | .expo.plugins += ["react-native-reanimated/plugin"]' app.json > app.json.tmp && mv app.json.tmp app.json
else
    # Fallback sem jq - adicionar scheme
    sed -i 's/"plugins": \[/"scheme": "'${PROJECT_NAME}'",\n    "plugins": [/' app.json
    # Adicionar reanimated plugin
    sed -i 's/"plugins": \[/"plugins": [\n      "react-native-reanimated\/plugin",/' app.json
fi

# ========================================
# 20. Atualizar package.json com Scripts
# ========================================

npm pkg set scripts.android="expo start --android"
npm pkg set scripts.ios="expo start --ios"
npm pkg set scripts.web="expo start --web"
npm pkg set scripts.start="expo start"

# ========================================
# 21. Criar README
# ========================================

cat > README.md << README_EOF
# $PROJECT_NAME

Projeto React Native criado com o setup automático baseado nas melhores práticas 2024/2025.

## 🚀 Stack

- **Framework:** Expo
- **Linguagem:** TypeScript
- **Navegação:** Expo Router
- **Estilização:** NativeWind v4 (TailwindCSS)
- **HTTP/Cache:** TanStack Query v5
- **Formulários:** React Hook Form + Zod v4
- **Estado Global:** Zustand v5
- **Animações:** React Native Reanimated
- **Build:** EAS Build

## 📦 Instalação

\`\`\`bash
npm install
\`\`\`

## 🏃 Executar

\`\`\`bash
# Desenvolvimento
npm start

# Android
npm run android

# iOS
npm run ios

# Web
npm run web
\`\`\`

## 📁 Estrutura

\`\`\`
$PROJECT_NAME/
├── app/              # Rotas (Expo Router)
├── src/
│   ├── components/   # Componentes reutilizáveis
│   ├── hooks/        # Hooks customizados
│   ├── services/     # API e serviços
│   ├── store/        # Estado global (Zustand v5)
│   ├── schemas/      # Validação (Zod v4)
│   └── lib/          # Configurações
├── assets/           # Imagens, fontes, ícones
├── global.css        # Estilos globais TailwindCSS
└── .env             # Variáveis de ambiente
\`\`\`

## 🔧 Variáveis de Ambiente

Copie \`.env.example\` para \`.env\` e configure:

\`\`\`env
EXPO_PUBLIC_API_URL=${API_URL}
EXPO_PUBLIC_API_TIMEOUT=${API_TIMEOUT}
\`\`\`

## 📱 Build

\`\`\`bash
# Instalar EAS CLI
npm install -g eas-cli

# Login
eas login

# Build de desenvolvimento
eas build --profile development --platform android

# Build de produção
eas build --profile production --platform all
\`\`\`

## 📚 Documentação

- [Expo](https://docs.expo.dev/)
- [NativeWind v4](https://www.nativewind.dev/)
- [TanStack Query](https://tanstack.com/query/latest)
- [Zustand](https://docs.pmnd.rs/zustand)
- [Zod](https://zod.dev/)

---

**Criado em:** $(date +"%d/%m/%Y")
**Setup:** Automático via script
**Versões:** NativeWind v4 + Zustand v5 + Zod v4
README_EOF

print_success "App configurado"

# ========================================
# 22. Inicializar Git
# ========================================

print_step "13/13 Inicializando Git..."

if [ ! -d .git ]; then
    git init
    git add .
    git commit -m "feat: initial project setup

- Expo + TypeScript
- TanStack Query v5 + Axios
- Zustand v5 state management (auth + theme)
- NativeWind v4 (TailwindCSS)
- React Hook Form + Zod v4
- React Native Reanimated
- Complete folder structure
- Environment variables configured"
    print_success "Git inicializado"
else
    print_warning "Git já inicializado"
fi

# ========================================
# Finalização
# ========================================

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                           ║${NC}"
echo -e "${GREEN}║            ✓ Setup Concluído com Sucesso!                ║${NC}"
echo -e "${GREEN}║                                                           ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}📦 Projeto:${NC} $PROJECT_NAME"
echo -e "${BLUE}📍 Localização:${NC} $(pwd)"
echo ""

echo -e "${YELLOW}🎯 Próximos passos:${NC}"
echo ""
echo -e "  1. Entrar no diretório:"
echo -e "     ${GREEN}cd $PROJECT_NAME${NC}"
echo ""
echo -e "  2. Iniciar o projeto:"
echo -e "     ${GREEN}npm start${NC}"
echo ""
echo -e "  3. Escanear QR code no app Expo Go"
echo ""

echo -e "${BLUE}✨ Recursos incluídos:${NC}"
echo -e "  ✓ Estrutura completa de pastas"
echo -e "  ✓ TanStack Query v5 configurado"
echo -e "  ✓ Axios com interceptors"
echo -e "  ✓ Zustand v5 stores (tema + auth)"
echo -e "  ✓ Schemas de validação (Zod v4)"
echo -e "  ✓ NativeWind v4 configurado"
echo -e "  ✓ React Native Reanimated"
echo -e "  ✓ TypeScript paths configurados"
echo -e "  ✓ Autenticação configurada"
echo ""

echo -e "${BLUE}📚 Documentação útil:${NC}"
echo -e "  • Expo: https://docs.expo.dev/"
echo -e "  • NativeWind v4: https://www.nativewind.dev/"
echo -e "  • TanStack Query: https://tanstack.com/query/latest"
echo ""

echo -e "${GREEN}Bom desenvolvimento! 🚀${NC}"
echo ""
