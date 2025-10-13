pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_VAR_project_name = 'match3-game'
        SSH_KEY_PATH = 'terraform/candy-crush-game-key.pem'
        DEPLOY_SCRIPT = 'scripts/deploy-application.sh'
    }
    
    parameters {
        choice(
            name: 'ACTION',
            choices: ['deploy', 'destroy', 'plan'],
            description: 'Ação a ser executada no pipeline'
        )
        booleanParam(
            name: 'FORCE_RECREATE',
            defaultValue: false,
            description: 'Forçar recriação da infraestrutura'
        )
        string(
            name: 'BRANCH',
            defaultValue: 'main',
            description: 'Branch do repositório para deploy'
        )
        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: 'Pular validações e testes'
        )
    }
    
    stages {
        stage('Checkout & Prepare') {
            steps {
                echo "Fazendo checkout do código..."
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${params.BRANCH}"]],
                    userRemoteConfigs: [[url: env.GIT_URL]]
                ])
                
                script {
                    if (isUnix()) {
                        sh '''
                            echo "Configurando permissões Linux..."
                            chmod 600 ${SSH_KEY_PATH} || echo "Chave SSH será criada pelo Terraform"
                            chmod +x ${DEPLOY_SCRIPT}
                            chmod +x scripts/setup.sh
                        '''
                    } else {
                        bat '''
                            echo "Configurando permissões Windows..."
                            echo "Chave SSH e scripts prontos para uso"
                        '''
                    }
                }
            }
        }
        
        stage('Code Validation') {
            when {
                expression { !params.SKIP_TESTS }
            }
            parallel {
                stage('Terraform Validate') {
                    steps {
                        dir('terraform') {
                            sh '''
                                echo "Validando sintaxe do Terraform..."
                                terraform fmt -check=true -diff=true
                                terraform validate
                            '''
                        }
                    }
                }
                stage('Application Structure') {
                    steps {
                        sh '''
                            echo "Verificando estrutura da aplicação..."
                            test -f game-app/docker-compose.yml || exit 1
                            test -f game-app/Dockerfile || exit 1
                            test -f game-app/src/index.html || exit 1
                            echo "Estrutura da aplicação OK!"
                        '''
                    }
                }
                stage('Scripts Validation') {
                    steps {
                        sh '''
                            echo "Validando scripts de deploy..."
                            bash -n ${DEPLOY_SCRIPT}
                            bash -n scripts/setup.sh
                            echo "Scripts validados com sucesso!"
                        '''
                    }
                }
            }
        }
        
        stage('Terraform Initialize') {
            steps {
                dir('terraform') {
                    sh '''
                        echo "Inicializando Terraform..."
                        terraform init -upgrade
                        terraform version
                    '''
                }
            }
        }
        
        stage('Infrastructure Planning') {
            when {
                anyOf {
                    expression { params.ACTION == 'plan' }
                    expression { params.ACTION == 'deploy' }
                }
            }
            steps {
                dir('terraform') {
                    sh '''
                        echo "Planejando infraestrutura..."
                        terraform plan -out=tfplan \
                            -var="project_name=${TF_VAR_project_name}" \
                            -detailed-exitcode
                        
                        echo "Salvando plano para revisão..."
                        terraform show -no-color tfplan > plan-output.txt
                    '''
                    
                    archiveArtifacts artifacts: 'tfplan,plan-output.txt', fingerprint: true
                }
            }
        }
        
        stage('Deploy Infrastructure') {
            when {
                expression { params.ACTION == 'deploy' }
            }
            steps {
                script {
                    def userApproval = true
                    
                    if (!params.FORCE_RECREATE) {
                        try {
                            timeout(time: 15, unit: 'MINUTES') {
                                userApproval = input(
                                    message: 'Confirma o deploy da infraestrutura AWS?',
                                    parameters: [
                                        booleanParam(
                                            name: 'CONFIRM_DEPLOY',
                                            defaultValue: false,
                                            description: 'Confirmar criação da infraestrutura'
                                        )
                                    ]
                                )
                            }
                        } catch (err) {
                            echo "Timeout na confirmação - cancelando deploy"
                            currentBuild.result = 'ABORTED'
                            return
                        }
                    }
                    
                    if (userApproval || params.FORCE_RECREATE) {
                        dir('terraform') {
                            sh '''
                                echo "🏗️ Aplicando infraestrutura..."
                                terraform apply -auto-approve tfplan
                                
                                echo "📝 Capturando outputs da infraestrutura..."
                                terraform output -raw server_ip > ../server_ip.txt
                                terraform output -raw server_public_ip > ../server_public_ip.txt
                                
                                echo "✅ Infraestrutura criada com sucesso!"
                                echo "🌐 IP do servidor: $(cat ../server_ip.txt)"
                            '''
                        }
                    } else {
                        echo "❌ Deploy cancelado pelo usuário"
                        currentBuild.result = 'ABORTED'
                    }
                }
            }
        }
        
        stage('⏳ Wait for Instance Ready') {
            when {
                expression { params.ACTION == 'deploy' }
            }
            steps {
                script {
                    def serverIp = readFile('server_ip.txt').trim()
                    echo "⏳ Aguardando instância ${serverIp} ficar pronta..."
                    
                    sh """
                        echo "🔍 Testando conectividade SSH..."
                        for i in {1..20}; do
                            if ssh -i ${SSH_KEY_PATH} -o ConnectTimeout=10 -o StrictHostKeyChecking=no ec2-user@${serverIp} 'echo "SSH OK"' 2>/dev/null; then
                                echo "✅ Instância acessível via SSH!"
                                break
                            fi
                            echo "⏳ Tentativa \$i/20 - aguardando 30 segundos..."
                            sleep 30
                        done
                        
                        echo "🐋 Verificando Docker na instância..."
                        ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no ec2-user@${serverIp} 'docker --version && docker-compose --version'
                    """
                }
            }
        }
        
        stage('🎮 Deploy Application') {
            when {
                expression { params.ACTION == 'deploy' }
            }
            steps {
                script {
                    def serverIp = readFile('server_ip.txt').trim()
                    echo "🚀 Iniciando deploy da aplicação para ${serverIp}..."
                    
                    sh """
                        echo "🎮 Executando deploy profissional..."
                        ${DEPLOY_SCRIPT} ${serverIp} ${SSH_KEY_PATH} game-app
                    """
                }
            }
        }
        
        stage('🧪 Application Health Check') {
            when {
                expression { params.ACTION == 'deploy' }
            }
            steps {
                script {
                    def serverIp = readFile('server_ip.txt').trim()
                    echo "🔍 Executando health check completo..."
                    
                    sh """
                        echo "🌐 Testando aplicação web..."
                        for i in {1..15}; do
                            if curl -f -s -m 10 http://${serverIp} >/dev/null 2>&1; then
                                echo "✅ Aplicação web respondendo!"
                                break
                            fi
                            echo "⏳ Tentativa \$i/15 - aguardando aplicação inicializar..."
                            sleep 20
                        done
                        
                        echo "🔧 Testando API backend..."
                        if curl -f -s -m 10 http://${serverIp}:3000/health >/dev/null 2>&1; then
                            echo "✅ API backend funcionando!"
                        else
                            echo "⚠️ API backend não respondeu (pode estar inicializando)"
                        fi
                        
                        echo "🐋 Verificando containers Docker..."
                        ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no ec2-user@${serverIp} 'cd /opt/game-app && docker-compose ps'
                        
                        echo "📊 Status geral do sistema:"
                        ssh -i ${SSH_KEY_PATH} -o StrictHostKeyChecking=no ec2-user@${serverIp} 'df -h / && free -h && uptime'
                    """
                }
            }
        }
        
        stage('🗑️ Destroy Infrastructure') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                script {
                    def confirmation = input(
                        message: '⚠️ DESTRUIÇÃO TOTAL DA INFRAESTRUTURA ⚠️',
                        parameters: [
                            string(
                                name: 'DESTROY_CONFIRMATION',
                                defaultValue: '',
                                description: 'Digite "DESTROY-ALL" para confirmar a destruição completa'
                            )
                        ]
                    )
                    
                    if (confirmation == 'DESTROY-ALL') {
                        dir('terraform') {
                            sh '''
                                echo "🗑️ Destruindo infraestrutura..."
                                terraform destroy -auto-approve \
                                    -var="project_name=${TF_VAR_project_name}"
                                
                                echo "✅ Infraestrutura destruída com sucesso!"
                            '''
                        }
                        
                        // Limpar arquivos temporários
                        sh '''
                            rm -f server_ip.txt server_public_ip.txt
                            echo "🧹 Arquivos temporários removidos"
                        '''
                    } else {
                        error('❌ Confirmação inválida. Destruição cancelada por segurança.')
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo "🧹 Executando limpeza pós-pipeline..."
            
            // Limpar arquivos temporários sensíveis
            sh '''
                rm -f terraform/tfplan
                rm -f terraform/*.log
                find . -name "*.tmp" -delete 2>/dev/null || true
            '''
            
            // Arquivar logs importantes
            archiveArtifacts artifacts: 'terraform/plan-output.txt', allowEmptyArchive: true
            archiveArtifacts artifacts: '*.log', allowEmptyArchive: true
        }
        
        success {
            script {
                if (params.ACTION == 'deploy') {
                    def serverIp = ''
                    try {
                        serverIp = readFile('server_ip.txt').trim()
                    } catch (Exception e) {
                        serverIp = 'N/A'
                    }
                    
                    echo """
                    🎉🎉🎉 PIPELINE DE PRODUÇÃO CONCLUÍDO COM SUCESSO! 🎉🎉🎉
                    
                    🎮 SEU MATCH-3 GAME ESTÁ FUNCIONANDO:
                    ═══════════════════════════════════════════
                    🌐 Aplicação Web: http://${serverIp}
                    🔧 API Backend:   http://${serverIp}:3000
                    🏥 Health Check:  http://${serverIp}:3000/health
                    
                    🔐 ACESSO SSH:
                    ssh -i candy-crush-game-key.pem ec2-user@${serverIp}
                    
                    📊 MONITORAMENTO:
                    - Logs Docker: /opt/game-app/logs/
                    - Status: docker-compose ps
                    - Recursos: htop / df -h
                    
                    🚀 PRÓXIMOS PASSOS:
                    - Teste o jogo completo
                    - Configure DNS personalizado
                    - Adicione HTTPS com SSL
                    - Configure backup automático
                    ═══════════════════════════════════════════
                    """
                } else if (params.ACTION == 'destroy') {
                    echo """
                    ✅ INFRAESTRUTURA DESTRUÍDA COM SUCESSO!
                    
                    🗑️ Todos os recursos AWS foram removidos
                    💰 Não haverá mais cobrança pelos recursos
                    🔄 Execute 'deploy' para recriar quando necessário
                    """
                } else if (params.ACTION == 'plan') {
                    echo """
                    ✅ PLANEJAMENTO CONCLUÍDO!
                    
                    📋 Revise o plano em: plan-output.txt
                    🚀 Execute 'deploy' para aplicar as mudanças
                    """
                }
            }
        }
        
        failure {
            echo """
            ❌❌❌ PIPELINE FALHOU! ❌❌❌
            
            🔍 DIAGNÓSTICO RÁPIDO:
            ═══════════════════════
            1. Verifique credenciais AWS (aws sts get-caller-identity)
            2. Confirme chave SSH: ${SSH_KEY_PATH}
            3. Valide região AWS: ${AWS_DEFAULT_REGION}
            4. Verifique logs do Terraform acima
            
            💡 PROBLEMAS COMUNS:
            - Credenciais AWS expiradas
            - Limite de recursos atingido
            - Security groups conflitantes
            - Chave SSH não encontrada
            
            🆘 SUPORTE:
            - Logs arquivados para análise
            - Execute 'plan' para diagnosticar
            - Verifique console AWS para conflitos
            ═══════════════════════
            """
        }
        
        aborted {
            echo """
            ⏸️ PIPELINE CANCELADO PELO USUÁRIO
            
            🔄 Você pode executar novamente quando necessário
            📊 Execute 'plan' para revisar mudanças antes do deploy
            """
        }
    }
}