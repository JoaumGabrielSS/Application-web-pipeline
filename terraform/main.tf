data "aws_vpc" "default" {
  default = true
}

resource "aws_subnet" "game_subnet" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = var.vpc_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(var.project_tags, {
    Name = "${var.project_name}-subnet"
  })
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_route_table" "game_rt" {
  vpc_id = data.aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.default.id
  }

  tags = merge(var.project_tags, {
    Name = "${var.project_name}-rt"
  })
}

resource "aws_route_table_association" "game_rta" {
  subnet_id      = aws_subnet.game_subnet.id
  route_table_id = aws_route_table.game_rt.id
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create a new private key for Jenkins to use
resource "tls_private_key" "game_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the new private key to Jenkins workspace
resource "local_file" "private_key" {
  content         = tls_private_key.game_key.private_key_pem
  filename        = "${path.module}/${var.key_name}.pem"
  file_permission = "0600"
}

# Create AWS key pair - will replace existing one
resource "aws_key_pair" "game_key" {
  key_name   = var.key_name
  public_key = tls_private_key.game_key.public_key_openssh

  tags = merge(var.project_tags, {
    Name = "${var.project_name}-key-pair"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "game_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  subnet_id                   = aws_subnet.game_subnet.id
  associate_public_ip_address = true

  user_data = base64encode(file("${path.module}/user_data_production.sh"))

  monitoring = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  tags = merge(var.project_tags, {
    Name = "${var.project_name}-game-server"
    Type = "GameServer"
  })

  # Force recreation when key pair is updated
  lifecycle {
    create_before_destroy = true
    replace_triggered_by  = [aws_key_pair.game_key]
  }

  depends_on = [aws_key_pair.game_key]
}