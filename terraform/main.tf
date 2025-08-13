provider "aws" {
  region = var.aws_region
}

# Import your local public key into AWS so EC2 can use it
resource "aws_key_pair" "devops_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Find latest Ubuntu 22.04 AMI in your region
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Allow SSH (22) and HTTP (80)
resource "aws_security_group" "web_sg" {
  name        = "devops-web-sg"
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 and install Nginx via user_data
resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.devops_key.key_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx
    echo "Hello from DevOps pipeline" > /var/www/html/index.html
    systemctl restart nginx
  EOF

  tags = {
    Name = "devops-web"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}