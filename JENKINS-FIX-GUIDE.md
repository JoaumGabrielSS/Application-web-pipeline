# 🔧 GUIA DE CORREÇÃO - PIPELINE JENKINS

## 📋 Problemas Identificados e Soluções

### ✅ CORRIGIDO: Arquivos Ausentes
- ✅ **scripts/setup.sh**: Criado com setup completo do ambiente
- ✅ **Jenkinsfile**: Melhorado com verificação de arquivos e tratamento de erros
- ✅ **Push para GitHub**: Alterações sincronizadas

### 🔧 PRÓXIMOS PASSOS OBRIGATÓRIOS

#### 1. **Configurar Credenciais AWS no Jenkins**
```bash
# No Jenkins, vá para: Manage Jenkins > Credentials > Global
# Adicione nova credencial tipo "AWS Credentials" com:
# - ID: aws-credentials
# - Access Key ID: <sua_access_key>
# - Secret Access Key: <sua_secret_key>
```

#### 2. **Configurar Plugin AWS no Jenkins**
```bash
# Instalar plugins necessários:
# - AWS Steps Plugin
# - Pipeline: AWS Steps
# - Terraform Plugin
```

#### 3. **Atualizar Jenkinsfile com Credenciais**
O Jenkinsfile precisa ser atualizado para usar as credenciais AWS:

```groovy
environment {
    AWS_DEFAULT_REGION = 'us-east-1'
    AWS_CREDENTIALS = credentials('aws-credentials')  // <- ADICIONAR
}
```

#### 4. **Criar Chave SSH no Terraform**
O terraform criará a chave automaticamente, mas você pode criar manualmente:

```bash
# No diretório terraform/
aws ec2 create-key-pair --key-name candy-crush-game-key \
  --output text --query 'KeyMaterial' > candy-crush-game-key.pem
chmod 600 candy-crush-game-key.pem
```

## 🚀 COMANDOS PARA EXECUÇÃO MANUAL (Se Jenkins falhar)

### Teste Local da Pipeline
```bash
# 1. Setup do ambiente
./scripts/setup.sh

# 2. Inicializar Terraform
cd terraform
terraform init
terraform plan
terraform apply

# 3. Deploy da aplicação
../scripts/deploy-application.sh
```

### Verificação de Saúde
```bash
# Verificar instância criada
terraform output instance_public_ip

# Testar conexão SSH
ssh -i candy-crush-game-key.pem ubuntu@$(terraform output -raw instance_public_ip)

# Testar aplicação
curl http://$(terraform output -raw instance_public_ip)
```

## 🔍 DIAGNÓSTICO DE PROBLEMAS

### Jenkins Pipeline Falha
1. **Credenciais AWS**: Verifique se estão configuradas no Jenkins
2. **Plugins**: Confirme instalação dos plugins AWS e Terraform  
3. **Permissões**: Jenkins precisa acessar Docker e executar scripts
4. **Região AWS**: Confirme que us-east-1 está disponível

### Terraform Falha
1. **Limites AWS**: Verifique limites da conta (EC2, VPC, etc.)
2. **Credenciais**: Execute `aws sts get-caller-identity` no Jenkins
3. **Recursos existentes**: Conflitos de nomes ou security groups
4. **Região**: Confirme disponibilidade de AZ's em us-east-1

### Aplicação Falha
1. **Porta 80**: Verificar se não está em uso na instância
2. **Docker**: Confirmar instalação do Docker na instância
3. **Security Groups**: Portas 80 e 22 abertas
4. **Logs**: Verificar logs do Docker Compose

## 📞 COMANDOS DE EMERGÊNCIA

```bash
# Destruir toda infraestrutura
terraform destroy -auto-approve

# Limpar estado do Terraform
rm -rf .terraform
rm terraform.tfstate*
terraform init

# Restart completo do Jenkins job
# Vá para o job > Build Now
```

## 🎯 RESULTADO ESPERADO

Quando tudo estiver funcionando, você verá:
- ✅ Pipeline verde no Jenkins
- ✅ Instância EC2 criada e rodando
- ✅ Aplicação Match-3 acessível via browser
- ✅ Monitoramento e logs funcionando

## 📋 CHECKLIST DE VERIFICAÇÃO

- [ ] Credenciais AWS configuradas no Jenkins
- [ ] Plugins AWS instalados no Jenkins  
- [ ] Jenkinsfile atualizado com credenciais
- [ ] Setup.sh executado com sucesso
- [ ] Terraform.tfvars configurado
- [ ] Região AWS confirmada (us-east-1)
- [ ] Security groups não conflitantes
- [ ] Limites AWS verificados