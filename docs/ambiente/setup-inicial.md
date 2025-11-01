# Setup Inicial do Ambiente de Desenvolvimento

> Guia completo para configurar o ambiente de desenvolvimento da Intellisys

## 📋 Visão Geral

Este guia apresenta as ferramentas essenciais que você deve ter instaladas no seu ambiente de desenvolvimento. As ferramentas estão organizadas por escopo de uso.

## 🚀 Setup Automático (Recomendado)

Use nosso script de instalação automática para configurar tudo de uma vez:

```bash
curl -fsSL https://raw.githubusercontent.com/intellisys-informatica/devhub/main/docs/ambiente/assets/setup-dev.sh | bash
```

**Ou baixe o script localmente:**

```bash
curl -fsSL https://raw.githubusercontent.com/intellisys-informatica/devhub/main/docs/ambiente/assets/setup-dev.sh -o setup-dev.sh
chmod +x setup-dev.sh
./setup-dev.sh
```

**O script permite escolher:**
- Ferramentas essenciais + ReactJS
- Ferramentas essenciais + Go
- Tudo (Ferramentas essenciais + ReactJS + Go)

**O que o script faz:**
- ✅ Detecta automaticamente seu sistema operacional e shell
- ✅ Instala ferramentas CLI essenciais (curl, wget, vim, jq, tree, htop)
- ✅ Pergunta se deseja usar Zsh + Oh My Zsh + Starship (se ainda não estiver usando)
- ✅ Instala todas as ferramentas necessárias
- ✅ Configura Git e Git Flow
- ✅ Configura Docker para iniciar com o sistema (Linux)
- ✅ Configura Docker sem sudo (Linux)
- ✅ Instala Node.js LTS mais recente
- ✅ Configura Go PATH corretamente (GOPATH em `~/.go`)
- ✅ Pergunta suas credenciais Git se não estiverem configuradas
- ✅ Configura chaves SSH para GitHub e servidores remotos

---

## 📝 Instalação Manual

Se preferir instalar manualmente, siga as instruções abaixo:

---

## 🔧 Ferramentas Essenciais (Todos os Ambientes)

Estas ferramentas devem estar presentes independente da stack de desenvolvimento:

### 1. Git

Sistema de controle de versão distribuído.

- **📖 Documentação**: [git-scm.com/doc](https://git-scm.com/doc)
- **📥 Download**: [git-scm.com/downloads](https://git-scm.com/downloads)

**Instalação:**

```bash
# Windows (com winget)
winget install Git.Git

# macOS (com Homebrew)
brew install git

# Linux (Ubuntu/Debian)
sudo apt update && sudo apt install git

# Verificar instalação
git --version
```

**Configuração inicial:**

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@empresa.com"
git config --global core.editor "code --wait"
```

**Git Flow:**

Após instalar o Git, instale o Git Flow:

```bash
# Windows
winget install Git.GitFlow

# macOS
brew install git-flow

# Linux (Ubuntu/Debian)
sudo apt install git-flow
```

📖 **[Veja nosso guia completo de Git e GitHub](#doc/fluxo)**

---

### 2. Docker

Plataforma de containerização para desenvolvimento e deploy.

- **📖 Documentação**: [docs.docker.com](https://docs.docker.com/)
- **📥 Download**: [docker.com/get-started](https://www.docker.com/get-started)

**Instalação:**

```bash
# Windows
winget install Docker.DockerDesktop

# macOS
brew install --cask docker

# Linux (Ubuntu)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

**Verificar instalação:**

```bash
docker --version
docker-compose --version
```

---

### 3. cURL

Ferramenta de linha de comando para transferência de dados.

- **📖 Documentação**: [curl.se/docs](https://curl.se/docs/)
- **📥 Download**: [curl.se/download.html](https://curl.se/download.html)

**Instalação:**

```bash
# Windows (geralmente já vem instalado)
winget install cURL.cURL

# macOS (já vem pré-instalado)
# Se necessário: brew install curl

# Linux
sudo apt install curl

# Verificar instalação
curl --version
```

---

### 4. Vim

Editor de texto universal para terminal.

- **📖 Documentação**: [vim.org/docs.php](https://www.vim.org/docs.php)
- **📥 Download**: [vim.org/download.php](https://www.vim.org/download.php)

**Instalação:**

```bash
# Windows
winget install vim.vim

# macOS (já vem pré-instalado)
# Versão atualizada: brew install vim

# Linux
sudo apt install vim

# Verificar instalação
vim --version
```

---

### 5. Winget (Somente Windows)

Gerenciador de pacotes oficial da Microsoft para Windows.

- **📖 Documentação**: [learn.microsoft.com/winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/)
- **📥 Instalação**: Incluído no Windows 11 e Windows 10 (versão 1809+)

**Se não estiver instalado:**

1. Instale o [App Installer](https://www.microsoft.com/p/app-installer/9nblggh4nns1) da Microsoft Store
2. Ou baixe manualmente: [github.com/microsoft/winget-cli/releases](https://github.com/microsoft/winget-cli/releases)

**Verificar instalação:**

```bash
winget --version
```

---

## ⚛️ Ambiente ReactJS / React Native

Para desenvolvimento com React, instale:

### Node.js (LTS)

Runtime JavaScript construído no motor V8 do Chrome.

- **📖 Documentação**: [nodejs.org/docs](https://nodejs.org/docs)
- **📥 Download**: [nodejs.org](https://nodejs.org/)
- **Versão recomendada**: Última LTS (Long Term Support)

**Instalação:**

```bash
# Windows
winget install OpenJS.NodeJS.LTS

# macOS
brew install node@lts

# Linux (Ubuntu/Debian) - via NodeSource
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Verificar instalação
node --version
npm --version
```

**Gerenciadores de versão Node (Opcional):**

Para gerenciar múltiplas versões do Node:

- **nvm** (Linux/macOS): [github.com/nvm-sh/nvm](https://github.com/nvm-sh/nvm)
- **nvm-windows**: [github.com/coreybutler/nvm-windows](https://github.com/coreybutler/nvm-windows)
- **fnm**: [github.com/Schniz/fnm](https://github.com/Schniz/fnm)

**Ferramentas adicionais:**

```bash
# Yarn (alternativa ao npm)
npm install -g yarn

# pnpm (gerenciador de pacotes performático)
npm install -g pnpm
```

📖 **[Veja nossos padrões ReactJS](#doc/padroes-reactjs)**

---

## 🐹 Ambiente Go (Golang)

Para desenvolvimento com Go, instale:

### Go

Linguagem de programação desenvolvida pelo Google.

- **📖 Documentação**: [go.dev/doc](https://go.dev/doc/)
- **📥 Download**: [go.dev/dl](https://go.dev/dl/)
- **Versão recomendada**: Última versão estável

**Instalação:**

```bash
# Windows
winget install GoLang.Go

# macOS
brew install go

# Linux (Ubuntu/Debian)
# Baixe o arquivo tar.gz do site oficial e extraia:
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz

# Adicione ao PATH (adicione no ~/.bashrc ou ~/.zshrc)
export PATH=$PATH:/usr/local/go/bin

# Verificar instalação
go version
```

**Configuração do ambiente Go:**

```bash
# Verificar variáveis de ambiente
go env

# GOPATH (onde ficam dependências)
echo $GOPATH

# GOROOT (onde está instalado o Go)
echo $GOROOT
```

**Ferramentas Go úteis:**

```bash
# Formatador de código
go install golang.org/x/tools/cmd/goimports@latest

# Linter
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Debugger
go install github.com/go-delve/delve/cmd/dlv@latest
```

---

## 🎨 Editor de Código Recomendado

### Visual Studio Code

Editor de código leve e extensível.

- **📖 Documentação**: [code.visualstudio.com/docs](https://code.visualstudio.com/docs)
- **📥 Download**: [code.visualstudio.com](https://code.visualstudio.com/)

**Instalação:**

```bash
# Windows
winget install Microsoft.VisualStudioCode

# macOS
brew install --cask visual-studio-code

# Linux (Ubuntu/Debian)
sudo snap install code --classic
```

**Extensões essenciais:**

```bash
# ESLint (JavaScript/TypeScript)
code --install-extension dbaeumer.vscode-eslint

# Prettier (Formatação)
code --install-extension esbenp.prettier-vscode

# GitLens (Git avançado)
code --install-extension eamodio.gitlens

# Go (Para desenvolvimento Go)
code --install-extension golang.go

# Docker
code --install-extension ms-azuretools.vscode-docker
```

📖 **[Configurações recomendadas do VSCode](#doc/vscode)**

---

## ✅ Verificação da Instalação

Execute os comandos abaixo para verificar se tudo foi instalado corretamente:

### Ferramentas essenciais

```bash
git --version
docker --version
curl --version
vim --version
```

### Ambiente ReactJS

```bash
node --version
npm --version
```

### Ambiente Go

```bash
go version
```

---

## 🚀 Próximos Passos

Após configurar seu ambiente:

1. ✅ **[Padrões ReactJS](#doc/padroes-reactjs)** - Se trabalha com React
2. ✅ **[Padrões Go](#doc/golang)** - Se trabalha com Go
3. ✅ **[Git Workflow](#doc/fluxo)** - Entenda nosso fluxo Git
4. ✅ **[Configurações VSCode](#doc/vscode)** - Configure seu editor

---

## 🔧 Resolução de Problemas

### Windows: winget não encontrado

- Instale o App Installer da Microsoft Store
- Ou atualize o Windows para a versão mais recente

### Linux: Permissão negada

Use `sudo` antes dos comandos de instalação ou configure seu usuário no grupo adequado:

```bash
# Docker sem sudo
sudo usermod -aG docker $USER
newgrp docker
```

### Node.js: versão antiga instalada

Use um gerenciador de versões como nvm:

```bash
# Instalar versão LTS
nvm install --lts
nvm use --lts
```

### Go: comando não encontrado

Adicione o Go ao PATH:

```bash
# Bash (~/.bashrc)
export PATH=$PATH:/usr/local/go/bin

# Zsh (~/.zshrc)
export PATH=$PATH:/usr/local/go/bin

# Recarregar
source ~/.bashrc  # ou source ~/.zshrc
```

---

## 📚 Recursos Adicionais

- [Git Official Documentation](https://git-scm.com/doc)
- [Docker Get Started Guide](https://docs.docker.com/get-started/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [Go by Example](https://gobyexample.com/)
- [VSCode Tips and Tricks](https://code.visualstudio.com/docs/getstarted/tips-and-tricks)

---

**Última atualização:** 01/11/2025 12:00
