# Deploy-Pipeline.ps1
# Script PowerShell para pipeline DevOps
# Executa pipeline completo: Terraform + Deploy + Health Check

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("deploy", "destroy", "plan")]
    [string]$Action,
    
    [switch]$AutoApprove,
    [switch]$ForceRecreate,
    [string]$ProjectName = "match3-game",
    [string]$AWSRegion = "us-east-1"
)

# Configurações
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Cores para output
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    
    $colors = @{
        "Red" = "Red"
        "Green" = "Green"
        "Yellow" = "Yellow"
        "Blue" = "Blue"
        "Cyan" = "Cyan"
        "White" = "White"
    }
    
    Write-Host $Message -ForegroundColor $colors[$Color]
}

function Write-Success { param([string]$Message) Write-ColorOutput "[SUCCESS] $Message" "Green" }
function Write-Error { param([string]$Message) Write-ColorOutput "[ERROR] $Message" "Red" }
function Write-Warning { param([string]$Message) Write-ColorOutput "[WARNING] $Message" "Yellow" }
function Write-Info { param([string]$Message) Write-ColorOutput "[INFO] $Message" "Cyan" }

# Banner inicial
function Show-Banner {
    Write-ColorOutput @"

    ╔══════════════════════════════════════╗
    ║      🚀 JENKINS PIPELINE PRO 🚀       ║
    ║                                      ║
    ║    Match-3 Game DevOps Pipeline      ║
    ║         Terraform + Docker           ║
    ╚══════════════════════════════════════╝

"@ "Cyan"
}

# Verificar pré-requisitos
function Test-Prerequisites {
    Write-Info "Verificando pré-requisitos do sistema..."
    
    # Terraform
    try {
        $tfVersion = terraform version
        Write-Success "Terraform encontrado: $($tfVersion[0])"
    } catch {
        Write-Error "Terraform não encontrado! Instale: https://terraform.io/downloads"
        exit 1
    }
    
    # AWS CLI
    try {
        $awsVersion = aws --version
        Write-Success "AWS CLI encontrado: $awsVersion"
        
        # Testar credenciais
        $caller = aws sts get-caller-identity --output json | ConvertFrom-Json
        Write-Success "AWS Credenciais OK - Usuario: $($caller.Arn)"
    } catch {
        Write-Error "AWS CLI não configurado! Execute: aws configure"
        exit 1
    }
    
    # Docker (opcional, só para desenvolvimento local)
    try {
        $dockerVersion = docker --version
        Write-Success "Docker encontrado: $dockerVersion"
    } catch {
        Write-Warning "Docker não encontrado (opcional para CI/CD)"
    }
    
    # Verificar estrutura do projeto
    $requiredFiles = @(
        "terraform/main.tf",
        "terraform/variables.tf", 
        "scripts/deploy-application.sh",
        "game-app/docker-compose.yml"
    )
    
    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            Write-Success "Arquivo encontrado: $file"
        } else {
            Write-Error "Arquivo obrigatório não encontrado: $file"
            exit 1
        }
    }
}

# Executar Terraform
function Invoke-TerraformAction {
    param([string]$TfAction)
    
    Write-Info "Executando ação Terraform: $TfAction"
    
    try {
        Set-Location "terraform"
        
        # Inicializar sempre
        Write-Info "Inicializando Terraform..."
        terraform init -upgrade
        
        switch ($TfAction) {
            "plan" {
                Write-Info "Criando plano de execução..."
                terraform plan -var="project_name=$ProjectName" -out=tfplan
                terraform show -no-color tfplan | Out-File "plan-output.txt" -Encoding UTF8
                Write-Success "Plano salvo em: terraform/plan-output.txt"
            }
            
            "deploy" {
                # Plan primeiro
                Write-Info "Criando plano antes do deploy..."
                terraform plan -var="project_name=$ProjectName" -out=tfplan
                
                # Confirmar se não for auto-aprovado
                if (-not $AutoApprove) {
                    Write-Warning "ATENÇÃO: Isso irá criar recursos AWS (pode gerar custos)"
                    $confirm = Read-Host "Digite 'yes' para continuar"
                    if ($confirm -ne "yes") {
                        Write-Error "Deploy cancelado pelo usuário"
                        exit 1
                    }
                }
                
                # Aplicar
                Write-Info "Aplicando infraestrutura..."
                terraform apply -auto-approve tfplan
                
                # Capturar outputs
                $serverIp = terraform output -raw server_ip
                $serverIp | Out-File "../server_ip.txt" -NoNewline -Encoding ASCII
                
                Write-Success "Infraestrutura criada! IP: $serverIp"
                return $serverIp
            }
            
            "destroy" {
                if (-not $AutoApprove) {
                    Write-Warning "ATENÇÃO: Isso irá DESTRUIR toda a infraestrutura!"
                    $confirm = Read-Host "Digite 'DESTROY' para confirmar"
                    if ($confirm -ne "DESTROY") {
                        Write-Error "Destruição cancelada"
                        exit 1
                    }
                }
                
                Write-Info "Destruindo infraestrutura..."
                terraform destroy -auto-approve -var="project_name=$ProjectName"
                Write-Success "Infraestrutura destruída com sucesso!"
            }
        }
    } catch {
        Write-Error "Erro no Terraform: $($_.Exception.Message)"
        exit 1
    } finally {
        Set-Location ".."
    }
}

# Deploy da aplicação
function Invoke-ApplicationDeploy {
    param([string]$ServerIP)
    
    Write-Info "Iniciando deploy da aplicação para: $ServerIP"
    
    try {
        # Aguardar instância ficar acessível
        Write-Info "Aguardando instância ficar acessível..."
        $maxAttempts = 20
        $attempt = 1
        
        do {
            Write-Info "Tentativa $attempt/$maxAttempts - testando SSH..."
            
            # Usar WSL para comandos SSH (Windows + WSL)
            $sshTest = wsl ssh -i terraform/candy-crush-game-key.pem -o ConnectTimeout=10 -o StrictHostKeyChecking=no ec2-user@$ServerIP 'echo "SSH_OK"' 2>$null
            
            if ($sshTest -eq "SSH_OK") {
                Write-Success "SSH acessível!"
                break
            }
            
            Start-Sleep 30
            $attempt++
        } while ($attempt -le $maxAttempts)
        
        if ($attempt -gt $maxAttempts) {
            Write-Error "Timeout: não foi possível conectar via SSH"
            exit 1
        }
        
        # Executar script de deploy
        Write-Info "Executando deploy da aplicação..."
        
        # Tornar executável e executar via WSL
        wsl chmod +x scripts/deploy-application.sh
        $deployResult = wsl ./scripts/deploy-application.sh $ServerIP terraform/candy-crush-game-key.pem game-app
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Aplicação deployada com sucesso!"
        } else {
            Write-Error "Falha no deploy da aplicação"
            exit 1
        }
        
    } catch {
        Write-Error "Erro no deploy: $($_.Exception.Message)"
        exit 1
    }
}

# Health Check
function Test-ApplicationHealth {
    param([string]$ServerIP)
    
    Write-Info "Executando health check da aplicação..."
    
    try {
        # Testar web app
        Write-Info "Testando aplicação web..."
        $maxAttempts = 15
        $webOk = $false
        
        for ($i = 1; $i -le $maxAttempts; $i++) {
            try {
                $response = Invoke-WebRequest -Uri "http://$ServerIP" -TimeoutSec 10 -UseBasicParsing
                if ($response.StatusCode -eq 200) {
                    Write-Success "Aplicação web respondendo (HTTP 200)"
                    $webOk = $true
                    break
                }
            } catch {
                Write-Info "Tentativa $i/$maxAttempts - aguardando aplicação..."
                Start-Sleep 20
            }
        }
        
        # Testar API
        Write-Info "Testando API backend..."
        try {
            $apiResponse = Invoke-WebRequest -Uri "http://$ServerIP`:3000/health" -TimeoutSec 10 -UseBasicParsing
            if ($apiResponse.StatusCode -eq 200) {
                Write-Success "API backend funcionando (HTTP 200)"
            }
        } catch {
            Write-Warning "API backend não respondeu (pode estar inicializando)"
        }
        
        # Status do sistema
        Write-Info "Verificando status do sistema..."
        $systemStatus = wsl ssh -i terraform/candy-crush-game-key.pem -o StrictHostKeyChecking=no ec2-user@$ServerIP 'cd /opt/game-app && docker-compose ps && echo "=== RESOURCES ===" && df -h / && free -h'
        Write-Info "Status do sistema:`n$systemStatus"
        
        if ($webOk) {
            Write-Success "Health check concluído com sucesso!"
            return $true
        } else {
            Write-Warning "Aplicação pode não estar totalmente funcional"
            return $false
        }
        
    } catch {
        Write-Error "Erro no health check: $($_.Exception.Message)"
        return $false
    }
}

# Função principal
function Main {
    Show-Banner
    
    Write-Info "Iniciando pipeline: $Action"
    Write-Info "Projeto: $ProjectName"
    Write-Info "Região AWS: $AWSRegion"
    Write-Info "Auto-Approve: $AutoApprove"
    
    # Verificar pré-requisitos
    Test-Prerequisites
    
    # Executar ação principal
    switch ($Action) {
        "plan" {
            Invoke-TerraformAction -TfAction "plan"
            Write-Success "Planejamento concluído! Revise o arquivo: terraform/plan-output.txt"
        }
        
        "deploy" {
            # 1. Deploy da infraestrutura
            $serverIp = Invoke-TerraformAction -TfAction "deploy"
            
            # 2. Deploy da aplicação
            Invoke-ApplicationDeploy -ServerIP $serverIp
            
            # 3. Health check
            $healthOk = Test-ApplicationHealth -ServerIP $serverIp
            
            # 4. Resumo final
            Write-ColorOutput @"

╔══════════════════════════════════════════════════════════════╗
║                   🎉 DEPLOY CONCLUÍDO! 🎉                     ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  🎮 MATCH-3 GAME FUNCIONANDO:                                ║
║  ┌────────────────────────────────────────────────────────┐  ║
║  │ 🌐 Web App: http://$serverIp                    │  ║
║  │ 🔧 API:     http://$serverIp`:3000                │  ║
║  │ 🏥 Health:  http://$serverIp`:3000/health         │  ║
║  └────────────────────────────────────────────────────────┘  ║
║                                                              ║
║  🔐 SSH: ssh -i candy-crush-game-key.pem ec2-user@$serverIp   ║
║                                                              ║
║  🚀 PRÓXIMOS PASSOS:                                         ║
║  • Teste o jogo completo                                    ║
║  • Configure domínio personalizado                          ║
║  • Adicione HTTPS com SSL                                   ║
║  • Configure monitoramento                                  ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

"@ "Green"
        }
        
        "destroy" {
            Invoke-TerraformAction -TfAction "destroy"
            
            # Limpeza
            if (Test-Path "server_ip.txt") { Remove-Item "server_ip.txt" }
            
            Write-Success "Infraestrutura destruída e arquivos limpos!"
        }
    }
    
    Write-Success "Pipeline '$Action' concluído com sucesso!"
}

# Executar pipeline
try {
    Main
} catch {
    Write-Error "Erro crítico no pipeline: $($_.Exception.Message)"
    Write-Error "Stack trace: $($_.ScriptStackTrace)"
    exit 1
}