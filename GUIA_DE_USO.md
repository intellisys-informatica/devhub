# 📚 Guia de Uso - DevHub

Instruções completas para usar e personalizar o DevHub.

## 🚀 Início Rápido

### 1. Abrir o Projeto

**Opção 1: Diretamente no navegador**
- Abra o arquivo `index.html` no seu navegador

**Opção 2: Com servidor local (recomendado)**

```bash
# Python
python -m http.server 8000

# Node.js
npx serve

# PHP
php -S localhost:8000
```

Acesse: `http://localhost:8000`

### 2. Navegação

- **Menu lateral**: Clique nas categorias para navegar
- **Busca**: Clique no ícone 🔍 no topo
- **Dark mode**: Clique no ícone 🌙/☀️
- **Menu mobile**: Clique no ícone ☰ (em telas pequenas)

## 📝 Adicionando Documentação

### Passo 1: Criar arquivo Markdown

Crie um arquivo `.md` na pasta apropriada:

```
docs/
└── sua-categoria/
    └── novo-documento.md
```

**Exemplo de conteúdo:**

```markdown
# Título do Documento

Introdução ao documento.

## Seção 1

Conteúdo da seção 1.

### Subseção

Mais conteúdo.

## Código

```javascript
const exemplo = 'código aqui';
```

## Lista

- Item 1
- Item 2
- Item 3
```

### Passo 2: Registrar no manifest.json

Edite `docs/manifest.json` e adicione:

```json
{
  "categories": [
    {
      "id": "sua-categoria",
      "title": "Nome da Categoria",
      "icon": "🎯",
      "docs": [
        {
          "id": "novo-doc",
          "title": "Título do Documento",
          "description": "Breve descrição",
          "file": "sua-categoria/novo-documento.md"
        }
      ]
    }
  ]
}
```

### Passo 3: Pronto!

Recarregue a página e veja seu novo documento no menu.

## 🎨 Personalização

### Alterar Cores

Edite `css/style.css`:

```css
:root {
  --accent-color: #0969da;  /* Cor principal */
  --bg-primary: #ffffff;     /* Fundo claro */
  --text-primary: #24292f;   /* Texto principal */
}
```

### Adicionar Categoria

1. Crie pasta em `docs/`:
```bash
mkdir docs/nova-categoria
```

2. Adicione no `manifest.json`:
```json
{
  "id": "nova-categoria",
  "title": "Nova Categoria",
  "icon": "🚀",
  "docs": []
}
```

### Mudar Logo

No `index.html`, linha 29:

```html
<h1 class="logo">🤖 Seu Nome</h1>
```

## 🌐 Deploy no GitHub Pages

### 1. Criar Repositório

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/SEU-USUARIO/SEU-REPO.git
git push -u origin main
```

### 2. Ativar GitHub Pages

1. Acesse seu repositório no GitHub
2. Vá em **Settings** → **Pages**
3. Em **Source**, selecione `main` branch
4. Clique em **Save**

### 3. Acessar

Seu site estará em:
```
https://SEU-USUARIO.github.io/SEU-REPO
```

### 4. Atualizar URL no README

Edite `README.md` e `index.html` com a URL correta.

## 📄 Recursos Markdown

### Títulos

```markdown
# H1
## H2
### H3
```

### Ênfase

```markdown
**negrito**
*itálico*
~~riscado~~
```

### Links

```markdown
[Texto do link](https://url.com)
```

### Imagens

```markdown
![Alt text](caminho/imagem.png)
```

### Código Inline

```markdown
Use `código` inline.
```

### Blocos de Código

````markdown
```javascript
const exemplo = 'código';
```
````

### Listas

```markdown
- Item 1
- Item 2
  - Subitem

1. Primeiro
2. Segundo
```

### Tabelas

```markdown
| Coluna 1 | Coluna 2 |
|----------|----------|
| Valor 1  | Valor 2  |
```

### Blockquotes

```markdown
> Citação ou nota importante
```

### Alertas (Admonitions)

```markdown
> [!NOTE]
> Informação útil

> [!TIP]
> Dica útil

> [!WARNING]
> Atenção

> [!DANGER]
> Perigo
```

### Checkbox

```markdown
- [x] Tarefa completa
- [ ] Tarefa pendente
```

## 🛠️ Solução de Problemas

### Documento não aparece

✅ Verifique se o arquivo está na pasta correta
✅ Confirme que está registrado no `manifest.json`
✅ Verifique se o caminho do arquivo está correto
✅ Recarregue a página com Ctrl+F5

### Markdown não renderiza

✅ Verifique se as bibliotecas estão carregando (console do navegador)
✅ Teste se o servidor está funcionando
✅ Verifique se há erros de sintaxe no Markdown

### Busca não funciona

✅ Certifique-se de que os documentos têm `description` no manifest
✅ Verifique o console do navegador por erros

### Menu não abre no mobile

✅ Verifique se o JavaScript está carregando
✅ Teste em modo incógnito (pode ser cache)

## 📁 Estrutura de Arquivos

```
devhub/
├── index.html              # Página principal ← ABRA ESTE ARQUIVO
├── css/
│   ├── style.css          # Estilos gerais
│   └── markdown.css       # Estilos do conteúdo
├── js/
│   ├── app.js             # Aplicação principal
│   ├── markdown-renderer.js
│   └── navigation.js
├── docs/
│   ├── manifest.json      # ← EDITE PARA ADICIONAR DOCS
│   ├── ambiente/
│   ├── padroes/
│   ├── git/
│   ├── ia/
│   └── config/
├── config/                # Templates de configuração
├── assets/                # Imagens e recursos
└── README.md
```

## 🎯 Próximos Passos

1. ✅ Explore a documentação existente
2. ✅ Adicione sua própria documentação
3. ✅ Customize cores e logo
4. ✅ Faça deploy no GitHub Pages
5. ✅ Compartilhe com seu time!

## 📞 Suporte

Dúvidas ou problemas?

- Consulte o [README.md](README.md)
- Abra uma issue no GitHub
- Verifique o console do navegador (F12)

---

**Feito com ❤️ para desenvolvedores**

Boa documentação! 🚀
