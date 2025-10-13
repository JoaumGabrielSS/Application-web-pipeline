#!/bin/bash

set -e

PUBLIC_IP=$1
SSH_KEY=$2
APP_DIR="/opt/game-app"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

if [ $# -lt 2 ]; then
    error "Uso: $0 <PUBLIC_IP> <SSH_KEY_PATH> [APP_SOURCE_DIR]"
    exit 1
fi

APP_SOURCE_DIR=${3:-"game-app"}

if [ ! -f "$SSH_KEY" ]; then
    error "Chave SSH não encontrada: $SSH_KEY"
    exit 1
fi

if [ ! -d "$APP_SOURCE_DIR" ]; then
    error "Diretório da aplicação não encontrado: $APP_SOURCE_DIR"
    exit 1
fi

chmod 600 "$SSH_KEY"

SSH_CMD="ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o ConnectTimeout=10 ec2-user@$PUBLIC_IP"
SCP_CMD="scp -i $SSH_KEY -o StrictHostKeyChecking=no"

log "Testando conectividade SSH..."
if ! $SSH_CMD 'echo "SSH OK"' >/dev/null 2>&1; then
    error "Falha na conectividade SSH para $PUBLIC_IP"
    exit 1
fi
success "SSH conectado com sucesso!"

log "Parando containers existentes..."
$SSH_CMD "cd $APP_DIR && docker-compose down --remove-orphans || true" 2>/dev/null || warning "Nenhum container rodando"

log "Fazendo backup da versão anterior..."
$SSH_CMD "sudo rm -rf $APP_DIR.backup && sudo cp -r $APP_DIR $APP_DIR.backup 2>/dev/null || true"

log "Criando diretório da aplicação..."
$SSH_CMD "sudo mkdir -p $APP_DIR && sudo chown ec2-user:ec2-user $APP_DIR"

log "Transferindo arquivos da aplicação..."
if command -v rsync >/dev/null 2>&1; then
    rsync -avz -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=no" \
          --exclude='.git' --exclude='node_modules' --exclude='*.log' \
          "$APP_SOURCE_DIR/" ec2-user@$PUBLIC_IP:$APP_DIR/
else
    $SCP_CMD -r "$APP_SOURCE_DIR"/* ec2-user@$PUBLIC_IP:$APP_DIR/
fi

log "Construindo e iniciando containers..."
$SSH_CMD "cd $APP_DIR && docker-compose build --no-cache"
$SSH_CMD "cd $APP_DIR && docker-compose up -d"

log "Aguardando containers iniciarem..."
sleep 15

log "Verificando status dos containers..."
CONTAINER_STATUS=$($SSH_CMD "cd $APP_DIR && docker-compose ps --format table" 2>/dev/null || echo "Erro ao verificar containers")
echo "$CONTAINER_STATUS"

log "Testando aplicação web..."
for i in {1..10}; do
    if curl -f -s -m 5 "http://$PUBLIC_IP" >/dev/null 2>&1; then
        success "Aplicação web respondendo!"
        break
    fi
    warning "Tentativa $i/10 - aguardando aplicação..."
    sleep 10
done

log "Testando API..."
if curl -f -s -m 5 "http://$PUBLIC_IP:3000/health" >/dev/null 2>&1; then
    success "API respondendo!"
else
    warning "API não respondeu (pode estar inicializando)"
fi

log "Verificando logs dos containers..."
$SSH_CMD "cd $APP_DIR && docker-compose logs --tail=20"

success "Deploy concluído com sucesso!"
echo ""
echo "Aplicação disponível em:"
echo "  Web: http://$PUBLIC_IP"
echo "  API: http://$PUBLIC_IP:3000"
echo ""
echo "Para verificar status:"
echo "  ssh -i $SSH_KEY ec2-user@$PUBLIC_IP 'cd $APP_DIR && docker-compose ps'"