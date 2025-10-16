output "instance_public_ip" {
  description = "Public IP address of the game server"
  value       = aws_instance.game_server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the game server"
  value       = aws_instance.game_server.public_dns
}

output "game_url" {
  description = "URL to access the game"
  value       = "http://${aws_instance.game_server.public_ip}"
}

output "web_security_group_id" {
  description = "Security group ID for the web server"
  value       = aws_security_group.web_sg.id
}

output "db_security_group_id" {
  description = "Security group ID for the database"
  value       = aws_security_group.db_sg.id
}

output "security_groups" {
  description = "All security group information"
  value = {
    web_sg = {
      id   = aws_security_group.web_sg.id
      name = aws_security_group.web_sg.name
    }
    db_sg = {
      id   = aws_security_group.db_sg.id
      name = aws_security_group.db_sg.name
    }
  }
}

output "server_ip" {
  description = "Server IP address"
  value       = aws_instance.game_server.public_ip
}

output "game_api_url" {
  description = "URL to access the game API"
  value       = "http://${aws_instance.game_server.public_ip}:3000"
}

output "mysql_url" {
  description = "URL to access MySQL (for development only)"
  value       = "mysql://${var.db_username}:${var.db_password}@${aws_instance.game_server.public_ip}:${var.db_port}/${var.db_name}"
  sensitive   = true
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.game_server.public_ip}"
}

output "private_key_path" {
  description = "Path to the private SSH key file"
  value       = "${path.module}/${var.key_name}.pem"
}

output "public_key" {
  description = "Public SSH key"
  value       = tls_private_key.game_key.public_key_openssh
}