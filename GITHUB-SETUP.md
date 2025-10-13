# Comandos para subir o código para o GitHub

## 1. Inicializar repositório Git
```bash
git init
```

## 2. Adicionar todos os arquivos
```bash
git add .
```

## 3. Commit inicial
```bash
git commit -m "Initial commit: Match-3 Game DevOps Pipeline with Terraform and Jenkins"
```

## 4. Criar repositório no GitHub
- Acesse GitHub.com
- Clique em "New Repository"
- Nome: `match3-game-devops`
- Descrição: `DevOps Pipeline for Match-3 Game with Terraform + Jenkins + Docker`
- Escolha Public ou Private
- NÃO inicializar com README (já temos)

## 5. Conectar com repositório remoto
```bash
git remote add origin https://github.com/SEU-USUARIO/match3-game-devops.git
```

## 6. Fazer push inicial
```bash
git branch -M main
git push -u origin main
```

## Comandos em sequência:
```bash
git init
git add .
git commit -m "Initial commit: Match-3 Game DevOps Pipeline"
git remote add origin https://github.com/SEU-USUARIO/NOME-REPOSITORIO.git
git branch -M main
git push -u origin main
```