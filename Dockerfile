# Isaac Sim Docker Container com suporte a GUI via WebRTC
FROM nvcr.io/nvidia/isaac-sim:4.5.0

# Informações do container
LABEL maintainer="Isaac Sim Development Team"
LABEL description="Isaac Sim 4.5.0 with WebRTC streaming support"
LABEL version="4.5.0"

# Definir variáveis de ambiente padrão
ENV ACCEPT_EULA=Y
ENV PRIVACY_CONSENT=Y
ENV DISPLAY=:1
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

# Criar usuário não-root para desenvolvimento (opcional)
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=isaac

# Instalar dependências adicionais se necessário
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    vim \
    nano \
    htop \
    git \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Criar usuário desenvolvimento (verificar se já existe)
RUN if ! getent group ${GROUP_ID} >/dev/null; then groupadd -g ${GROUP_ID} ${USERNAME}; fi && \
    if ! id -u ${USERNAME} >/dev/null 2>&1; then useradd -u ${USER_ID} -g ${GROUP_ID} -m -s /bin/bash ${USERNAME}; fi && \
    usermod -aG sudo ${USERNAME} || true

# Criar diretórios para cache e dados
RUN mkdir -p /isaac-sim/cache && \
    mkdir -p /isaac-sim/logs && \
    mkdir -p /isaac-sim/data && \
    mkdir -p /isaac-sim/documents && \
    mkdir -p /isaac-sim/projects

# Definir diretório de trabalho
WORKDIR /isaac-sim

# Copiar scripts customizados se existirem
COPY scripts/ /isaac-sim/scripts/

# Dar permissões de execução aos scripts
RUN chmod +x /isaac-sim/*.sh
RUN chmod +x /isaac-sim/scripts/*.sh

# Expor portas para WebRTC streaming
EXPOSE 8211 8899 8899/udp

# Script de entrada padrão para executar Isaac Sim em modo streaming
CMD ["/isaac-sim/runheadless.sh", "-v"] 