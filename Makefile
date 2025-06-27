# Isaac Sim Docker Project Makefile
# Facilita comandos comuns do projeto

.PHONY: help check setup build start stop restart logs shell status clean download dev

# Comando padrão
help:
	@echo "🚀 Isaac Sim Docker Project"
	@echo ""
	@echo "Comandos disponíveis:"
	@echo "  make check     - Verificar requisitos do sistema"
	@echo "  make setup     - Configuração inicial"
	@echo "  make build     - Construir imagem Docker"
	@echo "  make start     - Iniciar Isaac Sim"
	@echo "  make stop      - Parar Isaac Sim"
	@echo "  make restart   - Reiniciar Isaac Sim"
	@echo "  make logs      - Mostrar logs"
	@echo "  make shell     - Acessar shell do container"
	@echo "  make status    - Status dos containers"
	@echo "  make clean     - Limpar cache"
	@echo "  make download  - Baixar cliente WebRTC"
	@echo "  make dev       - Modo desenvolvimento"
	@echo ""
	@echo "Exemplos:"
	@echo "  make setup && make start    # Configurar e iniciar"
	@echo "  make logs                   # Ver logs"

check:
	@./scripts/manage-isaac-sim.sh check

setup:
	@./scripts/manage-isaac-sim.sh setup

build:
	@./scripts/manage-isaac-sim.sh build

start:
	@./scripts/manage-isaac-sim.sh start

stop:
	@./scripts/manage-isaac-sim.sh stop

restart:
	@./scripts/manage-isaac-sim.sh restart

logs:
	@./scripts/manage-isaac-sim.sh logs

shell:
	@./scripts/manage-isaac-sim.sh shell

status:
	@./scripts/manage-isaac-sim.sh status

clean:
	@./scripts/manage-isaac-sim.sh clean

download:
	@./scripts/manage-isaac-sim.sh download

dev:
	@./scripts/manage-isaac-sim.sh dev

# Comandos de conveniência
install-nvidia:
	@echo "🔧 Instalando NVIDIA Container Toolkit..."
	@sudo ./scripts/setup-nvidia-docker.sh

quick-start: setup build start
	@echo "🎉 Isaac Sim iniciado! Execute 'make download' para baixar o cliente WebRTC"

# Informações do projeto
info:
	@echo "📋 Informações do Projeto:"
	@echo "  Nome: Isaac Sim Docker Container"
	@echo "  Versão: 4.5.0"
	@echo "  Diretório: $(PWD)"
	@if [ -f .env ]; then echo "  Configuração: .env encontrado"; else echo "  Configuração: usar env-template"; fi
	@echo ""
	@echo "🔍 Status dos containers:"
	@docker compose ps 2>/dev/null || echo "  Docker compose não disponível" 