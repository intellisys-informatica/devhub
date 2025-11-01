#!/bin/bash

# =============================================================================
# Setup Automático do Ambiente de Desenvolvimento - Intellisys
# =============================================================================

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print colored messages
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Detect OS (Ubuntu/Debian only)
detect_os() {
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        print_error "Este script suporta apenas Ubuntu/Debian"
        print_error "Sistema detectado: $OSTYPE"
        exit 1
    fi

    if [ ! -f /etc/debian_version ]; then
        print_error "Este script suporta apenas Ubuntu/Debian"
        exit 1
    fi

    print_success "Sistema Ubuntu/Debian detectado"
}

# Detect shell
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_TYPE="zsh"
        SHELL_RC="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_TYPE="bash"
        SHELL_RC="$HOME/.bashrc"
    else
        print_warning "Shell não detectado. Usando bash como padrão."
        SHELL_TYPE="bash"
        SHELL_RC="$HOME/.bashrc"
    fi
}

# Install and configure Zsh
install_zsh() {
    CURRENT_SHELL=$(basename "$SHELL")

    # Se já está usando Zsh, apenas verifica instalação
    if [ "$CURRENT_SHELL" == "zsh" ]; then
        print_info "Zsh já é o shell padrão"
        SHELL_TYPE="zsh"
        SHELL_RC="$HOME/.zshrc"
        return
    fi

    # Pergunta se o usuário quer usar Zsh
    print_header "Configuração do Shell"
    echo -e "${YELLOW}Você está usando $CURRENT_SHELL${NC}"
    read -r -p "Deseja instalar e usar Zsh? (s/n): " use_zsh < /dev/tty

    if [[ ! "$use_zsh" =~ ^[Ss]$ ]]; then
        print_info "Mantendo shell atual: $CURRENT_SHELL"
        return
    fi

    print_header "Instalando Zsh"

    if command_exists zsh; then
        print_warning "Zsh já instalado: $(zsh --version)"
    else
        print_info "Instalando Zsh..."
        sudo apt update
        sudo apt install -y zsh
        print_success "Zsh instalado: $(zsh --version)"
    fi

    # Install Oh My Zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_warning "Oh My Zsh já instalado"
    else
        print_info "Instalando Oh My Zsh..."

        # Install Oh My Zsh without changing shell automatically
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        print_success "Oh My Zsh instalado"
    fi

    # Install Starship
    print_info "Instalando Starship..."
    if command_exists starship; then
        print_warning "Starship já instalado: $(starship --version)"
    else
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        print_success "Starship instalado: $(starship --version)"
    fi

    # Configure Starship in .zshrc
    if grep -q "starship init zsh" "$HOME/.zshrc" 2>/dev/null; then
        print_info "Starship já configurado no .zshrc"
    else
        print_info "Configurando Starship no .zshrc..."
        echo '' >> "$HOME/.zshrc"
        echo '# Starship prompt' >> "$HOME/.zshrc"
        echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
        print_success "Starship configurado no .zshrc"
    fi

    # Set Zsh as default shell
    print_info "Configurando Zsh como shell padrão..."
    sudo chsh -s "$(which zsh)" "$USER"
    print_success "Zsh configurado como shell padrão"
    print_warning "IMPORTANTE: Faça logout e login novamente para usar Zsh"

    # Update shell type for this script
    SHELL_TYPE="zsh"
    SHELL_RC="$HOME/.zshrc"

    print_success "Configuração Zsh + Oh My Zsh + Starship concluída"
}

# Show banner
show_banner() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════╗"
    echo "║   Setup Automático - Ambiente Dev         ║"
    echo "║   Intellisys Informatica                  ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Ask user what to install
ask_installation_type() {
    echo -e "${YELLOW}Escolha o tipo de ambiente:${NC}\n"
    echo "1) Ferramentas essenciais + ReactJS"
    echo "2) Ferramentas essenciais + Go"
    echo "3) Tudo (Ferramentas essenciais + ReactJS + Go)"
    echo ""
    read -r -p "Digite sua escolha (1-3): " choice < /dev/tty

    case $choice in
        1)
            INSTALL_ESSENTIALS=true
            INSTALL_REACT=true
            INSTALL_GO=false
            ;;
        2)
            INSTALL_ESSENTIALS=true
            INSTALL_REACT=false
            INSTALL_GO=true
            ;;
        3)
            INSTALL_ESSENTIALS=true
            INSTALL_REACT=true
            INSTALL_GO=true
            ;;
        *)
            print_error "Escolha inválida"
            exit 1
            ;;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Git
install_git() {
    print_header "Instalando Git"

    if command_exists git; then
        print_warning "Git já instalado: $(git --version)"
        return
    fi

    sudo apt update
    sudo apt install -y git

    print_success "Git instalado: $(git --version)"
}

# Install Git Flow
install_git_flow() {
    print_info "Instalando Git Flow..."

    if command_exists git-flow; then
        print_warning "Git Flow já instalado"
        return
    fi

    sudo apt install -y git-flow

    print_success "Git Flow instalado"
}

# Configure Git
configure_git() {
    # Check if git is already configured
    GIT_USER=$(git config --global user.name 2>/dev/null || echo "")
    GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

    if [ -z "$GIT_USER" ] || [ -z "$GIT_EMAIL" ]; then
        print_header "Configuração do Git"

        if [ -z "$GIT_USER" ]; then
            read -r -p "Digite seu nome completo: " git_name < /dev/tty
            git config --global user.name "$git_name"
        fi

        if [ -z "$GIT_EMAIL" ]; then
            read -r -p "Digite seu email do GitHub: " git_email < /dev/tty
            git config --global user.email "$git_email"
        fi

        git config --global core.editor "vim"
        git config --global init.defaultBranch main

        print_success "Git configurado com sucesso"
    else
        print_info "Git já configurado: $GIT_USER <$GIT_EMAIL>"
    fi
}

# Install Docker
install_docker() {
    print_header "Instalando Docker"

    if command_exists docker; then
        print_warning "Docker já instalado: $(docker --version)"
        return
    fi

    print_info "Instalando Docker..."

    # Remove old versions
    sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

    # Install dependencies
    sudo apt update
    sudo apt install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Set up repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Configure Docker to start on boot
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    sudo systemctl start docker

    # Add user to docker group (no sudo required)
    sudo usermod -aG docker $USER

    print_success "Docker instalado"
    print_info "Docker configurado para iniciar com o sistema"
    print_warning "IMPORTANTE: Faça logout e login novamente para usar Docker sem sudo"
}

# Install curl
install_curl() {
    print_info "Verificando curl..."

    if command_exists curl; then
        print_success "curl já instalado: $(curl --version | head -n1)"
        return
    fi

    sudo apt install -y curl
    print_success "curl instalado"
}

# Install vim
install_vim() {
    print_info "Verificando vim..."

    if command_exists vim; then
        print_success "vim já instalado: $(vim --version | head -n1)"
        return
    fi

    sudo apt install -y vim

    print_success "vim instalado"
}

# Install additional CLI tools
install_additional_tools() {
    print_header "Instalando ferramentas CLI adicionais"

    TOOLS=("jq" "tree" "htop" "wget")
    MISSING_TOOLS=()

    for tool in "${TOOLS[@]}"; do
        if ! command_exists "$tool"; then
            MISSING_TOOLS+=("$tool")
        else
            print_info "$tool já instalado"
        fi
    done

    if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
        print_info "Instalando: ${MISSING_TOOLS[*]}"
        sudo apt install -y "${MISSING_TOOLS[@]}"

        for tool in "${MISSING_TOOLS[@]}"; do
            if command_exists "$tool"; then
                print_success "$tool instalado"
            else
                print_error "Erro ao instalar $tool"
            fi
        done
    else
        print_success "Todas as ferramentas CLI já estão instaladas"
    fi
}

# Install Node.js (LTS)
install_nodejs() {
    print_header "Instalando Node.js LTS"

    if command_exists node; then
        CURRENT_NODE=$(node --version)
        print_warning "Node.js já instalado: $CURRENT_NODE"

        read -r -p "Deseja reinstalar a versão LTS? (s/n): " reinstall < /dev/tty
        if [[ ! "$reinstall" =~ ^[Ss]$ ]]; then
            return
        fi
    fi

    print_info "Instalando via NodeSource..."

    # Remove old Node if exists
    sudo apt remove -y nodejs npm 2>/dev/null || true

    # Install from NodeSource (LTS)
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs

    # Verify npm is installed
    if ! command_exists npm; then
        print_error "npm não foi instalado corretamente"
        exit 1
    fi

    print_success "Node.js instalado: $(node --version)"
    print_success "npm instalado: $(npm --version)"

    # Install global packages
    print_info "Instalando pacotes globais úteis..."
    npm install -g yarn pnpm
    print_success "yarn e pnpm instalados"
}

# Install Go
install_go() {
    print_header "Instalando Go (última versão estável)"

    if command_exists go; then
        print_warning "Go já instalado: $(go version)"

        read -r -p "Deseja reinstalar? (s/n): " reinstall < /dev/tty
        if [[ ! "$reinstall" =~ ^[Ss]$ ]]; then
            configure_go_path
            return
        fi
    fi

    # Check if wget is installed
    if ! command_exists wget; then
        print_info "wget não encontrado, instalando..."
        sudo apt install -y wget
    fi

    # Get latest stable version
    GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n1)
    GO_TAR="${GO_VERSION}.linux-amd64.tar.gz"

    print_info "Baixando Go $GO_VERSION..."
    wget -q --show-progress "https://go.dev/dl/$GO_TAR"

    print_info "Instalando..."
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$GO_TAR"
    rm "$GO_TAR"

    configure_go_path
    print_success "Go instalado: $(/usr/local/go/bin/go version)"
}

# Configure Go PATH
configure_go_path() {
    print_info "Configurando Go PATH..."

    # Create GOPATH directory
    mkdir -p "$HOME/.go"

    # Determine which RC file to use based on installed shells and user choice
    local TARGET_RC=""

    # Check if Zsh is installed and configured
    if command_exists zsh && [ -f "$HOME/.zshrc" ]; then
        TARGET_RC="$HOME/.zshrc"
        print_info "Detectado Zsh instalado, usando .zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        TARGET_RC="$HOME/.bashrc"
        print_info "Usando .bashrc"
    else
        print_error "Nenhum arquivo RC encontrado"
        return 1
    fi

    # Check if already configured in target RC
    if grep -q "export GOPATH=" "$TARGET_RC" 2>/dev/null; then
        print_info "Go PATH já configurado em $TARGET_RC"
        return
    fi

    # Add to shell RC
    cat >> "$TARGET_RC" << 'EOF'

# Go configuration
export GOPATH=$HOME/.go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
EOF

    # Source the file
    source "$TARGET_RC" 2>/dev/null || true

    print_success "Go PATH configurado em $TARGET_RC"
    print_info "GOPATH: $HOME/.go"
    print_info "GOROOT: /usr/local/go"

    # Install useful Go tools
    print_info "Instalando ferramentas Go úteis..."

    # Use PATH temporário para instalação
    export GOPATH=$HOME/.go
    export PATH=/usr/local/go/bin:$GOPATH/bin:$PATH

    /usr/local/go/bin/go install golang.org/x/tools/cmd/goimports@latest 2>/dev/null || print_warning "Erro ao instalar goimports"
    /usr/local/go/bin/go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest 2>/dev/null || print_warning "Erro ao instalar golangci-lint"

    print_success "Ferramentas Go instaladas"
}

# Configure SSH keys
configure_ssh() {
    print_header "Configuração de Chaves SSH"

    # Ensure .ssh directory exists
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    # Find existing SSH keys (private keys only)
    local ssh_keys=()
    while IFS= read -r key; do
        ssh_keys+=("$key")
    done < <(find "$HOME/.ssh" -maxdepth 1 -type f ! -name "*.pub" ! -name "config" ! -name "known_hosts" ! -name "authorized_keys" 2>/dev/null)

    local num_keys=${#ssh_keys[@]}

    if [ $num_keys -eq 0 ]; then
        # Cenário 1: Nenhuma chave existe
        print_info "Nenhuma chave SSH encontrada"
        create_intellisys_key
        create_ssh_config_github "$INTELLISYS_KEY"
        show_public_key "$INTELLISYS_KEY"
    elif [ $num_keys -eq 1 ]; then
        # Cenário 2: Apenas uma chave
        local key_name=$(basename "${ssh_keys[0]}")
        print_info "Encontrada 1 chave SSH: $key_name"

        read -r -p "Esta chave é da Intellisys? (s/n): " is_intellisys < /dev/tty

        if [[ "$is_intellisys" =~ ^[Ss]$ ]]; then
            INTELLISYS_KEY="${ssh_keys[0]}"
            create_ssh_config_github "$INTELLISYS_KEY"
            show_public_key "$INTELLISYS_KEY"
        else
            configure_existing_key "${ssh_keys[0]}"
            create_intellisys_key
            create_ssh_config_github "$INTELLISYS_KEY"
            show_public_key "$INTELLISYS_KEY"
        fi
    else
        # Cenário 3: Múltiplas chaves
        print_info "Encontradas $num_keys chaves SSH:"
        echo ""
        for i in "${!ssh_keys[@]}"; do
            echo "$((i+1))) $(basename "${ssh_keys[$i]}")"
        done
        echo "0) Nenhuma é da Intellisys"
        echo ""

        read -r -p "Qual destas chaves é da Intellisys? (0-$num_keys): " choice < /dev/tty

        if [ "$choice" -eq 0 ]; then
            # Nenhuma é da Intellisys
            for key in "${ssh_keys[@]}"; do
                configure_existing_key "$key"
            done
            create_intellisys_key
            create_ssh_config_github "$INTELLISYS_KEY"
            show_public_key "$INTELLISYS_KEY"
        else
            # Uma chave foi escolhida
            local idx=$((choice-1))
            INTELLISYS_KEY="${ssh_keys[$idx]}"

            for i in "${!ssh_keys[@]}"; do
                if [ $i -ne $idx ]; then
                    configure_existing_key "${ssh_keys[$i]}"
                fi
            done

            create_ssh_config_github "$INTELLISYS_KEY"
            show_public_key "$INTELLISYS_KEY"
        fi
    fi

    print_success "Configuração SSH concluída"
}

# Create Intellisys SSH key
create_intellisys_key() {
    print_info "Criando chave SSH da Intellisys..."

    read -r -p "Digite seu e-mail @intellisys.com.br: " intellisys_email < /dev/tty

    # Validate email
    if [[ ! "$intellisys_email" =~ @intellisys\.com\.br$ ]]; then
        print_warning "E-mail não termina com @intellisys.com.br, mas continuando..."
    fi

    INTELLISYS_KEY="$HOME/.ssh/id_ed25519"

    # Generate key
    ssh-keygen -a 128 -t ed25519 -C "$intellisys_email" -f "$INTELLISYS_KEY" -N "" >/dev/null 2>&1

    print_success "Chave SSH criada: $INTELLISYS_KEY"
}

# Configure existing SSH key
configure_existing_key() {
    local key_path="$1"
    local key_name=$(basename "$key_path")

    echo ""
    print_info "Configurando chave: $key_name"
    echo "1) GitHub"
    echo "2) Servidor Remoto"
    echo "3) Não usar (ignorar)"

    read -r -p "Qual o uso desta chave? (1-3): " key_usage < /dev/tty

    case $key_usage in
        1)
            # GitHub
            read -r -p "Nome/alias para esta chave GitHub (ex: personal, work): " github_alias < /dev/tty
            add_ssh_config_entry "github-$github_alias" "git" "github.com" "" "$key_path"
            ;;
        2)
            # Servidor Remoto
            read -r -p "Nome do servidor (alias): " server_alias < /dev/tty
            read -r -p "Usuário SSH: " ssh_user < /dev/tty
            read -r -p "Hostname/IP: " ssh_host < /dev/tty
            read -r -p "Porta SSH (Enter para 22): " ssh_port < /dev/tty
            ssh_port=${ssh_port:-22}

            add_ssh_config_entry "$server_alias" "$ssh_user" "$ssh_host" "$ssh_port" "$key_path"
            ;;
        3)
            print_info "Chave $key_name será ignorada"
            ;;
        *)
            print_warning "Opção inválida, ignorando chave $key_name"
            ;;
    esac
}

# Create SSH config for GitHub with Intellisys key
create_ssh_config_github() {
    local key_path="$1"

    # Backup existing config if exists
    if [ -f "$HOME/.ssh/config" ]; then
        cp "$HOME/.ssh/config" "$HOME/.ssh/config.backup.$(date +%Y%m%d%H%M%S)"
    fi

    # Create or append to config
    {
        echo ""
        echo "# GitHub - Intellisys (default)"
        echo "Host github.com"
        echo "    User git"
        echo "    Hostname github.com"
        echo "    PreferredAuthentications publickey"
        echo "    IdentityFile $key_path"
    } >> "$HOME/.ssh/config"

    chmod 600 "$HOME/.ssh/config"
}

# Add SSH config entry
add_ssh_config_entry() {
    local host="$1"
    local user="$2"
    local hostname="$3"
    local port="$4"
    local identity_file="$5"

    {
        echo ""
        echo "# $host"
        echo "Host $host"
        echo "    User $user"
        echo "    Hostname $hostname"
        if [ -n "$port" ] && [ "$port" != "22" ]; then
            echo "    Port $port"
        fi
        echo "    PreferredAuthentications publickey"
        echo "    IdentityFile $identity_file"
    } >> "$HOME/.ssh/config"

    chmod 600 "$HOME/.ssh/config"

    print_success "Configuração adicionada: $host"
}

# Show public key
show_public_key() {
    local key_path="$1"
    local pub_key_path="${key_path}.pub"

    if [ -f "$pub_key_path" ]; then
        echo ""
        print_header "Chave Pública SSH (adicione no GitHub)"
        echo ""
        cat "$pub_key_path"
        echo ""
        print_info "Copie a chave acima e adicione em: https://github.com/settings/keys"
    fi
}


# Show summary
show_summary() {
    print_header "Resumo da Instalação"

    echo -e "${GREEN}Ferramentas instaladas:${NC}\n"

    if [ "$INSTALL_ESSENTIALS" == true ]; then
        echo "✓ Zsh $(zsh --version 2>/dev/null || echo 'N/A')"
        echo "✓ Oh My Zsh $([ -d "$HOME/.oh-my-zsh" ] && echo 'Instalado' || echo 'N/A')"
        echo "✓ Starship $(starship --version 2>/dev/null || echo 'N/A')"
        echo "✓ Git $(git --version 2>/dev/null || echo 'N/A')"
        echo "✓ Git Flow $(git flow version 2>/dev/null || echo 'N/A')"
        echo "✓ Docker $(docker --version 2>/dev/null || echo 'N/A')"
        echo "✓ curl $(curl --version 2>/dev/null | head -n1 || echo 'N/A')"
        echo "✓ wget $(wget --version 2>/dev/null | head -n1 || echo 'N/A')"
        echo "✓ vim $(vim --version 2>/dev/null | head -n1 || echo 'N/A')"
        echo "✓ jq $(jq --version 2>/dev/null || echo 'N/A')"
        echo "✓ tree $(tree --version 2>/dev/null | head -n1 || echo 'N/A')"
        echo "✓ htop $(htop --version 2>/dev/null | head -n1 || echo 'N/A')"
    fi

    if [ "$INSTALL_REACT" == true ]; then
        echo ""
        echo -e "${BLUE}Ambiente ReactJS:${NC}"
        echo "✓ Node.js $(node --version 2>/dev/null || echo 'N/A')"
        echo "✓ npm $(npm --version 2>/dev/null || echo 'N/A')"
        echo "✓ yarn $(yarn --version 2>/dev/null || echo 'N/A')"
        echo "✓ pnpm $(pnpm --version 2>/dev/null || echo 'N/A')"
    fi

    if [ "$INSTALL_GO" == true ]; then
        echo ""
        echo -e "${BLUE}Ambiente Go:${NC}"
        echo "✓ Go $(go version 2>/dev/null || echo 'N/A')"
        echo "✓ GOPATH: $HOME/.go"
        echo "✓ GOROOT: /usr/local/go"
    fi

    echo ""
    print_success "Instalação concluída!"

    echo -e "\n${YELLOW}Próximos passos:${NC}"

    STEP=1
    if [ "$INSTALL_ESSENTIALS" == true ]; then
        CURRENT_SHELL=$(basename "$SHELL")
        if [ "$CURRENT_SHELL" != "zsh" ]; then
            echo "$STEP. Faça logout e login novamente para usar Zsh e Docker sem sudo"
            STEP=$((STEP + 1))
        else
            echo "$STEP. Faça logout e login novamente para usar Docker sem sudo"
            STEP=$((STEP + 1))
        fi
    fi

    if [ "$INSTALL_GO" == true ]; then
        echo "$STEP. Recarregue seu shell: source $SHELL_RC"
        STEP=$((STEP + 1))
    fi

    if [ "$INSTALL_REACT" == true ]; then
        echo "$STEP. Crie um projeto React: npm create vite@latest"
        STEP=$((STEP + 1))
    fi

    if [ "$INSTALL_GO" == true ]; then
        echo "$STEP. Teste Go: go version"
    fi
}

# Main installation flow
main() {
    show_banner
    detect_os
    detect_shell

    print_info "Shell: $SHELL_TYPE ($SHELL_RC)"
    echo ""

    ask_installation_type

    # Essential tools
    if [ "$INSTALL_ESSENTIALS" == true ]; then
        install_curl
        install_vim
        install_additional_tools
        install_zsh
        install_git
        install_git_flow
        install_docker
    fi

    # ReactJS environment
    if [ "$INSTALL_REACT" == true ]; then
        install_nodejs
    fi

    # Go environment
    if [ "$INSTALL_GO" == true ]; then
        install_go
    fi

    # Configure Git (ask at the end if not configured)
    if [ "$INSTALL_ESSENTIALS" == true ]; then
        configure_git
        configure_ssh
    fi

    # Show summary
    show_summary
}

# Run main function
main "$@"
