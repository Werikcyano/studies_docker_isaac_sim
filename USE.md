
# 📋 Resumo dos Comandos para Executar Isaac Sim Docker

## 🔧 **Configuração Inicial (apenas uma vez)**

### 1. Verificar Requisitos do Sistema
```bash
cd docker_isaac_sim
./scripts/manage-isaac-sim.sh check
```

### 2. Configurar NVIDIA Container Toolkit (se necessário)
```bash
# Configurar Docker para usar GPU NVIDIA
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Testar se funciona
docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
```

### 3. Setup Inicial do Projeto
```bash
./scripts/manage-isaac-sim.sh setup
```

### 4. Construir Imagem Docker
```bash
./scripts/manage-isaac-sim.sh build
```

## 🚀 **Comandos Para Usar Diariamente**

### Iniciar Isaac Sim
```bash
./scripts/manage-isaac-sim.sh start
# ou
make start
```

### Baixar Cliente WebRTC (apenas uma vez)
```bash
./scripts/manage-isaac-sim.sh download
# ou
make download
```

### Executar Cliente WebRTC
```bash
./downloads/isaacsim-webrtc-streaming-client-1.0.6-linux-x64.AppImage
```
**No cliente: conectar para `127.0.0.1`**

### Parar Isaac Sim
```bash
./scripts/manage-isaac-sim.sh stop
# ou
make stop
```

## 📊 **Comandos de Monitoramento**

### Ver Logs em Tempo Real
```bash
./scripts/manage-isaac-sim.sh logs -f
# ou
make logs
```

### Ver Status dos Containers
```bash
./scripts/manage-isaac-sim.sh status
# ou
make status
```

### Acessar Shell do Container
```bash
./scripts/manage-isaac-sim.sh shell
# ou
make shell
```

## 🧹 **Comandos de Manutenção**

### Reiniciar Isaac Sim
```bash
./scripts/manage-isaac-sim.sh restart
# ou
make restart
```

### Limpar Cache
```bash
./scripts/manage-isaac-sim.sh clean
# ou
make clean
```

### Reconstruir Imagem
```bash
./scripts/manage-isaac-sim.sh build
# ou
make build
```

## ⚡ **Comandos de Conveniência**

### Tudo de Uma Vez (Setup + Build + Start)
```bash
make quick-start
```

### Ver Todas as Opções Disponíveis
```bash
./scripts/manage-isaac-sim.sh help
# ou
make help
```

## 🔄 **Fluxo de Trabalho Típico**

```bash
# 1. Verificar se tudo está ok
./scripts/manage-isaac-sim.sh check

# 2. Iniciar Isaac Sim
./scripts/manage-isaac-sim.sh start

# 3. Aguardar mensagem nos logs
./scripts/manage-isaac-sim.sh logs -f
# Procurar por: "Isaac Sim Full Streaming App is loaded."

# 4. Conectar via WebRTC
./downloads/isaacsim-webrtc-streaming-client-1.0.6-linux-x64.AppImage
# Conectar para: 127.0.0.1

# 5. Quando terminar
./scripts/manage-isaac-sim.sh stop
```

## 🎯 **Comandos Essenciais para Memorizar**

| Comando | Ação |
|---------|------|
| `make start` | Iniciar Isaac Sim |
| `make stop` | Parar Isaac Sim |
| `make logs` | Ver logs |
| `make status` | Ver status |
| `make download` | Baixar cliente WebRTC |

