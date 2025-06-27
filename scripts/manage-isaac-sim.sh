#!/bin/bash

# Script principal de gerenciamento do Isaac Sim Docker
# Fornece comandos fáceis para gerenciar o container

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para mostrar ajuda
show_help() {
    echo "🚀 Isaac Sim Docker Manager"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  check       - Verificar requisitos do sistema"
    echo "  setup       - Configuração inicial (criar pastas, etc.)"
    echo "  build       - Construir imagem Docker"
    echo "  start       - Iniciar Isaac Sim container"
    echo "  stop        - Parar Isaac Sim container"
    echo "  restart     - Reiniciar Isaac Sim container"
    echo "  logs        - Mostrar logs do container"
    echo "  shell       - Acessar shell do container"
    echo "  status      - Status do container"
    echo "  clean       - Limpar cache e dados temporários"
    echo "  download    - Baixar cliente WebRTC"
    echo "  dev         - Iniciar container em modo desenvolvimento"
    echo "  help        - Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 check       # Verificar requisitos"
    echo "  $0 setup       # Configuração inicial"
    echo "  $0 start       # Iniciar Isaac Sim"
    echo "  $0 logs -f     # Acompanhar logs em tempo real"
}

# Função para verificar se Docker Compose está disponível
check_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    elif docker compose version &> /dev/null; then
        echo "docker compose"
    else
        echo -e "${RED}❌ Docker Compose não encontrado${NC}"
        exit 1
    fi
}

# Comando check
cmd_check() {
    echo -e "${BLUE}🔍 Verificando requisitos...${NC}"
    "$SCRIPT_DIR/check-requirements.sh"
}

# Comando setup
cmd_setup() {
    echo -e "${BLUE}⚙️  Configuração inicial...${NC}"
    
    # Criar estrutura de diretórios
    echo "📁 Criando estrutura de diretórios..."
    mkdir -p "$PROJECT_DIR"/{data/{cache/{kit,ov,pip,glcache,computecache},logs,documents,local},projects,downloads}
    
    # Copiar arquivo de configuração de exemplo
    if [ ! -f "$PROJECT_DIR/.env" ] && [ -f "$PROJECT_DIR/env-template" ]; then
        echo "📄 Criando arquivo .env a partir do template..."
        cp "$PROJECT_DIR/env-template" "$PROJECT_DIR/.env"
        echo -e "${YELLOW}⚠️  Edite o arquivo .env conforme necessário${NC}"
    fi
    
    # Dar permissões aos scripts
    echo "🔐 Configurando permissões dos scripts..."
    chmod +x "$SCRIPT_DIR"/*.sh
    
    echo -e "${GREEN}✅ Configuração inicial concluída!${NC}"
}

# Comando build
cmd_build() {
    echo -e "${BLUE}🏗️  Construindo imagem Docker...${NC}"
    COMPOSE_CMD=$(check_docker_compose)
    cd "$PROJECT_DIR"
    $COMPOSE_CMD build
}

# Comando start
cmd_start() {
    echo -e "${BLUE}🚀 Iniciando Isaac Sim...${NC}"
    COMPOSE_CMD=$(check_docker_compose)
    cd "$PROJECT_DIR"
    $COMPOSE_CMD up -d
    
    echo ""
    echo -e "${GREEN}✅ Isaac Sim iniciado!${NC}"
    echo ""
    echo "📋 Próximos passos:"
    echo "  1. Aguarde alguns minutos para o carregamento completo"
    echo "  2. Execute: $0 logs -f  (para acompanhar logs)"
    echo "  3. Procure pela mensagem: 'Isaac Sim Full Streaming App is loaded.'"
    echo "  4. Baixe o cliente WebRTC: $0 download"
    echo "  5. Conecte via WebRTC para: 127.0.0.1"
}

# Comando stop
cmd_stop() {
    echo -e "${BLUE}⏹️  Parando Isaac Sim...${NC}"
    COMPOSE_CMD=$(check_docker_compose)
    cd "$PROJECT_DIR"
    $COMPOSE_CMD down
    echo -e "${GREEN}✅ Isaac Sim parado!${NC}"
}

# Comando restart
cmd_restart() {
    echo -e "${BLUE}🔄 Reiniciando Isaac Sim...${NC}"
    cmd_stop
    sleep 2
    cmd_start
}

# Comando logs
cmd_logs() {
    COMPOSE_CMD=$(check_docker_compose)
    cd "$PROJECT_DIR"
    $COMPOSE_CMD logs "$@"
}

# Comando shell
cmd_shell() {
    echo -e "${BLUE}🐚 Acessando shell do container...${NC}"
    COMPOSE_CMD=$(check_docker_compose)
    cd "$PROJECT_DIR"
    $COMPOSE_CMD exec isaac-sim /bin/bash
}

# Comando status
cmd_status() {
    echo -e "${BLUE}📊 Status do container...${NC}"
    COMPOSE_CMD=$(check_docker_compose)
    cd "$PROJECT_DIR"
    $COMPOSE_CMD ps
}

# Comando clean
cmd_clean() {
    echo -e "${BLUE}🧹 Limpando cache e dados temporários...${NC}"
    
    read -p "⚠️  Isso irá remover todos os caches. Continuar? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$PROJECT_DIR/data/cache"/*
        echo -e "${GREEN}✅ Cache limpo!${NC}"
    else
        echo "Operação cancelada."
    fi
}

# Comando download
cmd_download() {
    echo -e "${BLUE}📥 Baixando cliente WebRTC...${NC}"
    "$SCRIPT_DIR/download-webrtc-client.sh"
}

# Comando dev
cmd_dev() {
    echo -e "${BLUE}👨‍💻 Iniciando modo desenvolvimento...${NC}"
    COMPOSE_CMD=$(check_docker_compose)
    cd "$PROJECT_DIR"
    $COMPOSE_CMD --profile dev up -d isaac-sim-dev
    echo -e "${GREEN}✅ Container de desenvolvimento iniciado!${NC}"
    echo "🐚 Para acessar o shell: $0 shell"
}

# Processar argumentos
case "${1:-help}" in
    check)
        cmd_check
        ;;
    setup)
        cmd_setup
        ;;
    build)
        cmd_build
        ;;
    start)
        cmd_start
        ;;
    stop)
        cmd_stop
        ;;
    restart)
        cmd_restart
        ;;
    logs)
        shift
        cmd_logs "$@"
        ;;
    shell)
        cmd_shell
        ;;
    status)
        cmd_status
        ;;
    clean)
        cmd_clean
        ;;
    download)
        cmd_download
        ;;
    dev)
        cmd_dev
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ Comando desconhecido: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac 