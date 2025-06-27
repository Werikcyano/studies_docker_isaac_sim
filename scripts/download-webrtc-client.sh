#!/bin/bash

# Script para baixar o Isaac Sim WebRTC Streaming Client
# Detecta automaticamente a plataforma e baixa a versão apropriada

set -e

echo "📥 Baixando Isaac Sim WebRTC Streaming Client..."

# Detectar plataforma
PLATFORM=""
ARCH=""

case "$(uname -s)" in
    Linux*)
        PLATFORM="linux"
        case "$(uname -m)" in
            x86_64) ARCH="x64" ;;
            *) echo "Arquitetura não suportada: $(uname -m)"; exit 1 ;;
        esac
        ;;
    Darwin*)
        PLATFORM="macos"
        case "$(uname -m)" in
            x86_64) ARCH="x64" ;;
            arm64) ARCH="arm64" ;;
            *) echo "Arquitetura não suportada: $(uname -m)"; exit 1 ;;
        esac
        ;;
    CYGWIN*|MINGW32*|MSYS*|MINGW*)
        PLATFORM="windows"
        ARCH="x64"
        ;;
    *)
        echo "Plataforma não suportada: $(uname -s)"
        exit 1
        ;;
esac

echo "🖥️  Plataforma detectada: $PLATFORM-$ARCH"

# URLs de download
VERSION="1.0.6"
BASE_URL="https://download.isaacsim.omniverse.nvidia.com"

case "$PLATFORM-$ARCH" in
    "linux-x64")
        FILE="isaacsim-webrtc-streaming-client-${VERSION}-linux-x64.AppImage"
        URL="${BASE_URL}/${FILE}"
        ;;
    "windows-x64")
        FILE="isaacsim-webrtc-streaming-client-${VERSION}-windows-x64.exe"
        URL="${BASE_URL}/${FILE}"
        ;;
    "macos-x64")
        FILE="isaacsim-webrtc-streaming-client-${VERSION}-macos-x64.dmg"
        URL="${BASE_URL}/${FILE}"
        ;;
    "macos-arm64")
        FILE="isaacsim-webrtc-streaming-client-${VERSION}-macos-arm64.dmg"
        URL="${BASE_URL}/${FILE}"
        ;;
    *)
        echo "Combinação plataforma-arquitetura não suportada: $PLATFORM-$ARCH"
        exit 1
        ;;
esac

# Criar diretório de downloads se não existir
DOWNLOAD_DIR="$(dirname "$0")/../downloads"
mkdir -p "$DOWNLOAD_DIR"

echo "📥 Baixando de: $URL"
echo "📁 Salvando em: $DOWNLOAD_DIR/$FILE"

# Baixar arquivo
if command -v curl &> /dev/null; then
    curl -L -o "$DOWNLOAD_DIR/$FILE" "$URL"
elif command -v wget &> /dev/null; then
    wget -O "$DOWNLOAD_DIR/$FILE" "$URL"
else
    echo "❌ Erro: curl ou wget não encontrado"
    echo "   Instale curl ou wget para continuar"
    exit 1
fi

# Dar permissão de execução para Linux
if [ "$PLATFORM" = "linux" ]; then
    chmod +x "$DOWNLOAD_DIR/$FILE"
    echo "✅ Download concluído! Execute o cliente com:"
    echo "   $DOWNLOAD_DIR/$FILE"
else
    echo "✅ Download concluído! Arquivo salvo em:"
    echo "   $DOWNLOAD_DIR/$FILE"
fi

echo ""
echo "🔗 Para conectar ao Isaac Sim:"
echo "   1. Execute o Isaac Sim container: docker-compose up -d"
echo "   2. Aguarde a mensagem 'Isaac Sim Full Streaming App is loaded.'"
echo "   3. Execute o cliente WebRTC e conecte para 127.0.0.1"
echo ""
echo "📖 Documentação: https://docs.omniverse.nvidia.com/isaacsim/latest/installation/install_container.html" 