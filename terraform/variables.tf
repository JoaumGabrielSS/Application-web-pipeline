variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = can(regex("^(dev|staging|production)$", var.environment))
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "match3-game"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition     = can(regex("^[tm][2-9]\\.(nano|micro|small|medium|large|xlarge|2xlarge)$", var.instance_type))
    error_message = "Instance type must be a valid EC2 instance type (t3.micro, t3.small, etc.)."
  }
}

variable "key_name" {
  description = "AWS Key Pair name for SSH access"
  type        = string
  default     = "candy-crush-game-key"
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vpc_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "172.31.1.0/24"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "gamedb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "gameuser"
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "gamepass123"
  sensitive   = true
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 3000
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 3306
}

variable "web_port" {
  description = "Web server port"
  type        = number
  default     = 80
}

variable "ssl_port" {
  description = "SSL port"
  type        = number
  default     = 443
}

variable "project_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "Match3Game"
    Environment = "Development"
    Owner       = "DevOps-Team"
    ManagedBy   = "Terraform"
  }
}