# Match-3 Game DevOps Project

Pipeline DevOps profissional com Terraform + Jenkins + Docker para deploy automatizado de um jogo Match-3 na AWS.

## Stack Tecnológica

### Infrastructure as Code (IaC)
- **Terraform** - Provisionamento AWS
- **AWS EC2** - Computação na nuvem
- **VPC + Security Groups** - Rede segura

### CI/CD Pipeline
- **Jenkins** - Automação DevOps
- **Git SCM** - Controle de versão
- **PowerShell** - Scripts Windows

### Containerização
- **Docker** - Containers
- **Docker Compose** - Orquestração
- **Nginx** - Proxy reverso

### Aplicação
- **Node.js** - Backend API
- **HTML5/CSS3/JavaScript** - Frontend
- **Match-3 Game Engine** - Lógica do jogo

## Quick Start

### Pré-requisitos

```bash
# Instalar Terraform
choco install terraform

# Instalar AWS CLI
choco install awscli

# Configurar credenciais AWS
aws configure
```

### Deploy Rápido

```powershell
# Pipeline completo automatizado
.\scripts\Deploy-Pipeline.ps1 -Action deploy -AutoApprove

# Ou via Jenkins
# Configurar job Jenkins apontando para Jenkinsfile
```

### Verificar Deploy

```bash
# Obter IP da instância
cd terraform
terraform output server_ip

# Testar aplicação
curl http://$(terraform output -raw server_ip)
```

## Estrutura do Projeto

```
terraform-game-project/
├── terraform/                  # Infrastructure as Code
│   ├── main.tf                # Recursos principais AWS
│   ├── variables.tf           # Variáveis Terraform
│   ├── outputs.tf             # Outputs da infraestrutura
│   ├── security_groups.tf     # Regras de segurança
│   ├── provider.tf            # Configuração AWS
│   └── user_data_production.sh # Script inicialização
│
├── game-app/                   # Aplicação Match-3
│   ├── docker-compose.yml     # Orquestração containers
│   ├── Dockerfile             # Imagem da aplicação
│   ├── src/                   # Frontend HTML/CSS/JS
│   ├── api/                   # Backend Node.js
│   └── nginx/                 # Proxy reverso
│
├── scripts/                    # Scripts automação
│   ├── deploy-application.sh  # Deploy profissional
│   └── Deploy-Pipeline.ps1    # Pipeline PowerShell
│
└── Jenkinsfile                 # Pipeline Jenkins
```

## Comandos Principais

### Deploy Manual
```bash
# 1. Inicializar Terraform
cd terraform
terraform init

# 2. Planejar mudanças
terraform plan -var="project_name=match3-game"

# 3. Aplicar infraestrutura
terraform apply -auto-approve

# 4. Deploy aplicação
../scripts/deploy-application.sh $(terraform output -raw server_ip) candy-crush-game-key.pem ../game-app
```

### Pipeline Automatizado
```powershell
# Deploy completo
.\scripts\Deploy-Pipeline.ps1 -Action deploy

# Apenas planejamento
.\scripts\Deploy-Pipeline.ps1 -Action plan

# Destruir infraestrutura
.\scripts\Deploy-Pipeline.ps1 -Action destroy
```

### Jenkins CI/CD
```yaml
# Configurar job Jenkins com:
- Repository: <seu-git-repo>
- Branch: */main
- Script Path: Jenkinsfile
- Parameters: ACTION=deploy
```

## Monitoramento

### Health Checks
```bash
# Status da aplicação
curl http://<server-ip>/health

# Status da API
curl http://<server-ip>:3000/health

# Status dos containers
ssh -i candy-crush-game-key.pem ec2-user@<server-ip>
docker-compose ps
```

## Testando o Jogo

Após o deploy bem-sucedido:

1. **Abra o navegador:** `http://<server-ip>`
2. **Teste a API:** `http://<server-ip>:3000/health`
3. **Jogue:** Combine 3 ou mais peças iguais
4. **Score:** Sistema de pontuação funcionando

## Contribuição

### Como Contribuir
1. Fork do repositório
2. Criar feature branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit das mudanças (`git commit -am 'Add: nova funcionalidade'`)
4. Push para branch (`git push origin feature/nova-funcionalidade`)
5. Criar Pull Request

## Licença

MIT License - Sinta-se livre para usar este projeto como referência para seus próprios projetos DevOps!