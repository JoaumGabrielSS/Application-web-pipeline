# network-variables.tf
# Variáveis específicas para configuração de rede e segurança

variable "security_group_rules" {
  description = "Map of security group rules"
  type = map(object({
    description = string
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = {
    http = {
      description = "HTTP traffic"
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    https = {
      description = "HTTPS traffic"
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    api = {
      description = "API traffic"
      port        = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

variable "db_security_rules" {
  description = "Database security configuration"
  type = object({
    port                = number
    protocol            = string
    allow_internal_only = bool
  })
  default = {
    port                = 3306
    protocol            = "tcp"
    allow_internal_only = true
  }
}

variable "ssh_security" {
  description = "SSH security configuration"
  type = object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  })
  default = {
    port        = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}