#!/bin/bash

# Script para inicializar Isaac Sim com configurações otimizadas
# Baseado na documentação oficial da NVIDIA

set -e

echo "🚀 Iniciando Isaac Sim..."

# Configurações de ambiente
export ACCEPT_EULA=Y
export PRIVACY_CONSENT=Y

# Configurações de performance
export OMNI_KIT_DISABLE_AUTH_FROM_URL=1
export OMNI_KIT_ACCEPT_EULA=Y

# Verificar se GPU NVIDIA está disponível
if ! nvidia-smi &> /dev/null; then
    echo "❌ Erro: GPU NVIDIA não detectada ou drivers não instalados"
    echo "   Verifique se o NVIDIA Container Toolkit está configurado"
    exit 1
fi

echo "✅ GPU NVIDIA detectada:"
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader

# Verificar se o diretório de cache existe e criar se necessário
CACHE_DIRS=(
    "/isaac-sim/kit/cache"
    "/root/.cache/ov"
    "/root/.cache/nvidia/GLCache"
    "/root/.nv/ComputeCache"
)

for dir in "${CACHE_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "📁 Criando diretório de cache: $dir"
        mkdir -p "$dir"
    fi
done

echo "⚡ Aquecendo cache de shaders..."
# Executar warmup se disponível
if [ -f "/isaac-sim/warmup.sh" ]; then
    /isaac-sim/warmup.sh
fi

echo "🌐 Iniciando Isaac Sim em modo streaming..."
echo "   Aguarde alguns minutos para o primeiro carregamento"
echo "   Procure pela mensagem: 'Isaac Sim Full Streaming App is loaded.'"

# Executar Isaac Sim em modo headless com streaming
exec /isaac-sim/runheadless.sh -v 