# Convenções React Native + TypeScript + Expo

> Guia de padrões e boas práticas para desenvolvimento React Native com Expo

## Índice

1. [Nomenclatura](#1-nomenclatura)
2. [Estrutura de Pastas](#2-estrutura-de-pastas)
3. [Organização de Código](#3-organizacao-de-codigo)
4. [Boas Práticas](#4-boas-praticas)
5. [Exemplos Práticos](#5-exemplos-praticos)
6. [Navegação e Rotas](#6-navegacao-e-rotas)
7. [Git e Versionamento](#7-git-e-versionamento)

---

## 1. Nomenclatura

### 1.1 Idioma do Código

**Regra:** Todo código (variáveis, funções, componentes, arquivos) deve ser escrito em **inglês**. Português apenas para conteúdo de interface (textos, labels, mensagens).

#### ❌ Evitar
```typescript
// Português em código
const TelaAlunos = () => { ... }
export function obterAlunos() { ... }
const armazenamentoLocal = AsyncStorage;
```

#### ✅ Recomendado
```typescript
// Inglês em código
const StudentsScreen = () => { ... }
export function getStudents() { ... }
const localStorage = AsyncStorage;

// Português apenas em UI
<Text>Cadastrar Aluno</Text>
Toast.show({ text1: 'Aluno cadastrado com sucesso' });
```

---

### 1.2 Convenções de Nomenclatura

| Elemento | Convenção | Exemplo |
|----------|-----------|---------|
| **Componentes** | PascalCase | `StudentCard.tsx` |
| **Screens** | PascalCase com sufixo `Screen` | `StudentsScreen.tsx`, `HomeScreen.tsx` |
| **Hooks customizados** | camelCase com prefixo `use` | `useStudents.ts`, `useAuth.ts` |
| **Stores Zustand** | camelCase com sufixo `Store` + hook `use` | `authStore.ts`, `useAuthStore` |
| **Schemas Zod** | camelCase com sufixo `Schema` | `loginSchema`, `studentSchema` |
| **Services/API** | camelCase com sufixo `.service` ou `.api` | `student.service.ts`, `students.api.ts` |
| **Tipos e Interfaces** | PascalCase | `Student`, `StudentFilter` |
| **Utilities** | camelCase | `formatDate.ts`, `validation.ts` |
| **Pastas** | kebab-case | `student-card/`, `api-client/` |
| **Constantes** | UPPER_SNAKE_CASE | `API_BASE_URL`, `STORAGE_KEYS` |
| **Props Interfaces** | PascalCase com sufixo `Props` | `StudentCardProps` |

---

### 1.3 Variáveis e Funções

**Regra:** Seguir convenção **camelCase** do JavaScript/TypeScript.

#### Booleanos

Use prefixos descritivos: `is`, `has`, `should`, `can`

```typescript
const isLoading = true;
const hasPermission = false;
const shouldRefresh = true;
const canEdit = false;
```

#### Arrays

Sempre usar plural:

```typescript
const users = [];
const items = [];
const students = [];
const studentIds = [1, 2, 3];
```

#### Funções

Usar verbos + substantivo:

```typescript
getUserById(id: string);
createStudent(data: Student);
updateStudentProfile(id: string, data: Partial<Student>);
deleteOldRecords();
validateEmail(email: string);
fetchStudents();
```

---

### 1.4 Stores Zustand v5

**Convenção:** Nome do arquivo em camelCase + sufixo `Store`, hook com prefixo `use`.

```typescript
// src/store/authStore.ts
export const useAuthStore = create<AuthStore>()(
  persist(
    (set) => ({ ... }),
    { name: 'auth-storage' }
  )
);

// Uso
import { useAuthStore } from '@/store';
const user = useAuthStore(state => state.user);
```

---

### 1.5 Schemas Zod v4

**Convenção:** Nome em camelCase + sufixo `Schema`.

```typescript
// src/schemas/auth.schema.ts
export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

export type LoginInput = z.infer<typeof loginSchema>;
```

---

## 2. Estrutura de Pastas

### 2.1 Estrutura Geral

```
app/                          # 🔴 FUNDAMENTAL - Rotas (Expo Router)
├── (auth)/                   # Grupo de rotas de autenticação
│   ├── login.tsx
│   └── register.tsx
├── (tabs)/                   # Grupo de rotas com tabs
│   ├── _layout.tsx           # Layout das tabs
│   ├── index.tsx             # Home
│   └── profile.tsx
├── _layout.tsx               # 🔴 FUNDAMENTAL - Layout raiz + providers
└── index.tsx                 # 🔴 FUNDAMENTAL - Página inicial

src/
├── components/               # 🔴 FUNDAMENTAL - Componentes reutilizáveis
│   ├── ui/                   # 🔴 FUNDAMENTAL - Componentes base
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   └── index.ts
│   ├── forms/                # 🟡 SITUACIONAL - Componentes de formulário
│   └── shared/               # 🟡 SITUACIONAL - Componentes compartilhados
│
├── features/                 # 🔴 FUNDAMENTAL - Módulos por funcionalidade
│   └── students/
│       ├── components/       # 🟡 SITUACIONAL - Componentes da feature
│       ├── hooks/            # 🟡 SITUACIONAL - Hooks da feature
│       ├── types/            # 🟡 SITUACIONAL - Tipos específicos
│       ├── screens/          # 🟡 SITUACIONAL - Telas da feature
│       └── services/         # 🟡 SITUACIONAL - API calls da feature
│
├── hooks/                    # 🟡 SITUACIONAL - Hooks globais
│
├── lib/                      # 🔴 FUNDAMENTAL - Configurações de libs
│   └── queryClient.ts        # TanStack Query config
│
├── services/                 # 🔴 FUNDAMENTAL - Serviços globais
│   └── api/
│       ├── axios.config.ts   # 🔴 FUNDAMENTAL - Axios configurado
│       └── index.ts
│
├── store/                    # 🔴 FUNDAMENTAL - Estado global (Zustand v5)
│   ├── authStore.ts
│   ├── themeStore.ts
│   └── index.ts
│
├── schemas/                  # 🔴 FUNDAMENTAL - Schemas de validação (Zod v4)
│   ├── common.schema.ts
│   ├── auth.schema.ts
│   └── index.ts
│
├── types/                    # 🟡 SITUACIONAL - Tipos globais
├── utils/                    # 🟡 SITUACIONAL - Funções utilitárias
└── constants/                # 🟡 SITUACIONAL - Constantes da aplicação

assets/                       # 🔴 FUNDAMENTAL - Assets estáticos
├── images/
├── fonts/
└── icons/

global.css                    # 🔴 FUNDAMENTAL - TailwindCSS (NativeWind v4)
metro.config.js               # 🔴 FUNDAMENTAL - Metro + NativeWind v4
babel.config.js               # 🔴 FUNDAMENTAL - Babel config
tailwind.config.js            # 🔴 FUNDAMENTAL - Tailwind config
nativewind-env.d.ts          # 🔴 FUNDAMENTAL - Types do NativeWind
```

**Legenda:**
- 🔴 **FUNDAMENTAL** - Deve existir em todo projeto
- 🟡 **SITUACIONAL** - Criar apenas quando necessário

---

### 2.2 Estrutura de Features

**Princípio:** Criar subpastas apenas quando houver **múltiplos arquivos**.

#### ❌ Evitar - Pastas desnecessárias
```
features/students/
├── components/
│   └── StudentCard.tsx       # apenas 1 arquivo
├── hooks/
│   └── index.ts              # apenas 1 arquivo
└── screens/
    └── index.tsx             # apenas 1 arquivo
```

#### ✅ Recomendado - Estrutura enxuta
```
features/students/
├── components/               # múltiplos componentes
│   ├── StudentCard.tsx
│   ├── StudentList.tsx
│   └── StudentFilters.tsx
├── useStudents.ts            # hook direto (único)
├── students.api.ts           # API direto (único)
└── screens/
    ├── StudentsScreen.tsx
    └── StudentDetailScreen.tsx
```

---

### 2.3 Organização de Tipos

**Regra:** Separar tipos em arquivos dedicados, não misturar com código.

#### ❌ Evitar - Tipos misturados
```typescript
// services/student.service.ts
export interface Student {
  id: string;
  name: string;
}

export const studentService = {
  list: async (): Promise<Student[]> => { ... }
};
```

#### ✅ Recomendado - Separação clara
```typescript
// types/student.types.ts
export interface Student {
  id: string;
  name: string;
  email: string;
  phone: string;
}

export interface StudentFilter {
  name?: string;
  classId?: string;
}

// services/student.service.ts
import { Student, StudentFilter } from '@/types/student.types';

export const studentService = {
  list: async (filter?: StudentFilter): Promise<Student[]> => { ... },
  getById: async (id: string): Promise<Student> => { ... },
};
```

---

## 3. Organização de Código

### 3.1 Componentes React Native

**Estrutura padrão de um componente:**

```typescript
// Ordem de imports
import React from 'react';                    // 1. React
import { View, Text, TouchableOpacity } from 'react-native'; // 2. React Native
import { useRouter } from 'expo-router';      // 3. Libs externas
import { useAuthStore } from '@/store';       // 4. Stores/hooks internos
import { Button } from '@/components/ui';     // 5. Componentes internos
import type { StudentCardProps } from './types'; // 6. Tipos

// Props interface
interface StudentCardProps {
  student: Student;
  onPress?: (id: string) => void;
}

// Componente
export function StudentCard({ student, onPress }: StudentCardProps) {
  // 1. Hooks externos (router, store)
  const router = useRouter();
  const theme = useThemeStore(state => state.theme);

  // 2. Hooks de estado
  const [isExpanded, setIsExpanded] = useState(false);

  // 3. Hooks customizados
  const { handleDelete } = useStudentActions();

  // 4. Callbacks
  const handlePress = () => {
    onPress?.(student.id);
  };

  // 5. Effects
  useEffect(() => {
    // ...
  }, []);

  // 6. Render
  return (
    <View className="bg-white p-4 rounded-lg">
      <Text className="text-lg font-bold">{student.name}</Text>
      <TouchableOpacity onPress={handlePress}>
        <Text className="text-blue-500">Ver detalhes</Text>
      </TouchableOpacity>
    </View>
  );
}
```

---

### 3.2 Expo Router (Navegação)

**Estrutura de rotas baseada em arquivos:**

```
app/
├── _layout.tsx               # Layout raiz
├── index.tsx                 # /
├── about.tsx                 # /about
├── (auth)/                   # Grupo sem afetar URL
│   ├── _layout.tsx
│   ├── login.tsx             # /login
│   └── register.tsx          # /register
├── (tabs)/                   # Grupo com tabs
│   ├── _layout.tsx           # Configuração das tabs
│   ├── index.tsx             # / (home tab)
│   └── profile.tsx           # /profile (profile tab)
├── students/
│   ├── index.tsx             # /students
│   └── [id].tsx              # /students/:id (dinâmica)
```

**Layout raiz (`app/_layout.tsx`):**

```typescript
import '../global.css'; // 🔴 OBRIGATÓRIO para NativeWind v4
import { Slot } from 'expo-router';
import { QueryClientProvider } from '@tanstack/react-query';
import { queryClient } from '@/lib/queryClient';

export default function RootLayout() {
  return (
    <QueryClientProvider client={queryClient}>
      <Slot />
    </QueryClientProvider>
  );
}
```

---

### 3.3 Zustand v5 (Estado Global)

**Padrão de criação de stores:**

```typescript
// src/store/authStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface User {
  id: string;
  name: string;
  email: string;
}

interface AuthStore {
  user: User | null;
  token: string | null;
  login: (user: User, token: string) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthStore>()(
  persist(
    (set) => ({
      user: null,
      token: null,

      login: (user, token) => {
        set({ user, token });
      },

      logout: () => {
        set({ user: null, token: null });
      },
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

**Uso otimizado com seletores:**

#### ❌ Evitar - Re-render desnecessário
```typescript
const Component = () => {
  // Re-renderiza quando QUALQUER estado muda
  const { user, token, login, logout } = useAuthStore();

  return <Text>{user?.name}</Text>;
};
```

#### ✅ Recomendado - Seletor específico
```typescript
const Component = () => {
  // Re-renderiza APENAS quando user muda
  const user = useAuthStore(state => state.user);
  const login = useAuthStore(state => state.login);

  return <Text>{user?.name}</Text>;
};
```

---

### 3.4 TanStack Query v5

**Configuração (`src/lib/queryClient.ts`):**

```typescript
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutos
      retry: 2,
      refetchOnWindowFocus: false,
    },
  },
});
```

**Uso com hooks:**

```typescript
// hooks/useStudents.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/services/api';

export function useStudents() {
  return useQuery({
    queryKey: ['students'],
    queryFn: async () => {
      const response = await api.get<Student[]>('/students');
      return response.data;
    },
  });
}

export function useCreateStudent() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (data: Student) => {
      return api.post('/students', data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['students'] });
    },
  });
}
```

---

### 3.5 React Hook Form + Zod v4

**Schema de validação:**

```typescript
// schemas/student.schema.ts
import { z } from 'zod';

export const studentSchema = z.object({
  name: z.string().min(3, 'Nome deve ter no mínimo 3 caracteres'),
  email: z.string().email('Email inválido'),
  phone: z.string().regex(/^\d{10,11}$/, 'Telefone inválido'),
  birthDate: z.string(),
});

export type StudentInput = z.infer<typeof studentSchema>;
```

**Formulário:**

```typescript
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { studentSchema, StudentInput } from '@/schemas/student.schema';

export function StudentForm() {
  const { control, handleSubmit, formState: { errors } } = useForm<StudentInput>({
    resolver: zodResolver(studentSchema),
  });

  const onSubmit = async (data: StudentInput) => {
    console.log(data);
  };

  return (
    <View className="p-4">
      <Controller
        control={control}
        name="name"
        render={({ field: { onChange, value } }) => (
          <View>
            <TextInput
              value={value}
              onChangeText={onChange}
              placeholder="Nome"
              className="border border-gray-300 rounded p-2"
            />
            {errors.name && (
              <Text className="text-red-500 text-sm">{errors.name.message}</Text>
            )}
          </View>
        )}
      />

      <TouchableOpacity
        onPress={handleSubmit(onSubmit)}
        className="bg-blue-500 p-3 rounded mt-4"
      >
        <Text className="text-white text-center">Salvar</Text>
      </TouchableOpacity>
    </View>
  );
}
```

---

### 3.6 Axios com Interceptors

**Configuração (`src/services/api/axios.config.ts`):**

```typescript
import axios from 'axios';
import { useAuthStore } from '@/store';

const API_URL = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000';
const API_TIMEOUT = Number(process.env.EXPO_PUBLIC_API_TIMEOUT) || 10000;

export const api = axios.create({
  baseURL: API_URL,
  timeout: API_TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor de request - adiciona token
api.interceptors.request.use(
  (config) => {
    const token = useAuthStore.getState().token;

    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    if (__DEV__) {
      console.log(`[API] ${config.method?.toUpperCase()} ${config.url}`);
    }

    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Interceptor de response - trata erros
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      // Logout automático em caso de 401
      useAuthStore.getState().logout();
    }

    if (__DEV__) {
      console.error('[API Error]', error.response?.data || error.message);
    }

    return Promise.reject(error);
  }
);
```

---

### 3.7 NativeWind v4 (TailwindCSS)

**Uso de classes:**

```typescript
import { View, Text, TouchableOpacity } from 'react-native';

export function Card() {
  return (
    <View className="bg-white p-4 rounded-lg shadow-md mb-4">
      <Text className="text-xl font-bold text-gray-800 mb-2">
        Título
      </Text>
      <Text className="text-gray-600 mb-4">
        Descrição do card
      </Text>
      <TouchableOpacity className="bg-blue-500 p-3 rounded">
        <Text className="text-white text-center font-semibold">
          Ação
        </Text>
      </TouchableOpacity>
    </View>
  );
}
```

**Classes condicionais:**

```typescript
import clsx from 'clsx'; // ou use library 'classnames'

export function Button({ variant = 'primary', disabled }: ButtonProps) {
  return (
    <TouchableOpacity
      className={clsx(
        'p-3 rounded',
        variant === 'primary' && 'bg-blue-500',
        variant === 'secondary' && 'bg-gray-500',
        disabled && 'opacity-50'
      )}
      disabled={disabled}
    >
      <Text className="text-white text-center">Clique aqui</Text>
    </TouchableOpacity>
  );
}
```

---

## 4. Boas Práticas

### 4.1 Performance - FlatList vs ScrollView

**Regra:** Usar `FlatList` para listas dinâmicas, `ScrollView` apenas para conteúdo estático pequeno.

#### ❌ Evitar - ScrollView com .map()
```typescript
<ScrollView>
  {students.map(student => (
    <StudentCard key={student.id} student={student} />
  ))}
</ScrollView>
```

#### ✅ Recomendado - FlatList
```typescript
<FlatList
  data={students}
  keyExtractor={(item) => item.id}
  renderItem={({ item }) => <StudentCard student={item} />}
  initialNumToRender={10}
  maxToRenderPerBatch={10}
  windowSize={5}
  removeClippedSubviews={true}
  ListEmptyComponent={<EmptyState />}
  ListFooterComponent={isLoading ? <LoadingSpinner /> : null}
/>
```

---

### 4.2 Otimização com React.memo

**Quando usar:** Componentes que recebem props que raramente mudam.

```typescript
interface StudentCardProps {
  student: Student;
  onPress: (id: string) => void;
}

export const StudentCard = React.memo(({ student, onPress }: StudentCardProps) => {
  return (
    <TouchableOpacity onPress={() => onPress(student.id)}>
      <View className="p-4 bg-white rounded">
        <Text>{student.name}</Text>
      </View>
    </TouchableOpacity>
  );
}, (prevProps, nextProps) => {
  // Re-renderiza apenas se student.id mudou
  return prevProps.student.id === nextProps.student.id;
});
```

---

### 4.3 Hooks Customizados

**Quando criar:** Lógica reutilizável que envolve estado ou efeitos.

```typescript
// hooks/useStudents.ts
import { useState, useEffect } from 'react';
import { api } from '@/services/api';

export function useStudents() {
  const [students, setStudents] = useState<Student[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadStudents();
  }, []);

  const loadStudents = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const response = await api.get<Student[]>('/students');
      setStudents(response.data);
    } catch (err) {
      setError('Erro ao carregar alunos');
    } finally {
      setIsLoading(false);
    }
  };

  const refresh = () => {
    loadStudents();
  };

  return { students, isLoading, error, refresh };
}
```

---

### 4.4 Error Handling

**Padrão de tratamento de erros:**

```typescript
import { AxiosError } from 'axios';

export function isApiError(error: unknown): error is AxiosError {
  return error instanceof AxiosError;
}

// Uso
try {
  const result = await api.get('/students');
} catch (error) {
  if (isApiError(error)) {
    const message = error.response?.data?.message || 'Erro ao buscar alunos';
    Toast.show({
      type: 'error',
      text1: 'Erro',
      text2: message,
    });
  } else {
    Toast.show({
      type: 'error',
      text1: 'Erro',
      text2: 'Erro desconhecido',
    });
  }
}
```

---

### 4.5 AsyncStorage (Persistência)

**Evitar uso direto, usar Zustand persist:**

#### ❌ Evitar - Uso direto
```typescript
// Espalhado pelo código
await AsyncStorage.setItem('user', JSON.stringify(user));
const userData = await AsyncStorage.getItem('user');
const user = JSON.parse(userData || '{}');
```

#### ✅ Recomendado - Zustand persist
```typescript
// store/authStore.ts (configurado uma vez)
export const useAuthStore = create<AuthStore>()(
  persist(
    (set) => ({
      user: null,
      login: (user) => set({ user }),
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);

// Uso em componentes (automático)
const user = useAuthStore(state => state.user);
```

---

### 4.6 Variáveis de Ambiente

**Arquivo `.env`:**

```env
EXPO_PUBLIC_API_URL=https://api.example.com
EXPO_PUBLIC_API_TIMEOUT=10000
```

**⚠️ IMPORTANTE:** Variáveis Expo devem ter prefixo `EXPO_PUBLIC_`

**Tipagem (`vite-env.d.ts`):**

```typescript
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly EXPO_PUBLIC_API_URL: string
  readonly EXPO_PUBLIC_API_TIMEOUT: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
```

**Uso:**

```typescript
const API_URL = process.env.EXPO_PUBLIC_API_URL;
const TIMEOUT = Number(process.env.EXPO_PUBLIC_API_TIMEOUT);
```

---

### 4.7 Acessibilidade

**Sempre adicionar props de acessibilidade:**

```typescript
<TouchableOpacity
  accessible={true}
  accessibilityLabel="Botão para cadastrar aluno"
  accessibilityHint="Toque duas vezes para abrir o formulário"
  accessibilityRole="button"
>
  <Text>Cadastrar</Text>
</TouchableOpacity>

<TextInput
  accessible={true}
  accessibilityLabel="Campo de email"
  accessibilityHint="Digite seu email"
  placeholder="Email"
/>
```

---

## 5. Exemplos Práticos

### 5.1 Feature Completa (CRUD de Alunos)

**Estrutura:**

```
features/students/
├── components/
│   ├── StudentCard.tsx
│   ├── StudentList.tsx
│   └── StudentFilters.tsx
├── hooks/
│   ├── useStudents.ts
│   └── useStudentForm.ts
├── types/
│   └── student.types.ts
├── screens/
│   ├── StudentsScreen.tsx
│   └── StudentDetailScreen.tsx
└── students.api.ts
```

---

**`types/student.types.ts`**

```typescript
export interface Student {
  id: string;
  name: string;
  email: string;
  phone: string;
  birthDate: string;
}

export interface StudentFilter {
  name?: string;
  classId?: string;
}
```

---

**`students.api.ts`**

```typescript
import { api } from '@/services/api';
import { Student, StudentFilter } from './types/student.types';

export const studentsApi = {
  list: async (filter?: StudentFilter) => {
    const response = await api.get<Student[]>('/students', {
      params: filter,
    });
    return response.data;
  },

  getById: async (id: string) => {
    const response = await api.get<Student>(`/students/${id}`);
    return response.data;
  },

  create: async (data: Student) => {
    const response = await api.post<Student>('/students', data);
    return response.data;
  },

  update: async (id: string, data: Partial<Student>) => {
    const response = await api.put<Student>(`/students/${id}`, data);
    return response.data;
  },

  delete: async (id: string) => {
    await api.delete(`/students/${id}`);
  },
};
```

---

**`hooks/useStudents.ts`**

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { studentsApi } from '../students.api';
import { Student, StudentFilter } from '../types/student.types';
import Toast from 'react-native-toast-message';

export function useStudents(filter?: StudentFilter) {
  return useQuery({
    queryKey: ['students', filter],
    queryFn: () => studentsApi.list(filter),
  });
}

export function useCreateStudent() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: Student) => studentsApi.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['students'] });
      Toast.show({
        type: 'success',
        text1: 'Sucesso',
        text2: 'Aluno cadastrado com sucesso',
      });
    },
    onError: () => {
      Toast.show({
        type: 'error',
        text1: 'Erro',
        text2: 'Erro ao cadastrar aluno',
      });
    },
  });
}

export function useDeleteStudent() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => studentsApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['students'] });
      Toast.show({
        type: 'success',
        text1: 'Sucesso',
        text2: 'Aluno deletado com sucesso',
      });
    },
  });
}
```

---

**`components/StudentCard.tsx`**

```typescript
import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { Student } from '../types/student.types';

interface StudentCardProps {
  student: Student;
  onDelete?: (id: string) => void;
}

export const StudentCard = React.memo(({ student, onDelete }: StudentCardProps) => {
  const router = useRouter();

  const handlePress = () => {
    router.push(`/students/${student.id}`);
  };

  return (
    <View className="bg-white p-4 rounded-lg shadow-md mb-3">
      <TouchableOpacity onPress={handlePress}>
        <Text className="text-lg font-bold text-gray-800">
          {student.name}
        </Text>
        <Text className="text-gray-600 text-sm mt-1">
          {student.email}
        </Text>
        <Text className="text-gray-500 text-sm">
          {student.phone}
        </Text>
      </TouchableOpacity>

      {onDelete && (
        <TouchableOpacity
          onPress={() => onDelete(student.id)}
          className="mt-3 bg-red-500 p-2 rounded"
          accessibilityLabel={`Deletar aluno ${student.name}`}
          accessibilityRole="button"
        >
          <Text className="text-white text-center text-sm">
            Deletar
          </Text>
        </TouchableOpacity>
      )}
    </View>
  );
});
```

---

**`screens/StudentsScreen.tsx`**

```typescript
import { View, FlatList, ActivityIndicator, RefreshControl } from 'react-native';
import { useRouter } from 'expo-router';
import { useStudents, useDeleteStudent } from '../hooks/useStudents';
import { StudentCard } from '../components/StudentCard';
import { Button } from '@/components/ui';

export default function StudentsScreen() {
  const router = useRouter();
  const { data: students, isLoading, refetch } = useStudents();
  const deleteMutation = useDeleteStudent();

  const handleDelete = (id: string) => {
    // Aqui você poderia adicionar um modal de confirmação
    deleteMutation.mutate(id);
  };

  const handleAdd = () => {
    router.push('/students/new');
  };

  if (isLoading) {
    return (
      <View className="flex-1 justify-center items-center">
        <ActivityIndicator size="large" color="#3B82F6" />
      </View>
    );
  }

  return (
    <View className="flex-1 bg-gray-100">
      <View className="p-4">
        <Button onPress={handleAdd}>
          Adicionar Aluno
        </Button>
      </View>

      <FlatList
        data={students}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <StudentCard
            student={item}
            onDelete={handleDelete}
          />
        )}
        contentContainerStyle={{ padding: 16 }}
        refreshControl={
          <RefreshControl
            refreshing={isLoading}
            onRefresh={() => refetch()}
          />
        }
        ListEmptyComponent={
          <View className="p-8 items-center">
            <Text className="text-gray-500">Nenhum aluno cadastrado</Text>
          </View>
        }
      />
    </View>
  );
}
```

---

**`screens/StudentDetailScreen.tsx`**

```typescript
import { View, Text, ActivityIndicator } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useQuery } from '@tanstack/react-query';
import { studentsApi } from '../students.api';
import { Button } from '@/components/ui';

export default function StudentDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();

  const { data: student, isLoading } = useQuery({
    queryKey: ['students', id],
    queryFn: () => studentsApi.getById(id),
    enabled: !!id,
  });

  if (isLoading) {
    return (
      <View className="flex-1 justify-center items-center">
        <ActivityIndicator size="large" />
      </View>
    );
  }

  if (!student) {
    return (
      <View className="flex-1 justify-center items-center">
        <Text>Aluno não encontrado</Text>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-white p-4">
      <Text className="text-2xl font-bold mb-4">{student.name}</Text>

      <View className="mb-3">
        <Text className="text-gray-600 text-sm">Email</Text>
        <Text className="text-lg">{student.email}</Text>
      </View>

      <View className="mb-3">
        <Text className="text-gray-600 text-sm">Telefone</Text>
        <Text className="text-lg">{student.phone}</Text>
      </View>

      <View className="mb-3">
        <Text className="text-gray-600 text-sm">Data de Nascimento</Text>
        <Text className="text-lg">{student.birthDate}</Text>
      </View>

      <Button onPress={() => router.push(`/students/${id}/edit`)}>
        Editar
      </Button>
    </View>
  );
}
```

---

### 5.2 Formulário com React Hook Form + Zod

**`screens/StudentFormScreen.tsx`**

```typescript
import { View, Text, TextInput, TouchableOpacity, ScrollView } from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { studentSchema, type StudentInput } from '@/schemas/student.schema';
import { useCreateStudent } from '../hooks/useStudents';

export default function StudentFormScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id?: string }>();
  const createMutation = useCreateStudent();

  const {
    control,
    handleSubmit,
    formState: { errors },
  } = useForm<StudentInput>({
    resolver: zodResolver(studentSchema),
  });

  const onSubmit = async (data: StudentInput) => {
    try {
      await createMutation.mutateAsync(data);
      router.back();
    } catch (error) {
      // Error já tratado no hook
    }
  };

  return (
    <ScrollView className="flex-1 bg-white p-4">
      <Text className="text-2xl font-bold mb-6">
        {id ? 'Editar Aluno' : 'Novo Aluno'}
      </Text>

      <View className="mb-4">
        <Text className="text-gray-700 mb-2">Nome</Text>
        <Controller
          control={control}
          name="name"
          render={({ field: { onChange, value } }) => (
            <View>
              <TextInput
                value={value}
                onChangeText={onChange}
                placeholder="Nome completo"
                className="border border-gray-300 rounded p-3 text-base"
              />
              {errors.name && (
                <Text className="text-red-500 text-sm mt-1">
                  {errors.name.message}
                </Text>
              )}
            </View>
          )}
        />
      </View>

      <View className="mb-4">
        <Text className="text-gray-700 mb-2">Email</Text>
        <Controller
          control={control}
          name="email"
          render={({ field: { onChange, value } }) => (
            <View>
              <TextInput
                value={value}
                onChangeText={onChange}
                placeholder="email@exemplo.com"
                keyboardType="email-address"
                autoCapitalize="none"
                className="border border-gray-300 rounded p-3 text-base"
              />
              {errors.email && (
                <Text className="text-red-500 text-sm mt-1">
                  {errors.email.message}
                </Text>
              )}
            </View>
          )}
        />
      </View>

      <View className="mb-4">
        <Text className="text-gray-700 mb-2">Telefone</Text>
        <Controller
          control={control}
          name="phone"
          render={({ field: { onChange, value } }) => (
            <View>
              <TextInput
                value={value}
                onChangeText={onChange}
                placeholder="(00) 00000-0000"
                keyboardType="phone-pad"
                className="border border-gray-300 rounded p-3 text-base"
              />
              {errors.phone && (
                <Text className="text-red-500 text-sm mt-1">
                  {errors.phone.message}
                </Text>
              )}
            </View>
          )}
        />
      </View>

      <TouchableOpacity
        onPress={handleSubmit(onSubmit)}
        disabled={createMutation.isPending}
        className="bg-blue-500 p-4 rounded mt-4"
      >
        <Text className="text-white text-center font-semibold text-base">
          {createMutation.isPending ? 'Salvando...' : 'Salvar'}
        </Text>
      </TouchableOpacity>
    </ScrollView>
  );
}
```

---

## 6. Navegação e Rotas

### 6.1 Expo Router - Estrutura de Arquivos

**Rotas baseadas em arquivos:**

| Arquivo | Rota | Descrição |
|---------|------|-----------|
| `app/index.tsx` | `/` | Página inicial |
| `app/about.tsx` | `/about` | Página sobre |
| `app/students/index.tsx` | `/students` | Lista de alunos |
| `app/students/[id].tsx` | `/students/:id` | Detalhe do aluno (dinâmica) |
| `app/(auth)/login.tsx` | `/login` | Login (grupo sem afetar URL) |
| `app/(tabs)/_layout.tsx` | - | Layout de tabs |

---

### 6.2 Navegação Programática

```typescript
import { useRouter } from 'expo-router';

export function MyComponent() {
  const router = useRouter();

  // Push (adiciona à pilha)
  const goToStudent = () => {
    router.push('/students/123');
  };

  // Replace (substitui a tela atual)
  const replaceWithHome = () => {
    router.replace('/home');
  };

  // Back (volta uma tela)
  const goBack = () => {
    router.back();
  };

  // Com parâmetros
  const goToStudentWithParams = () => {
    router.push({
      pathname: '/students/[id]',
      params: { id: '123', name: 'João' },
    });
  };

  return (
    <View>
      <Button onPress={goToStudent}>Ver Aluno</Button>
      <Button onPress={goBack}>Voltar</Button>
    </View>
  );
}
```

---

### 6.3 Parâmetros de Rota

**Receber parâmetros:**

```typescript
// app/students/[id].tsx
import { useLocalSearchParams } from 'expo-router';

export default function StudentDetail() {
  const { id, name } = useLocalSearchParams<{ id: string; name?: string }>();

  return (
    <View>
      <Text>ID: {id}</Text>
      <Text>Nome: {name}</Text>
    </View>
  );
}
```

---

### 6.4 Rotas Protegidas (Autenticação)

```typescript
// app/_layout.tsx
import { Redirect, Slot } from 'expo-router';
import { useAuthStore } from '@/store';

export default function RootLayout() {
  const token = useAuthStore(state => state.token);

  if (!token) {
    return <Redirect href="/login" />;
  }

  return <Slot />;
}
```

---

### 6.5 Tabs Navigation

**`app/(tabs)/_layout.tsx`**

```typescript
import { Tabs } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: '#3B82F6',
        tabBarInactiveTintColor: '#9CA3AF',
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="home" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Perfil',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="person" size={size} color={color} />
          ),
        }}
      />
    </Tabs>
  );
}
```

---

## 7. Git e Versionamento

### 7.1 Branches

Siga o padrão de nomenclatura:

```
feature/add-user-authentication
feature/implement-student-crud
bugfix/fix-login-redirect
bugfix/correct-form-validation
hotfix/patch-security-issue
release/v1.2.0
```

---

### 7.2 Commits (Conventional Commits)

Use o formato Conventional Commits:

```
feat: add student CRUD
feat(auth): implement OAuth2 login
fix: resolve navigation crash on Android
fix(forms): correct email validation
docs: update README with setup instructions
style: format code with prettier
refactor: simplify student store logic
test: add unit tests for student service
chore: update dependencies to latest versions
perf: optimize FlatList rendering
```

**Tipos de commit:**
- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Documentação
- `style`: Formatação (sem mudança de lógica)
- `refactor`: Refatoração (sem nova funcionalidade ou correção)
- `test`: Testes
- `chore`: Tarefas gerais (deps, config)
- `perf`: Melhorias de performance

---

## Checklist de Revisão de Código

Antes de abrir um Pull Request, verifique:

- [ ] Todo código está em **inglês** (exceto textos de UI)
- [ ] Nomenclatura seguindo convenções (PascalCase, camelCase, kebab-case)
- [ ] Componentes com sufixo correto (`Screen`, `Props`)
- [ ] Stores Zustand com `useXxxStore` pattern
- [ ] Schemas Zod com sufixo `Schema`
- [ ] Booleanos com prefixos `is`, `has`, `should`, `can`
- [ ] Arrays no plural
- [ ] Não há uso de `any` sem justificativa
- [ ] Tipos/interfaces em arquivos `.types.ts` separados
- [ ] `FlatList` para listas dinâmicas (não `ScrollView` + `.map()`)
- [ ] `React.memo` em componentes de lista quando apropriado
- [ ] Hooks customizados para lógica reutilizável
- [ ] TanStack Query para data fetching (não estado local)
- [ ] Zustand persist ao invés de AsyncStorage direto
- [ ] NativeWind classes consistentes (não inline styles)
- [ ] Props de acessibilidade (`accessibilityLabel`, `accessibilityRole`)
- [ ] Error handling adequado (não try-catch silencioso)
- [ ] Variáveis de ambiente com prefixo `EXPO_PUBLIC_`
- [ ] `import '../global.css'` no layout raiz
- [ ] Commits seguindo Conventional Commits
- [ ] Branches com nomenclatura correta
- [ ] Sem `console.log` em produção

---

## Diferenças React Web vs React Native

| Aspecto | React Web | React Native |
|---------|-----------|--------------|
| **Componentes** | `div`, `span`, `button` | `View`, `Text`, `TouchableOpacity` |
| **Estilização** | CSS classes, styled-components | NativeWind (className) ou StyleSheet |
| **Listas** | `.map()` com `key` | `FlatList`, `SectionList` |
| **Navegação** | React Router (`BrowserRouter`) | Expo Router (file-based) |
| **Formulários** | `<form>`, `<input>` | `TextInput` + `Controller` |
| **Storage** | `localStorage`, `sessionStorage` | `AsyncStorage` |
| **HTTP** | `fetch`, `axios` | `axios` (mesmo) |
| **Estado Global** | Context, Redux, Zustand | Zustand (mesmo) |
| **Animações** | CSS transitions, Framer Motion | React Native Reanimated |
| **Scroll** | `overflow: scroll` | `ScrollView`, `FlatList` |
| **Touch** | `onClick` | `onPress` |
| **Env Vars** | `VITE_`, `REACT_APP_` | `EXPO_PUBLIC_` |

---

## Referências

- [Expo Documentation](https://docs.expo.dev/)
- [React Native Documentation](https://reactnative.dev/)
- [Expo Router](https://docs.expo.dev/router/introduction/)
- [NativeWind v4](https://www.nativewind.dev/)
- [TanStack Query](https://tanstack.com/query/latest)
- [Zustand](https://docs.pmnd.rs/zustand)
- [React Hook Form](https://react-hook-form.com/)
- [Zod](https://zod.dev/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

---

**Última atualização:** 12/12/2024 15:45
