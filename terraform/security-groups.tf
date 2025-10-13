# security-groups.tf
# Security Groups organizados e reutilizáveis

locals {
  common_ports = {
    http    = 80
    https   = 443
    ssh     = 22
    mysql   = 3306
    api     = 3000
  }
  
  common_protocols = {
    tcp = "tcp"
    udp = "udp"
    all = "-1"
  }
}

# Security Group para Aplicação Web
resource "aws_security_group" "web_sg" {
  name_prefix = "${var.project_name}-web-"
  description = "Security group for web application"
  vpc_id      = data.aws_vpc.default.id

  tags = merge(var.project_tags, {
    Name = "${var.project_name}-web-sg"
    Type = "WebApplication"
  })
}

# Security Group para Database
resource "aws_security_group" "db_sg" {
  name_prefix = "${var.project_name}-db-"
  description = "Security group for database"
  vpc_id      = data.aws_vpc.default.id

  tags = merge(var.project_tags, {
    Name = "${var.project_name}-db-sg"
    Type = "Database"
  })
}

# Regras de Ingress - Web Security Group
resource "aws_security_group_rule" "web_http_ingress" {
  type              = "ingress"
  description       = "HTTP"
  from_port         = local.common_ports.http
  to_port           = local.common_ports.http
  protocol          = local.common_protocols.tcp
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "web_https_ingress" {
  type              = "ingress"
  description       = "HTTPS"
  from_port         = local.common_ports.https
  to_port           = local.common_ports.https
  protocol          = local.common_protocols.tcp
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "web_ssh_ingress" {
  type              = "ingress"
  description       = "SSH"
  from_port         = local.common_ports.ssh
  to_port           = local.common_ports.ssh
  protocol          = local.common_protocols.tcp
  cidr_blocks       = var.allowed_ssh_cidr
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "web_api_ingress" {
  type              = "ingress"
  description       = "Game API"
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = local.common_protocols.tcp
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

# Regra MySQL para acesso interno (container para container)
resource "aws_security_group_rule" "web_mysql_ingress" {
  type              = "ingress"
  description       = "MySQL for containers"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = local.common_protocols.tcp
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.web_sg.id
}

# Regras de Egress - Web Security Group
resource "aws_security_group_rule" "web_all_egress" {
  type              = "egress"
  description       = "All outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = local.common_protocols.all
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

# Regras Database Security Group
resource "aws_security_group_rule" "db_mysql_ingress" {
  type                     = "ingress"
  description              = "MySQL from web servers"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = local.common_protocols.tcp
  source_security_group_id = aws_security_group.web_sg.id
  security_group_id        = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "db_all_egress" {
  type              = "egress"
  description       = "All outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = local.common_protocols.all
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db_sg.id
}