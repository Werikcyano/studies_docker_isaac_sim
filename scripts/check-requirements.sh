#!/bin/bash

# Script para verificar requisitos do sistema para Isaac Sim
# Baseado nos requisitos documentados

set -e

echo "🔍 Verificando requisitos do sistema para Isaac Sim..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para verificar requisitos
check_requirement() {
    local name="$1"
    local command="$2"
    local requirement="$3"
    
    echo -n "  Verificando $name... "
    
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}✓${NC} $requirement"
        return 0
    else
        echo -e "${RED}✗${NC} $requirement"
        return 1
    fi
}

# Função para verificar versão mínima
check_version() {
    local name="$1"
    local current="$2"
    local minimum="$3"
    
    echo -n "  Verificando versão do $name... "
    
    if [ "$(printf '%s\n' "$minimum" "$current" | sort -V | head -n1)" = "$minimum" ]; then
        echo -e "${GREEN}✓${NC} $current (mínimo: $minimum)"
        return 0
    else
        echo -e "${RED}✗${NC} $current (mínimo: $minimum)"
        return 1
    fi
}

echo ""
echo "📋 Verificações do Sistema:"

# 1. Verificar Docker
if ! command -v docker &> /dev/null; then
    echo -e "  ${RED}✗${NC} Docker não encontrado"
    MISSING_DOCKER=true
else
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    check_version "Docker" "$DOCKER_VERSION" "20.10.0"
fi

# 2. Verificar Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "  ${RED}✗${NC} Docker Compose não encontrado"
    MISSING_COMPOSE=true
else
    echo -e "  ${GREEN}✓${NC} Docker Compose encontrado"
fi

# 3. Verificar NVIDIA Driver
if ! command -v nvidia-smi &> /dev/null; then
    echo -e "  ${RED}✗${NC} NVIDIA Driver não encontrado"
    MISSING_NVIDIA=true
else
    NVIDIA_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | head -1)
    check_version "NVIDIA Driver" "$NVIDIA_VERSION" "535.129.03"
fi

# 4. Verificar NVIDIA Container Toolkit
if ! docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi &>/dev/null; then
    echo -e "  ${RED}✗${NC} NVIDIA Container Toolkit não configurado"
    MISSING_NVIDIA_TOOLKIT=true
else
    echo -e "  ${GREEN}✓${NC} NVIDIA Container Toolkit funcionando"
fi

# 5. Verificar GPU compatível
if command -v nvidia-smi &> /dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
    echo -e "  ${GREEN}✓${NC} GPU detectada: $GPU_INFO"
    
    # Verificar VRAM
    VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -1)
    if [ "$VRAM" -ge 8000 ]; then
        echo -e "  ${GREEN}✓${NC} VRAM: ${VRAM}MB (mínimo: 8GB)"
    else
        echo -e "  ${YELLOW}⚠${NC} VRAM: ${VRAM}MB (recomendado: 8GB+)"
    fi
fi

# 6. Verificar RAM do sistema
TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2/1024}')
if [ "$TOTAL_RAM" -ge 32 ]; then
    echo -e "  ${GREEN}✓${NC} RAM: ${TOTAL_RAM}GB (mínimo: 32GB)"
elif [ "$TOTAL_RAM" -ge 16 ]; then
    echo -e "  ${YELLOW}⚠${NC} RAM: ${TOTAL_RAM}GB (recomendado: 32GB+)"
else
    echo -e "  ${RED}✗${NC} RAM: ${TOTAL_RAM}GB (mínimo: 32GB)"
fi

# 7. Verificar espaço em disco
DISK_SPACE=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$DISK_SPACE" -ge 50 ]; then
    echo -e "  ${GREEN}✓${NC} Espaço em disco: ${DISK_SPACE}GB (mínimo: 50GB)"
else
    echo -e "  ${RED}✗${NC} Espaço em disco: ${DISK_SPACE}GB (mínimo: 50GB)"
fi

echo ""

# Resumo
if [ -z "$MISSING_DOCKER" ] && [ -z "$MISSING_COMPOSE" ] && [ -z "$MISSING_NVIDIA" ] && [ -z "$MISSING_NVIDIA_TOOLKIT" ]; then
    echo -e "${GREEN}🎉 Todos os requisitos essenciais foram atendidos!${NC}"
    echo ""
    echo "Para iniciar o Isaac Sim:"
    echo "  docker-compose up -d"
    echo ""
    echo "Para acessar via WebRTC:"
    echo "  Baixe o Isaac Sim WebRTC Streaming Client em:"
    echo "  https://download.isaacsim.omniverse.nvidia.com/isaacsim-webrtc-streaming-client-1.0.6-linux-x64.AppImage"
else
    echo -e "${RED}❌ Alguns requisitos não foram atendidos.${NC}"
    echo ""
    echo "Instale os componentes em falta antes de continuar:"
    [ ! -z "$MISSING_DOCKER" ] && echo "  - Docker: https://docs.docker.com/engine/install/"
    [ ! -z "$MISSING_COMPOSE" ] && echo "  - Docker Compose: https://docs.docker.com/compose/install/"
    [ ! -z "$MISSING_NVIDIA" ] && echo "  - NVIDIA Driver: https://www.nvidia.com/drivers/"
    [ ! -z "$MISSING_NVIDIA_TOOLKIT" ] && echo "  - NVIDIA Container Toolkit: https://github.com/NVIDIA/nvidia-container-toolkit"
fi 