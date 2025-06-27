#!/bin/bash

# Script para instalação automática do NVIDIA Container Toolkit
# Baseado na documentação oficial da NVIDIA

set -e

echo "🚀 Instalação do NVIDIA Container Toolkit"
echo "=========================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Função para verificar se comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Este script precisa ser executado como root (sudo)${NC}"
    exit 1
fi

# Verificar distribuição Linux
if [ ! -f /etc/os-release ]; then
    echo -e "${RED}❌ Não foi possível detectar a distribuição Linux${NC}"
    exit 1
fi

source /etc/os-release

echo -e "${BLUE}🔍 Distribuição detectada: $ID $VERSION_ID${NC}"

# Verificar se é Ubuntu/Debian
if [ "$ID" != "ubuntu" ] && [ "$ID" != "debian" ]; then
    echo -e "${YELLOW}⚠️  Este script foi testado apenas no Ubuntu/Debian${NC}"
    read -p "Continuar mesmo assim? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}📋 Verificando pré-requisitos...${NC}"

# 1. Verificar Docker
if ! command_exists docker; then
    echo -e "${RED}❌ Docker não encontrado${NC}"
    echo "Instale o Docker primeiro: https://docs.docker.com/engine/install/"
    exit 1
else
    echo -e "${GREEN}✅ Docker encontrado${NC}"
fi

# 2. Verificar NVIDIA Driver
if ! command_exists nvidia-smi; then
    echo -e "${RED}❌ Driver NVIDIA não encontrado${NC}"
    echo "Instale o driver NVIDIA primeiro: https://www.nvidia.com/drivers/"
    exit 1
else
    NVIDIA_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | head -1)
    echo -e "${GREEN}✅ Driver NVIDIA encontrado: v$NVIDIA_VERSION${NC}"
fi

# 3. Verificar se NVIDIA Container Toolkit já está instalado
if command_exists nvidia-ctk; then
    echo -e "${YELLOW}⚠️  NVIDIA Container Toolkit já parece estar instalado${NC}"
    read -p "Reinstalar? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Saindo..."
        exit 0
    fi
fi

echo ""
echo -e "${BLUE}🔧 Instalando NVIDIA Container Toolkit...${NC}"

# Configurar repositório
echo "📦 Configurando repositório..."
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Atualizar lista de pacotes
echo "🔄 Atualizando lista de pacotes..."
apt-get update

# Instalar NVIDIA Container Toolkit
echo "📥 Instalando NVIDIA Container Toolkit..."
apt-get install -y nvidia-container-toolkit

# Configurar Docker runtime
echo "⚙️  Configurando Docker runtime..."
nvidia-ctk runtime configure --runtime=docker

# Reiniciar Docker
echo "🔄 Reiniciando Docker..."
systemctl restart docker

echo ""
echo -e "${BLUE}🧪 Testando instalação...${NC}"

# Testar se funciona
if docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi; then
    echo ""
    echo -e "${GREEN}🎉 NVIDIA Container Toolkit instalado com sucesso!${NC}"
    echo ""
    echo "Próximos passos:"
    echo "  1. Execute: ./scripts/manage-isaac-sim.sh check"
    echo "  2. Execute: ./scripts/manage-isaac-sim.sh setup"
    echo "  3. Execute: ./scripts/manage-isaac-sim.sh start"
else
    echo ""
    echo -e "${RED}❌ Teste falhou. Algo deu errado na instalação.${NC}"
    echo ""
    echo "Possíveis soluções:"
    echo "  1. Reinicie o sistema"
    echo "  2. Verifique os logs: journalctl -u docker.service"
    echo "  3. Reinstale o driver NVIDIA"
    exit 1
fi 