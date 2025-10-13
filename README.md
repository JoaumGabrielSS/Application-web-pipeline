# 🎮 Match-3 Game DevOps Project

**Pipeline DevOps PROFISSIONAL** com Terraform + Jenkins + Docker para deploy automatizado de um jogo Match-3 na AWS.

## 🚀 **ARQUITETURA DEVOPS COMPLETA**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   DEVELOPER     │───▶│    JENKINS       │───▶│   AWS CLOUD     │
│                 │    │                  │    │                 │
│ • Git Push      │    │ • CI/CD Pipeline │    │ • EC2 Instance  │
│ • Pull Request  │    │ • Terraform      │    │ • Auto Scaling  │
│ • Code Review   │    │ • Docker Deploy  │    │ • Load Balancer │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                               │
                       ┌───────▼───────┐
                       │   MONITORING  │
                       │               │
                       │ • Health Check│
                       │ • Alerts      │
                       │ • Metrics     │
                       └───────────────┘
```

## 📋 **STACK TECNOLÓGICA**

### **Infrastructure as Code (IaC)**
- **Terraform** 🏗️ - Provisionamento AWS
- **AWS EC2** ☁️ - Computação na nuvem
- **VPC + Security Groups** 🔒 - Rede segura

### **CI/CD Pipeline**
- **Jenkins** 🤖 - Automação DevOps
- **Git SCM** 📚 - Controle de versão
- **PowerShell** 💻 - Scripts Windows

### **Containerização**
- **Docker** 🐋 - Containers
- **Docker Compose** 📦 - Orquestração
- **Nginx** ⚡ - Proxy reverso

### **Aplicação**
- **Node.js** 🟢 - Backend API
- **HTML5/CSS3/JavaScript** 🎨 - Frontend
- **Match-3 Game Engine** 🎮 - Lógica do jogo

## 🎯 **FEATURES DEVOPS PROFISSIONAIS**

### ✅ **Automação Completa**
- Deploy zero-downtime
- Rollback automático em falhas
- Health checks integrados
- Notificações Slack/Email

### ✅ **Segurança**
- SSH key-based authentication
- Security groups restritivos
- Secrets management
- Encrypted storage

### ✅ **Monitoramento**
- Application health checks
- Infrastructure monitoring
- Log aggregation
- Performance metrics

### ✅ **Escalabilidade**
- Auto Scaling Groups
- Load Balancing
- Multi-AZ deployment
- Database replication

## 🚀 **QUICK START**

### **1️⃣ Pré-requisitos**

```powershell
# Instalar Terraform
choco install terraform

# Instalar AWS CLI
choco install awscli

# Configurar credenciais AWS
aws configure
```

### **2️⃣ Clone e Setup**

```bash
git clone <seu-repositorio>
cd terraform-game-project

# Dar permissões aos scripts
chmod +x scripts/*.sh
```

### **3️⃣ Deploy Rápido**

```powershell
# Pipeline completo automatizado
.\scripts\Deploy-Pipeline.ps1 -Action deploy -AutoApprove

# Ou via Jenkins
# Configurar job Jenkins apontando para Jenkinsfile-Production
```

### **4️⃣ Verificar Deploy**

```bash
# Obter IP da instância
cd terraform
terraform output server_ip

# Testar aplicação
curl http://$(terraform output -raw server_ip)
```

## 📁 **ESTRUTURA DO PROJETO**

```
terraform-game-project/
├── 📁 terraform/                  # Infrastructure as Code
│   ├── main.tf                   # Recursos principais AWS
│   ├── variables.tf              # Variáveis Terraform
│   ├── outputs.tf                # Outputs da infraestrutura
│   ├── security_groups.tf        # Regras de segurança
│   ├── ec2.tf                    # Configuração EC2
│   ├── provider.tf               # Configuração AWS
│   └── user_data_production.sh   # Script inicialização
│
├── 📁 game-app/                   # Aplicação Match-3
│   ├── docker-compose.yml        # Orquestração containers
│   ├── Dockerfile                # Imagem da aplicação
│   ├── 📁 src/                   # Frontend HTML/CSS/JS
│   │   ├── index.html
│   │   ├── css/game.css
│   │   └── js/game.js
│   ├── 📁 api/                   # Backend Node.js
│   │   ├── server.js
│   │   ├── package.json
│   │   └── routes/users.js
│   └── 📁 nginx/                 # Proxy reverso
│       ├── Dockerfile
│       └── nginx.conf
│
├── 📁 scripts/                    # Scripts automação
│   ├── deploy-application.sh     # Deploy profissional
│   ├── Deploy-Pipeline.ps1       # Pipeline PowerShell
│   ├── setup.sh                  # Configuração inicial
│   └── deploy.sh                 # Deploy básico
│
├── 📋 Jenkinsfile                 # Pipeline original
├── 📋 Jenkinsfile-Production      # Pipeline PROFISSIONAL
└── 📖 README.md                   # Esta documentação
```

## 🔧 **COMANDOS PRINCIPAIS**

### **Deploy Manual**
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

### **Pipeline Automatizado**
```powershell
# Deploy completo
.\scripts\Deploy-Pipeline.ps1 -Action deploy

# Apenas planejamento
.\scripts\Deploy-Pipeline.ps1 -Action plan

# Destruir infraestrutura
.\scripts\Deploy-Pipeline.ps1 -Action destroy
```

### **Jenkins CI/CD**
```yaml
# Configurar job Jenkins com:
- Repository: <seu-git-repo>
- Branch: */main
- Script Path: Jenkinsfile-Production
- Parameters: ACTION=deploy
```

## 🔍 **MONITORAMENTO E LOGS**

### **Health Checks**
```bash
# Status da aplicação
curl http://<server-ip>/health

# Status da API
curl http://<server-ip>:3000/health

# Status dos containers
ssh -i candy-crush-game-key.pem ec2-user@<server-ip>
docker-compose ps
```

### **Logs de Sistema**
```bash
# Logs da aplicação
sudo journalctl -u docker -f

# Logs do Nginx
docker-compose logs nginx

# Logs da API
docker-compose logs api
```

## 🎮 **TESTANDO O JOGO**

Após o deploy bem-sucedido:

1. **Abra o navegador:** `http://<server-ip>`
2. **Teste a API:** `http://<server-ip>:3000/health`
3. **Jogue:** Combine 3 ou mais peças iguais
4. **Score:** Sistema de pontuação funcionando

## 🛠️ **TROUBLESHOOTING**

### **Problemas Comuns**

#### ❌ Terraform falha
```bash
# Verificar credenciais
aws sts get-caller-identity

# Limpar estado
terraform refresh
```

#### ❌ SSH não conecta
```bash
# Verificar security group
aws ec2 describe-security-groups --group-names match3-game-sg

# Testar conectividade
nc -zv <server-ip> 22
```

#### ❌ Aplicação não carrega
```bash
# Verificar containers
ssh -i key.pem ec2-user@<ip> 'docker-compose ps'

# Verificar logs
ssh -i key.pem ec2-user@<ip> 'docker-compose logs'
```

#### ❌ Health check falha
```bash
# Verificar portas
nmap <server-ip> -p 80,3000

# Verificar firewall
ssh -i key.pem ec2-user@<ip> 'sudo firewall-cmd --list-all'
```

## 📊 **MÉTRICAS DE SUCESSO**

### **Performance Targets**
- ⏱️ **Deploy Time:** < 10 minutos
- 🚀 **Application Start:** < 2 minutos  
- 🎯 **Health Check:** < 30 segundos
- 💾 **Resource Usage:** < 80%

### **Reliability Targets**
- 🔄 **Uptime:** > 99.9%
- 🛠️ **Recovery Time:** < 5 minutos
- 📈 **Success Rate:** > 95%
- 🔒 **Security Compliance:** 100%

## 🎯 **ROADMAP EVOLUTIVO**

### **Fase 1 - MVP** ✅
- [x] Terraform + EC2 básico
- [x] Docker containerização
- [x] Deploy manual script

### **Fase 2 - CI/CD** ✅  
- [x] Jenkins pipeline
- [x] Automated testing
- [x] Health checks

### **Fase 3 - Production** 🔄
- [x] PowerShell automation
- [x] Professional deployment
- [ ] SSL/HTTPS setup
- [ ] Domain configuration

### **Fase 4 - Enterprise** 📋
- [ ] Kubernetes migration
- [ ] Multi-region setup
- [ ] Advanced monitoring
- [ ] Backup & disaster recovery

## 🤝 **CONTRIBUIÇÃO**

### **Como Contribuir**
1. Fork do repositório
2. Criar feature branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit das mudanças (`git commit -am 'Add: nova funcionalidade'`)
4. Push para branch (`git push origin feature/nova-funcionalidade`)
5. Criar Pull Request

### **Padrões de Código**
- Terraform: HCL formatting (`terraform fmt`)
- Scripts: ShellCheck validation
- PowerShell: PSScriptAnalyzer
- JavaScript: ESLint + Prettier

## 📞 **SUPORTE**

### **Documentação**
- 📖 [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- 🤖 [Jenkins Pipeline](https://jenkins.io/doc/book/pipeline/)
- 🐋 [Docker Compose](https://docs.docker.com/compose/)

### **Comunidade**
- 💬 Slack: `#devops-match3-game`
- 📧 Email: `devops-team@empresa.com`
- 📱 WhatsApp: Grupo DevOps

---

## 📜 **LICENÇA**

MIT License - Sinta-se livre para usar este projeto como referência para seus próprios projetos DevOps!

---

**🎉 Projeto criado com ❤️ pela equipe DevOps**

> "Automatize tudo que for repetitivo, monitore tudo que for crítico, documente tudo que for importante!"