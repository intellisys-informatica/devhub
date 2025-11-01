# Padrões React + TypeScript

> Convenções e boas práticas para projetos React + TypeScript

## Índice

1. [Nomenclatura](#1-nomenclatura)
2. [Estrutura de Pastas](#2-estrutura-de-pastas)
3. [Organização de Código](#3-organiza%C3%A7%C3%A3o-de-c%C3%B3digo)
4. [Boas Práticas](#4-boas-pr%C3%A1ticas)
5. [Exemplos Práticos](#5-exemplos-pr%C3%A1ticos)
6. [CSS Classes](#6-css-classes)
7. [Git e Versionamento](#7-git-e-versionamento)

---

## 1. Nomenclatura

### 1.1 Idioma do Código

**Regra:** Todo código (variáveis, funções, classes, arquivos) deve ser escrito em **inglês**. Português apenas para conteúdo de interface (textos, labels, mensagens).

#### ❌ Evitar
```typescript
// Português em código
const ProvedorSessao = () => { ... }
export function obterSessao() { ... }
const servicoAluno = new ServicoAluno();
servicoAluno.Listar();
```

#### ✅ Recomendado
```typescript
// Inglês em código
const SessionProvider = () => { ... }
export function getSession() { ... }
const studentService = new StudentService();
studentService.list();

// Português apenas em UI
<Button>Cadastrar Aluno</Button>
toast.success('Aluno cadastrado com sucesso');
```

---

### 1.2 Convenções de Nomenclatura

| Elemento | Convenção | Exemplo |
|----------|-----------|---------|
| **Componentes** | PascalCase | `StudentForm.tsx` |
| **Hooks customizados** | camelCase com prefixo `use` | `useStudentForm.ts` |
| **Services/API** | camelCase com sufixo `.service` ou `.api` | `student.service.ts`, `students.api.ts` |
| **Tipos e Interfaces** | PascalCase com sufixo `.types` | `Student.types.ts` |
| **Utilities** | camelCase | `formatDate.ts`, `validation.ts` |
| **Pastas** | kebab-case | `student-form/`, `api-client/` |
| **Constantes** | UPPER_SNAKE_CASE | `MAX_RETRY_ATTEMPTS` |
| **Testes** | Nome do arquivo + `.test` ou `.spec` | `StudentForm.test.tsx`, `formatDate.spec.ts` |

---

### 1.3 Variáveis e Funções

**Regra:** Seguir convenção **camelCase** do JavaScript/TypeScript.

#### Booleanos

Use prefixos descritivos: `is`, `has`, `should`, `can`

```typescript
const isLoading = true;
const hasPermission = false;
const shouldUpdate = true;
const canEdit = false;
```

#### Arrays

Sempre usar plural:

```typescript
const users = [];
const items = [];
const products = [];
const studentIds = [1, 2, 3];
```

#### Funções

Usar verbos + substantivo:

```typescript
getUserById(id: string);
createNewUser(data: User);
updateUserProfile(id: string, data: Partial<User>);
deleteOldRecords();
validateEmail(email: string);
fetchStudents();
```

#### Métodos de Classes

**Regra:** Sempre **camelCase**, nunca PascalCase.

##### ❌ Evitar
```typescript
// Primeira letra maiúscula (não é padrão JS)
class StudentService {
  Listar() { ... }
  Obter(id: string) { ... }
  Deletar(id: string) { ... }
  Cadastrar(data: Student) { ... }
}
```

##### ✅ Recomendado
```typescript
// camelCase padrão
class StudentService {
  list(filter?: StudentFilter) { ... }
  getById(id: string) { ... }
  delete(id: string) { ... }
  create(data: Student) { ... }
  update(id: string, data: Student) { ... }
}
```

---

## 2. Estrutura de Pastas

### 2.1 Estrutura Geral

```
src/
├── app/                  # 🔴 FUNDAMENTAL - Configuração da aplicação
│   ├── providers/        # Context providers
│   ├── routes/           # Definições de rotas
│   └── styles/           # Estilos globais
│
├── features/             # 🔴 FUNDAMENTAL - Módulos por funcionalidade
│   └── students/
│       ├── api/          # 🟡 SITUACIONAL - Chamadas API específicas da feature
│       ├── components/   # 🟡 SITUACIONAL - Componentes da feature
│       ├── hooks/        # 🟡 SITUACIONAL - Hooks da feature
│       ├── types/        # 🟡 SITUACIONAL - Tipos específicos
│       └── index.tsx     # 🔴 FUNDAMENTAL - Página principal
│
├── shared/               # 🔴 FUNDAMENTAL - Código compartilhado
│   ├── components/       # 🔴 FUNDAMENTAL - Componentes reutilizáveis
│   ├── hooks/            # 🟡 SITUACIONAL - Hooks genéricos
│   ├── lib/              # 🔴 FUNDAMENTAL - Utilities
│   ├── services/         # 🔴 FUNDAMENTAL - Serviços globais (API client)
│   └── types/            # 🟡 SITUACIONAL - Tipos compartilhados
│
└── main.tsx              # 🔴 FUNDAMENTAL - Entry point
```

**Legenda:**
- 🔴 **FUNDAMENTAL** - Deve existir em todo projeto
- 🟡 **SITUACIONAL** - Criar apenas quando necessário

---

### 2.2 Estrutura de Features

**Princípio:** Criar subpastas apenas quando houver **múltiplos arquivos**. Se há apenas um arquivo, manter no nível da feature.

#### ❌ Evitar - Pastas desnecessárias
```
features/students/
├── components/
│   └── columns.tsx        # apenas 1 arquivo
├── hooks/
│   └── index.ts           # apenas 1 arquivo
├── scripts/
│   └── index.ts           # apenas 1 arquivo
└── index.tsx
```

#### ✅ Recomendado - Estrutura enxuta
```
features/students/
├── components/            # múltiplos componentes
│   ├── StudentTable.tsx
│   ├── StudentFilters.tsx
│   └── StudentActions.tsx
├── useStudents.ts         # hook direto (único)
├── students.api.ts        # API direto (único)
└── index.tsx
```

#### ✅ Alternativa - Quando há lógica complexa
```
features/students/
├── components/
│   ├── StudentTable.tsx
│   └── StudentFilters.tsx
├── useStudents.ts         # lógica de UI/estado
├── students.api.ts        # apenas chamadas HTTP
└── index.tsx
```

---

### 2.3 Organização de Tipos

**Regra:** Separar tipos em arquivos dedicados, não misturar com código de implementação.

#### ❌ Evitar - Tipos misturados com serviços
```typescript
// services/student.service.ts
export interface Student {
  id: string;
  name: string;
  birthDate: string;
}

export interface StudentFilter {
  name?: string;
  classId?: string;
}

export class StudentService {
  async list(filter: StudentFilter): Promise<Student[]> { ... }
}
```

#### ✅ Recomendado - Separação clara
```typescript
// types/student.types.ts
export interface Student {
  id: string;
  name: string;
  birthDate: string;
  addresses: Address[];
  guardians: Guardian[];
}

export interface StudentFilter {
  name?: string;
  guardianName?: string;
  classId?: string;
}

// services/student.service.ts
import { Student, StudentFilter } from '@/types/student.types';

export class StudentService {
  async list(filter?: StudentFilter): Promise<Student[]> { ... }
  async getById(id: string): Promise<Student> { ... }
}
```

---

## 3. Organização de Código

### 3.1 Tipagem de Erros

**Regra:** Evitar `any` em blocos de erro. Usar tipagem adequada.

#### ❌ Evitar
```typescript
try {
  const result = await studentService.list();
} catch (e: any) {
  console.log(e);
  throw e;
}
```

#### ✅ Recomendado
```typescript
try {
  const result = await studentService.list();
} catch (error) {
  if (error instanceof AxiosError) {
    console.error('API Error:', error.response?.data);
    throw new Error(error.response?.data.message || 'Erro ao listar alunos');
  }
  throw error;
}
```

---

### 3.2 Tratamento Centralizado de Erros

**Regra:** Evitar blocos try-catch repetitivos. Usar interceptors do Axios.

#### ❌ Evitar - Repetição em cada método
```typescript
class StudentService {
  async list() {
    try {
      const result = await axios.get('/students');
      return result.data;
    } catch (e) {
      if (axios.isAxiosError(e)) {
        const status = e.response?.data['codigo'];
        const message = e.response?.data['mensagem'];

        switch (status) {
          case 300:
            throw new Error('Acesso negado');
          default:
            throw new Error(message);
        }
      }
      throw e;
    }
  }

  async getById(id: string) {
    try {
      const result = await axios.get(`/students/${id}`);
      return result.data;
    } catch (e) {
      if (axios.isAxiosError(e)) {
        const status = e.response?.data['codigo'];
        const message = e.response?.data['mensagem'];

        switch (status) {
          case 300:
            throw new Error('Acesso negado');
          default:
            throw new Error(message);
        }
      }
      throw e;
    }
  }
}
```

#### ✅ Recomendado - Interceptor centralizado
```typescript
// services/api/error.interceptor.ts
import axios from 'axios';

export class ApiError extends Error {
  constructor(
    message: string,
    public code?: number,
    public statusCode?: number
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

axios.interceptors.response.use(
  (response) => response,
  (error) => {
    if (axios.isAxiosError(error)) {
      const code = error.response?.data?.codigo;
      const message = error.response?.data?.mensagem || 'Erro desconhecido';

      if (code === 300) {
        throw new ApiError('Acesso negado', code, error.response?.status);
      }

      throw new ApiError(message, code, error.response?.status);
    }

    throw error;
  }
);

// services/student.service.ts (simplificado)
class StudentService {
  async list(filter?: StudentFilter): Promise<Student[]> {
    const response = await axios.get('/students', { params: filter });
    return response.data.records;
  }

  async getById(id: string): Promise<Student> {
    const response = await axios.get(`/students/${id}`);
    return response.data;
  }
}
```

---

### 3.3 Modularização de Rotas

**Regra:** Dividir rotas por módulo/feature, não centralizar tudo em um arquivo.

#### ❌ Evitar - Arquivo único com 70+ linhas
```typescript
// routes.tsx
export default function AppRoutes() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/home" element={<Home />} />

        <Route path="/students" element={<Students />} />
        <Route path="/student/:id" element={<StudentForm />} />
        <Route path="/student" element={<StudentForm />} />

        <Route path="/teachers" element={<Teachers />} />
        <Route path="/teacher/:id" element={<TeacherForm />} />
        <Route path="/teacher" element={<TeacherForm />} />

        {/* ... mais 50 linhas ... */}
      </Routes>
    </BrowserRouter>
  );
}
```

#### ✅ Recomendado - Rotas modulares
```typescript
// app/routes/index.tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { studentRoutes } from './student.routes';
import { teacherRoutes } from './teacher.routes';
import Login from '@/features/auth/Login';
import Home from '@/features/home';

export const AppRoutes = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/home" element={<Home />} />

        {studentRoutes.map((route) => (
          <Route key={route.path} {...route} />
        ))}

        {teacherRoutes.map((route) => (
          <Route key={route.path} {...route} />
        ))}
      </Routes>
    </BrowserRouter>
  );
};

// app/routes/student.routes.tsx
import Students from '@/features/students';
import StudentForm from '@/features/students/StudentForm';

export const studentRoutes = [
  { path: '/students', element: <Students /> },
  { path: '/student/:id', element: <StudentForm /> },
  { path: '/student', element: <StudentForm /> },
];

// app/routes/teacher.routes.tsx
import Teachers from '@/features/teachers';
import TeacherForm from '@/features/teachers/TeacherForm';

export const teacherRoutes = [
  { path: '/teachers', element: <Teachers /> },
  { path: '/teacher/:id', element: <TeacherForm /> },
  { path: '/teacher', element: <TeacherForm /> },
];
```

---

### 3.4 Componentes de Coluna (Tabelas)

**Regra:** Extrair lógica de ações para hooks customizados.

#### ❌ Evitar - Hooks dentro de definição de coluna
```typescript
// components/StudentColumns.tsx
export const studentColumns: ColumnDef<Student>[] = [
  {
    id: 'actions',
    cell: ({ row }) => {
      const student = row.original;
      // ❌ Hooks dentro de renderização de célula
      const navigate = useNavigate();
      const { openModal, modal } = useMessageModal();

      return (
        <>
          {modal}
          <DropdownMenu>
            <DropdownMenuItem onClick={() => navigate(`/student/${student.id}`)}>
              Editar
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => {
              openModal({
                title: 'Deletar Aluno',
                description: `Deseja deletar ${student.name}?`,
                onConfirm: () => deleteStudent(student.id)
              });
            }}>
              Deletar
            </DropdownMenuItem>
          </DropdownMenu>
        </>
      );
    },
  },
];
```

#### ✅ Recomendado - Hook de ações extraído
```typescript
// hooks/useStudentActions.ts
export const useStudentActions = () => {
  const navigate = useNavigate();
  const { openModal } = useMessageModal();

  const handleEdit = (student: Student) => {
    navigate(`/student/${student.id}`);
  };

  const handleDelete = async (student: Student) => {
    openModal({
      title: 'Deletar Aluno',
      description: `Deseja realmente deletar ${student.name}?`,
      type: 'warning',
      onConfirm: async () => {
        try {
          await studentService.delete(student.id);
          toast.success('Aluno deletado com sucesso');
        } catch (error) {
          toast.error('Erro ao deletar aluno');
        }
      },
    });
  };

  return { handleEdit, handleDelete };
};

// components/StudentColumns.tsx
import { StudentActions } from './StudentActions';

export const studentColumns: ColumnDef<Student>[] = [
  {
    id: 'name',
    accessorKey: 'name',
    header: 'Nome',
  },
  {
    id: 'birthDate',
    header: 'Data Nascimento',
    cell: ({ row }) => formatDate(row.original.birthDate),
  },
  {
    id: 'actions',
    header: 'Ações',
    cell: ({ row }) => <StudentActions student={row.original} />,
  },
];

// components/StudentActions.tsx
interface Props {
  student: Student;
}

export const StudentActions = ({ student }: Props) => {
  const { handleEdit, handleDelete } = useStudentActions();

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="sm">
          <MoreHorizontal />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent>
        <DropdownMenuItem onClick={() => handleEdit(student)}>
          Editar
        </DropdownMenuItem>
        <DropdownMenuItem
          onClick={() => handleDelete(student)}
          className="text-destructive"
        >
          Deletar
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
};
```

---

### 3.5 Callbacks e Mutações

**Regra:** Padronizar tratamento de callbacks em hooks customizados.

#### ❌ Evitar - Callbacks inline repetitivos
```typescript
// Página 1
const onSuccess = () => {
  toast.success('Aluno cadastrado');
  navigate('/students');
};
const onFailure = (error: Error) => {
  toast.error(error.message);
};
const onComplete = () => {
  setLoading(false);
};

handle({ onSuccess, onFailure, onComplete });

// Página 2 - mesmo código repetido
const onSuccess = () => {
  toast.success('Professor cadastrado');
  navigate('/teachers');
};
const onFailure = (error: Error) => {
  toast.error(error.message);
};
const onComplete = () => {
  setLoading(false);
};

handle({ onSuccess, onFailure, onComplete });
```

#### ✅ Recomendado - Hook de mutação padronizado
```typescript
// hooks/useFormMutation.ts
interface UseFormMutationOptions {
  successMessage: string;
  redirectTo?: string;
}

export const useFormMutation = <T,>(
  mutationFn: (data: T) => Promise<void>,
  options: UseFormMutationOptions
) => {
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);

  const mutate = async (data: T) => {
    setIsLoading(true);

    try {
      await mutationFn(data);
      toast.success(options.successMessage);

      if (options.redirectTo) {
        navigate(options.redirectTo);
      }
    } catch (error) {
      const message = error instanceof Error
        ? error.message
        : 'Erro ao processar requisição';
      toast.error(message);
    } finally {
      setIsLoading(false);
    }
  };

  return { mutate, isLoading };
};

// Uso na página
const StudentForm = () => {
  const { id } = useParams();
  const form = useForm<Student>();

  const { mutate, isLoading } = useFormMutation(
    async (data: Student) => {
      if (id) {
        await studentService.update(id, data);
      } else {
        await studentService.create(data);
      }
    },
    {
      successMessage: id ? 'Aluno atualizado' : 'Aluno cadastrado',
      redirectTo: '/students',
    }
  );

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(mutate)}>
        {/* campos do formulário */}
        <Button type="submit" disabled={isLoading}>
          {id ? 'Atualizar' : 'Cadastrar'}
        </Button>
      </form>
    </Form>
  );
};
```

---

## 4. Boas Práticas

### 4.1 Hooks Customizados

**Quando criar:** Lógica reutilizável ou complexa que envolve estado.

```typescript
// ✅ Bom uso de hook customizado
const useStudentForm = (id?: string) => {
  const [student, setStudent] = useState<Student | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const form = useForm<Student>();

  useEffect(() => {
    if (id) {
      loadStudent(id);
    }
  }, [id]);

  const loadStudent = async (id: string) => {
    setIsLoading(true);
    try {
      const data = await studentService.getById(id);
      form.reset(data);
      setStudent(data);
    } catch (error) {
      toast.error('Erro ao carregar aluno');
    } finally {
      setIsLoading(false);
    }
  };

  return { form, student, isLoading };
};
```

---

### 4.2 Composição de Componentes

**Preferir composição** a renderização condicional complexa.

#### ❌ Evitar
```typescript
const StudentPage = ({ mode }: { mode: 'view' | 'edit' | 'create' }) => {
  if (mode === 'view') {
    return <div>{/* código de visualização */}</div>;
  }

  if (mode === 'edit') {
    return <form>{/* código de edição */}</form>;
  }

  return <form>{/* código de criação */}</form>;
};
```

#### ✅ Recomendado
```typescript
// Componentes separados
const StudentView = ({ student }: { student: Student }) => {
  return <div>{/* visualização */}</div>;
};

const StudentForm = ({ student }: { student?: Student }) => {
  return <form>{/* formulário */}</form>;
};

// Composição na rota
<Route path="/student/:id/view" element={<StudentView />} />
<Route path="/student/:id" element={<StudentForm />} />
<Route path="/student" element={<StudentForm />} />
```

---

### 4.3 Uso de Axios

**Padrão do time:** Usar Axios para chamadas HTTP (não usar React Query/TanStack Query).

```typescript
// services/api/client.ts
import axios from 'axios';

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'X-API-Key': import.meta.env.VITE_API_KEY,
  },
});

// Interceptor de autenticação
apiClient.interceptors.request.use((config) => {
  const token = sessionStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Interceptor de erro
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      sessionStorage.removeItem('token');
      window.location.href = '/';
    }
    return Promise.reject(error);
  }
);

export { apiClient };
```

---

### 4.4 Error Boundaries

Implementar para capturar erros de renderização.

```typescript
// components/ErrorBoundary.tsx
import { Component, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: any) {
    console.error('Error caught by boundary:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="p-4 text-center">
          <h2>Algo deu errado</h2>
          <p>{this.state.error?.message}</p>
          <button onClick={() => window.location.reload()}>
            Recarregar página
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

// Uso
<ErrorBoundary>
  <App />
</ErrorBoundary>
```

---

### 4.5 Lazy Loading de Rotas

Melhorar performance com carregamento sob demanda.

```typescript
// app/routes/index.tsx
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

// Lazy loading de páginas
const Students = lazy(() => import('@/features/students'));
const StudentForm = lazy(() => import('@/features/students/StudentForm'));
const Teachers = lazy(() => import('@/features/teachers'));

const LoadingFallback = () => (
  <div className="flex items-center justify-center h-screen">
    <span>Carregando...</span>
  </div>
);

export const AppRoutes = () => {
  return (
    <BrowserRouter>
      <Suspense fallback={<LoadingFallback />}>
        <Routes>
          <Route path="/students" element={<Students />} />
          <Route path="/student/:id" element={<StudentForm />} />
          <Route path="/teachers" element={<Teachers />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
};
```

---

## 5. Exemplos Práticos

### 5.1 Feature Completa (CRUD de Alunos)

```
features/students/
├── api/
│   └── students.api.ts
├── components/
│   ├── StudentTable.tsx
│   ├── StudentFilters.tsx
│   ├── StudentActions.tsx
│   └── StudentColumns.tsx
├── hooks/
│   ├── useStudents.ts
│   ├── useStudentForm.ts
│   └── useStudentActions.ts
├── types/
│   └── student.types.ts
├── index.tsx              # Lista de alunos
├── StudentForm.tsx        # Formulário
└── StudentView.tsx        # Visualização
```

**students.api.ts**
```typescript
import { apiClient } from '@/shared/services/api';
import { Student, StudentFilter } from '../types/student.types';

export const studentsApi = {
  list: async (filter?: StudentFilter) => {
    const response = await apiClient.get<{ records: Student[] }>('/students', {
      params: filter,
    });
    return response.data.records;
  },

  getById: async (id: string) => {
    const response = await apiClient.get<Student>(`/students/${id}`);
    return response.data;
  },

  create: async (data: Student) => {
    const response = await apiClient.post<{ id: string }>('/students', data);
    return response.data;
  },

  update: async (id: string, data: Student) => {
    const response = await apiClient.put(`/students/${id}`, data);
    return response.data;
  },

  delete: async (id: string) => {
    await apiClient.delete(`/students/${id}`);
  },
};
```

**useStudents.ts**
```typescript
import { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { studentsApi } from '../api/students.api';
import { Student, StudentFilter } from '../types/student.types';

export const useStudents = () => {
  const [students, setStudents] = useState<Student[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const form = useForm<StudentFilter>();

  const loadStudents = async (filter?: StudentFilter) => {
    setIsLoading(true);
    try {
      const data = await studentsApi.list(filter);
      setStudents(data);
    } catch (error) {
      toast.error('Erro ao carregar alunos');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadStudents();
  }, []);

  const handleFilter = form.handleSubmit(async (data) => {
    await loadStudents(data);
  });

  const handleClearFilters = () => {
    form.reset();
    loadStudents();
  };

  return {
    students,
    isLoading,
    form,
    handleFilter,
    handleClearFilters,
    reload: loadStudents,
  };
};
```

**index.tsx (Lista)**
```typescript
import { Layout } from '@/shared/components/Layout';
import { Card, CardContent, CardHeader } from '@/shared/components/ui/card';
import { Button } from '@/shared/components/ui/button';
import { DataTable } from '@/shared/components/DataTable';
import { useNavigate } from 'react-router-dom';
import { useStudents } from './hooks/useStudents';
import { StudentFilters } from './components/StudentFilters';
import { studentColumns } from './components/StudentColumns';

export default function Students() {
  const navigate = useNavigate();
  const { students, isLoading, form, handleFilter, handleClearFilters } = useStudents();

  return (
    <Layout
      title="Alunos"
      subtitle="Gerencie os alunos cadastrados"
    >
      <Card className="mb-4">
        <CardHeader>Filtros</CardHeader>
        <CardContent>
          <StudentFilters
            form={form}
            onFilter={handleFilter}
            onClear={handleClearFilters}
          />
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <div className="flex justify-end">
            <Button onClick={() => navigate('/student')}>
              Adicionar Aluno
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          <DataTable
            columns={studentColumns}
            data={students}
            isLoading={isLoading}
          />
        </CardContent>
      </Card>
    </Layout>
  );
}
```

---

### 5.2 Serviço com Classe vs Objeto

**Ambas abordagens são válidas:**

#### Opção A: Classe (orientado a objetos)
```typescript
export class StudentService {
  private baseUrl = '/students';

  async list(filter?: StudentFilter): Promise<Student[]> {
    const response = await apiClient.get(this.baseUrl, { params: filter });
    return response.data.records;
  }

  async getById(id: string): Promise<Student> {
    const response = await apiClient.get(`${this.baseUrl}/${id}`);
    return response.data;
  }
}

export const studentService = new StudentService();
```

#### Opção B: Objeto (funcional)
```typescript
export const studentService = {
  list: async (filter?: StudentFilter) => {
    const response = await apiClient.get('/students', { params: filter });
    return response.data.records;
  },

  getById: async (id: string) => {
    const response = await apiClient.get(`/students/${id}`);
    return response.data;
  },
};
```

**Recomendação:** Usar Opção B (objeto) para simplicidade, a menos que precise de herança ou estado interno.

---

## 6. CSS Classes

### 6.1 Metodologia BEM

Use BEM (Block Element Modifier) para organização de classes CSS:

```css
.block {}
.block__element {}
.block--modifier {}

/* Exemplos práticos */
.card {}
.card__title {}
.card__body {}
.card__footer {}
.card--featured {}
.card--disabled {}
```

### 6.2 Classes de Estado

Para estados de componentes, use prefixos descritivos:

```css
.is-active {}
.is-disabled {}
.is-loading {}
.is-visible {}
.is-hidden {}
.has-error {}
.has-icon {}
```

**Exemplo React:**
```tsx
<button
  className={`btn ${isLoading ? 'is-loading' : ''} ${hasError ? 'has-error' : ''}`}
>
  Submit
</button>
```

---

## 7. Git e Versionamento

### 7.1 Branches

Siga o padrão de nomenclatura:

```
feature/add-user-authentication
feature/implement-dashboard
bugfix/fix-login-redirect
bugfix/correct-validation
hotfix/patch-security-issue
release/v1.2.0
```

### 7.2 Commits (Conventional Commits)

Use o formato Conventional Commits:

```
feat: add user authentication
fix: resolve login redirect issue
docs: update README with new instructions
style: format code with prettier
refactor: simplify validation logic
test: add unit tests for auth service
chore: update dependencies
```

**Escopo opcional:**
```
feat(auth): add OAuth2 integration
fix(api): handle timeout errors
docs(readme): add installation guide
```

---

## Checklist de Revisão de Código

Antes de abrir um Pull Request, verifique:

- [ ] Todo código está em **inglês** (exceto textos de UI)
- [ ] Nomenclatura seguindo convenções (PascalCase, camelCase, kebab-case)
- [ ] Booleanos com prefixos `is`, `has`, `should`, `can`
- [ ] Arrays no plural
- [ ] Funções com verbos + substantivo
- [ ] Não há uso de `any` sem justificativa
- [ ] Tipos/interfaces em arquivos `.types.ts` separados
- [ ] Erros tratados adequadamente (sem try-catch repetitivo)
- [ ] Hooks customizados para lógica reutilizável
- [ ] Componentes com responsabilidade única
- [ ] Imports organizados (React → libs → internos)
- [ ] Classes CSS seguindo BEM ou padrão de estados
- [ ] Commits seguindo Conventional Commits
- [ ] Branches com nomenclatura correta
- [ ] Sem console.log em produção
- [ ] Rotas organizadas por módulo (não centralizadas)

---

## Referências

- [React Documentation](https://react.dev/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Axios Documentation](https://axios-http.com/)
- [React Hook Form](https://react-hook-form.com/)
- [shadcn/ui](https://ui.shadcn.com/)

---

**Última atualização:** 01/11/2025 13:14
