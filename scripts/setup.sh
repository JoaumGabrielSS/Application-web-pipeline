#!/bin/bash

# =============================================================================
# SCRIPT DE SETUP INICIAL - TERRAFORM GAME PROJECT
# =============================================================================
# Descrição: Configura o ambiente local para desenvolvimento
# Uso: ./scripts/setup.sh
# =============================================================================

set -euo pipefail

PROJECT_NAME="terraform-game-project"
TERRAFORM_DIR="./terraform"
SCRIPTS_DIR="./scripts"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

error() {
    echo "❌ ERRO: $1" >&2
    exit 1
}

success() {
    echo "✅ $1"
}

log "🚀 Iniciando setup do projeto $PROJECT_NAME..."

if ! command -v terraform &> /dev/null; then
    error "Terraform não encontrado. Instale: https://www.terraform.io/downloads"
fi

if ! command -v aws &> /dev/null; then
    error "AWS CLI não encontrado. Instale: https://aws.amazon.com/cli/"
fi

if ! command -v docker &> /dev/null; then
    error "Docker não encontrado. Instale: https://www.docker.com/"
fi

log "📋 Verificando credenciais AWS..."
if ! aws sts get-caller-identity &> /dev/null; then
    error "Credenciais AWS não configuradas. Execute: aws configure"
fi

aws_account=$(aws sts get-caller-identity --query Account --output text)
aws_region=$(aws configure get region)
success "AWS Account: $aws_account | Região: ${aws_region:-us-east-1}"

log "📁 Verificando estrutura do projeto..."
required_dirs=("terraform" "game-app" "scripts")
for dir in "${required_dirs[@]}"; do
    if [[ ! -d "$dir" ]]; then
        error "Diretório '$dir' não encontrado"
    fi
    success "Diretório '$dir' existe"
done

log "🔧 Configurando permissões dos scripts..."
chmod +x "$SCRIPTS_DIR"/*.sh 2>/dev/null || true
success "Permissões configuradas"

log "🔑 Verificando chave SSH..."
SSH_KEY_PATH="$TERRAFORM_DIR/candy-crush-game-key.pem"
if [[ ! -f "$SSH_KEY_PATH" ]]; then
    log "Chave SSH não encontrada. Será criada pelo Terraform."
else
    chmod 600 "$SSH_KEY_PATH"
    success "Chave SSH configurada: $SSH_KEY_PATH"
fi

log "🏗️  Inicializando Terraform..."
cd "$TERRAFORM_DIR"

if [[ ! -f "terraform.tfvars" ]]; then
    if [[ -f "terraform.tfvars.example" ]]; then
        log "Copiando terraform.tfvars.example para terraform.tfvars..."
        cp terraform.tfvars.example terraform.tfvars
        log "⚠️  IMPORTANTE: Edite terraform.tfvars com seus valores reais!"
    else
        error "Arquivo terraform.tfvars.example não encontrado"
    fi
fi

terraform init
terraform fmt
terraform validate

cd - > /dev/null

log "🎮 Verificando aplicação do jogo..."
if [[ -f "game-app/docker-compose.yml" ]]; then
    success "Docker Compose encontrado"
else
    error "Arquivo docker-compose.yml não encontrado em game-app/"
fi

log "✨ Setup concluído com sucesso!"
echo ""
echo "📖 PRÓXIMOS PASSOS:"
echo "1. Edite terraform/terraform.tfvars com suas configurações"
echo "2. Execute: terraform plan (para verificar recursos)"
echo "3. Execute: terraform apply (para criar infraestrutura)"
echo "4. Execute: ./scripts/deploy-application.sh (para deploy da app)"
echo ""
success "Ambiente pronto para desenvolvimento! 🎉"