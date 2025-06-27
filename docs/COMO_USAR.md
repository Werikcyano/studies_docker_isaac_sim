# Como Usar o Isaac Sim Docker

Este guia explica como usar o projeto Docker Isaac Sim para executar o simulador NVIDIA Isaac Sim em container com acesso à interface gráfica via WebRTC.

## 🚀 Início Rápido

### 1. Verificar Requisitos
```bash
# Verificar se o sistema atende aos requisitos
./scripts/manage-isaac-sim.sh check
# ou
make check
```

### 2. Configuração Inicial
```bash
# Configurar projeto (criar pastas, permissões, etc.)
./scripts/manage-isaac-sim.sh setup
# ou
make setup
```

### 3. Iniciar Isaac Sim
```bash
# Construir e iniciar o container
./scripts/manage-isaac-sim.sh build
./scripts/manage-isaac-sim.sh start

# ou usando make
make build
make start

# ou tudo de uma vez
make quick-start
```

### 4. Baixar Cliente WebRTC
```bash
# Baixar cliente para visualizar a interface
./scripts/manage-isaac-sim.sh download
# ou
make download
```

### 5. Conectar via WebRTC
1. Execute o cliente WebRTC baixado
2. Conecte para o IP: `127.0.0.1`
3. Aguarde o carregamento do Isaac Sim

## 📋 Comandos Disponíveis

### Scripts Bash
```bash
# Script principal de gerenciamento
./scripts/manage-isaac-sim.sh [comando]

# Comandos disponíveis:
./scripts/manage-isaac-sim.sh check       # Verificar requisitos
./scripts/manage-isaac-sim.sh setup       # Configuração inicial  
./scripts/manage-isaac-sim.sh build       # Construir imagem
./scripts/manage-isaac-sim.sh start       # Iniciar container
./scripts/manage-isaac-sim.sh stop        # Parar container
./scripts/manage-isaac-sim.sh restart     # Reiniciar container
./scripts/manage-isaac-sim.sh logs        # Ver logs
./scripts/manage-isaac-sim.sh shell       # Acessar shell
./scripts/manage-isaac-sim.sh status      # Status containers
./scripts/manage-isaac-sim.sh clean       # Limpar cache
./scripts/manage-isaac-sim.sh download    # Baixar WebRTC client
./scripts/manage-isaac-sim.sh dev         # Modo desenvolvimento
```

### Makefile (Alternativa)
```bash
make check     # Verificar requisitos
make setup     # Configuração inicial
make build     # Construir imagem
make start     # Iniciar Isaac Sim
make stop      # Parar Isaac Sim
make restart   # Reiniciar Isaac Sim
make logs      # Mostrar logs
make shell     # Acessar shell
make status    # Status containers
make clean     # Limpar cache
make download  # Baixar cliente WebRTC
make dev       # Modo desenvolvimento
```

### Docker Compose Direto
```bash
# Construir imagem
docker-compose build

# Iniciar serviços
docker-compose up -d

# Ver logs
docker-compose logs -f

# Parar serviços
docker-compose down

# Modo desenvolvimento
docker-compose --profile dev up -d isaac-sim-dev
```

## 🔧 Configurações

### Arquivo .env
Copie `env-template` para `.env` e ajuste conforme necessário:

```bash
cp env-template .env
# Editar .env conforme necessário
```

### Configurações Importantes
- **USER_ID/GROUP_ID**: Ajustar para seu usuário local
- **NVIDIA_VISIBLE_DEVICES**: Especificar GPUs específicas
- **RMW_IMPLEMENTATION**: Para uso com ROS2

### Volumes Persistentes
O projeto cria os seguintes volumes para persistência:
- `./data/cache/`: Cache do Isaac Sim
- `./data/logs/`: Logs do sistema
- `./data/documents/`: Documentos do usuário
- `./projects/`: Seus projetos personalizados

## 🌐 Acesso Remoto

### Mesmo Computador
1. Inicie o Isaac Sim: `make start`
2. Execute o cliente WebRTC
3. Conecte para: `127.0.0.1`

### Rede Local
1. Configure FastDDS para UDP:
   ```bash
   export FASTRTPS_DEFAULT_PROFILES_FILE=$(pwd)/configs/fastdds.xml
   ```
2. Inicie Isaac Sim
3. No cliente WebRTC, use o IP do servidor

### Múltiplas Máquinas (ROS2)
Para usar ROS2 entre máquinas:

1. Configure FastDDS em todas as máquinas:
   ```bash
   export FASTRTPS_DEFAULT_PROFILES_FILE=/caminho/para/fastdds.xml
   export ROS_DOMAIN_ID=0
   ```

2. Certifique-se que as portas estão abertas:
   - 7400, 7410, 9387 (FastDDS)
   - 8211, 8899 (WebRTC)

## 🐞 Solução de Problemas

### Container não inicia
1. Verificar requisitos: `make check`
2. Verificar logs: `make logs`
3. Verificar NVIDIA Toolkit: `docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi`

### Isaac Sim não carrega
1. Aguardar alguns minutos (primeira execução demora)
2. Verificar logs: `make logs -f`
3. Procurar por: "Isaac Sim Full Streaming App is loaded."

### Cliente WebRTC não conecta
1. Verificar se Isaac Sim terminou de carregar
2. Verificar firewall nas portas 8211, 8899
3. Tentar reiniciar: `make restart`

### Performance baixa
1. Verificar VRAM disponível: `nvidia-smi`
2. Limpar cache: `make clean`
3. Verificar se está usando GPU correta

### ROS2 não funciona
1. Verificar configuração FastDDS
2. Verificar ROS_DOMAIN_ID
3. Testar comunicação: `ros2 topic list`

## 🚀 Modo Desenvolvimento

Para desenvolvimento avançado:

```bash
# Iniciar container de desenvolvimento
make dev

# Acessar shell
make shell

# Montar projetos personalizados em ./projects/
# Executar scripts customizados em ./scripts/
```

## 📚 Recursos Adicionais

- [Documentação Isaac Sim](https://docs.omniverse.nvidia.com/isaacsim/latest/)
- [Requisitos do Sistema](https://docs.omniverse.nvidia.com/isaacsim/latest/installation/requirements.html)
- [Instalação Container](https://docs.omniverse.nvidia.com/isaacsim/latest/installation/install_container.html)
- [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-container-toolkit)

## 📞 Suporte

Em caso de problemas:
1. Verificar logs: `make logs`
2. Verificar requisitos: `make check`
3. Consultar documentação oficial da NVIDIA
4. Verificar issues conhecidos no repositório Isaac Sim 