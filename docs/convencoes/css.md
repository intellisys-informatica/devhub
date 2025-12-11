# Padrões CSS/SCSS

Convenções e boas práticas para estilização.

## Nomenclatura

### BEM (Block Element Modifier)

Use a metodologia BEM para organizar classes CSS:

```css
/* Block */
.card { }

/* Element */
.card__title { }
.card__content { }

/* Modifier */
.card--featured { }
.card__title--large { }
```

**Exemplo prático:**

```html
<div class="card card--featured">
  <h2 class="card__title card__title--large">Título</h2>
  <p class="card__content">Conteúdo</p>
</div>
```

```css
.card {
  padding: 1rem;
  background: white;
}

.card--featured {
  border: 2px solid gold;
}

.card__title {
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
}

.card__title--large {
  font-size: 2rem;
}

.card__content {
  color: #666;
}
```

## Organização de Arquivos

### Estrutura de pastas

```
styles/
├── base/
│   ├── _reset.scss
│   ├── _typography.scss
│   └── _variables.scss
├── components/
│   ├── _button.scss
│   ├── _card.scss
│   └── _modal.scss
├── layout/
│   ├── _header.scss
│   ├── _footer.scss
│   └── _grid.scss
├── pages/
│   ├── _home.scss
│   └── _profile.scss
├── utils/
│   ├── _mixins.scss
│   └── _helpers.scss
└── main.scss
```

### main.scss

```scss
// 1. Variables and config
@import 'base/variables';

// 2. Base styles
@import 'base/reset';
@import 'base/typography';

// 3. Utils
@import 'utils/mixins';
@import 'utils/helpers';

// 4. Layout
@import 'layout/grid';
@import 'layout/header';
@import 'layout/footer';

// 5. Components
@import 'components/button';
@import 'components/card';
@import 'components/modal';

// 6. Pages
@import 'pages/home';
@import 'pages/profile';
```

## Variáveis CSS

### CSS Custom Properties

```css
:root {
  /* Colors */
  --color-primary: #0066cc;
  --color-secondary: #6c757d;
  --color-success: #28a745;
  --color-danger: #dc3545;
  --color-warning: #ffc107;

  /* Typography */
  --font-family-base: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-family-mono: 'Fira Code', 'Courier New', monospace;
  --font-size-base: 16px;
  --line-height-base: 1.6;

  /* Spacing */
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 1.5rem;
  --spacing-xl: 2rem;

  /* Breakpoints */
  --breakpoint-sm: 576px;
  --breakpoint-md: 768px;
  --breakpoint-lg: 992px;
  --breakpoint-xl: 1200px;

  /* Shadows */
  --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.1);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 20px rgba(0, 0, 0, 0.15);

  /* Transitions */
  --transition-base: 0.2s ease;
  --transition-slow: 0.3s ease;
}
```

### SCSS Variables

```scss
// Colors
$primary: #0066cc;
$secondary: #6c757d;
$success: #28a745;
$danger: #dc3545;

// Spacing
$spacing: (
  'xs': 0.25rem,
  'sm': 0.5rem,
  'md': 1rem,
  'lg': 1.5rem,
  'xl': 2rem
);

// Usage
.button {
  padding: map-get($spacing, 'md');
}
```

## Mixins SCSS

### Responsive

```scss
@mixin respond-to($breakpoint) {
  @if $breakpoint == 'sm' {
    @media (min-width: 576px) { @content; }
  }
  @else if $breakpoint == 'md' {
    @media (min-width: 768px) { @content; }
  }
  @else if $breakpoint == 'lg' {
    @media (min-width: 992px) { @content; }
  }
  @else if $breakpoint == 'xl' {
    @media (min-width: 1200px) { @content; }
  }
}

// Usage
.container {
  padding: 1rem;

  @include respond-to('md') {
    padding: 2rem;
  }
}
```

### Flexbox

```scss
@mixin flex-center {
  display: flex;
  align-items: center;
  justify-content: center;
}

@mixin flex-between {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

// Usage
.header {
  @include flex-between;
}
```

### Truncate

```scss
@mixin truncate($lines: 1) {
  @if $lines == 1 {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  } @else {
    display: -webkit-box;
    -webkit-line-clamp: $lines;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
}

// Usage
.title {
  @include truncate(2);
}
```

## Boas Práticas

### 1. Mobile-First

```css
/* ✅ Bom - Mobile first */
.element {
  width: 100%;
}

@media (min-width: 768px) {
  .element {
    width: 50%;
  }
}

/* ❌ Evite - Desktop first */
.element {
  width: 50%;
}

@media (max-width: 767px) {
  .element {
    width: 100%;
  }
}
```

### 2. Evite !important

```css
/* ❌ Ruim */
.button {
  color: red !important;
}

/* ✅ Bom - Aumente especificidade */
.modal .button {
  color: red;
}
```

### 3. Use unidades relativas

```css
/* ✅ Bom */
.text {
  font-size: 1rem;
  padding: 1em;
  margin: 2rem 0;
}

/* ❌ Evite pixels para tamanhos */
.text {
  font-size: 16px;
  padding: 16px;
}
```

### 4. Organize seletores

```css
/* Ordem recomendada */
.element {
  /* 1. Positioning */
  position: relative;
  top: 0;
  left: 0;
  z-index: 10;

  /* 2. Box Model */
  display: flex;
  width: 100%;
  padding: 1rem;
  margin: 0 auto;

  /* 3. Typography */
  font-size: 1rem;
  line-height: 1.6;
  text-align: center;

  /* 4. Visual */
  background: white;
  border: 1px solid #ccc;
  border-radius: 4px;
  color: #333;

  /* 5. Misc */
  cursor: pointer;
  transition: all 0.2s;
}
```

## Utilitários

### Classes Helper

```css
/* Spacing */
.mt-1 { margin-top: 0.25rem; }
.mt-2 { margin-top: 0.5rem; }
.mt-3 { margin-top: 1rem; }

.p-1 { padding: 0.25rem; }
.p-2 { padding: 0.5rem; }
.p-3 { padding: 1rem; }

/* Display */
.d-block { display: block; }
.d-none { display: none; }
.d-flex { display: flex; }

/* Text */
.text-center { text-align: center; }
.text-bold { font-weight: bold; }
.text-uppercase { text-transform: uppercase; }

/* Visibility */
@media (max-width: 767px) {
  .hide-mobile { display: none; }
}

@media (min-width: 768px) {
  .hide-desktop { display: none; }
}
```

## Componentes

### Button

```scss
.button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.75rem 1.5rem;
  font-size: 1rem;
  font-weight: 500;
  line-height: 1;
  text-align: center;
  border: none;
  border-radius: 0.25rem;
  cursor: pointer;
  transition: all var(--transition-base);

  &:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
  }

  &:active {
    transform: translateY(0);
  }

  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  // Variants
  &--primary {
    background: var(--color-primary);
    color: white;

    &:hover {
      background: darken($primary, 10%);
    }
  }

  &--secondary {
    background: var(--color-secondary);
    color: white;
  }

  &--outline {
    background: transparent;
    border: 2px solid var(--color-primary);
    color: var(--color-primary);
  }

  // Sizes
  &--small {
    padding: 0.5rem 1rem;
    font-size: 0.875rem;
  }

  &--large {
    padding: 1rem 2rem;
    font-size: 1.125rem;
  }
}
```

### Card

```scss
.card {
  background: white;
  border-radius: 0.5rem;
  box-shadow: var(--shadow-sm);
  overflow: hidden;
  transition: all var(--transition-base);

  &:hover {
    box-shadow: var(--shadow-md);
  }

  &__image {
    width: 100%;
    height: 200px;
    object-fit: cover;
  }

  &__body {
    padding: 1.5rem;
  }

  &__title {
    margin-bottom: 0.75rem;
    font-size: 1.25rem;
    font-weight: 600;
  }

  &__text {
    color: var(--text-secondary);
    margin-bottom: 1rem;
  }

  &__footer {
    padding: 1rem 1.5rem;
    background: var(--bg-secondary);
    border-top: 1px solid var(--border-color);
  }
}
```

## Grid System

```scss
.container {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
}

.row {
  display: flex;
  flex-wrap: wrap;
  margin: 0 -0.5rem;
}

.col {
  flex: 1;
  padding: 0 0.5rem;
}

@for $i from 1 through 12 {
  .col-#{$i} {
    flex: 0 0 calc(#{$i} / 12 * 100%);
    max-width: calc(#{$i} / 12 * 100%);
    padding: 0 0.5rem;
  }
}

// Responsive
@include respond-to('md') {
  @for $i from 1 through 12 {
    .col-md-#{$i} {
      flex: 0 0 calc(#{$i} / 12 * 100%);
      max-width: calc(#{$i} / 12 * 100%);
    }
  }
}
```

## Performance

### 1. Evite seletores complexos

```css
/* ❌ Ruim */
div > ul > li > a {
  color: blue;
}

/* ✅ Bom */
.nav-link {
  color: blue;
}
```

### 2. Use transform para animações

```css
/* ✅ Bom - GPU accelerated */
.element {
  transform: translateX(100px);
  transition: transform 0.3s;
}

/* ❌ Evite - Causa reflow */
.element {
  left: 100px;
  transition: left 0.3s;
}
```

### 3. Will-change para animações pesadas

```css
.animated-element {
  will-change: transform, opacity;
}
```

## Dark Mode

```css
:root {
  --bg-primary: #ffffff;
  --text-primary: #000000;
}

[data-theme="dark"] {
  --bg-primary: #1a1a1a;
  --text-primary: #ffffff;
}

body {
  background: var(--bg-primary);
  color: var(--text-primary);
}
```

## Checklist

- [ ] Classes seguem padrão BEM
- [ ] Uso de variáveis CSS/SCSS
- [ ] Mobile-first
- [ ] Sem !important desnecessário
- [ ] Unidades relativas (rem, em, %)
- [ ] Código organizado e comentado
- [ ] Performance otimizada
- [ ] Suporte a dark mode (se aplicável)

## Recursos Adicionais

- [BEM Methodology](http://getbem.com/)
- [CSS Guidelines](https://cssguidelin.es/)
- [SASS Documentation](https://sass-lang.com/documentation)
