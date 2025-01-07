terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "aws_security_group" "JigneshSG" {
  name        = "JigneshSG"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Linux instances
resource "aws_instance" "linux_servers" {
  count           = length(var.linux_ami_configs)
  ami             = var.linux_ami_configs[count.index].ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.JigneshSG.name]
  user_data = templatefile("${path.module}/user_data/${var.linux_ami_configs[count.index].user_data_script}", {
    server_name = var.linux_ami_configs[count.index].name
    domain_name = var.domain_name
  })

  tags = {
    Name = "LinuxServer-${var.linux_ami_configs[count.index].name}"
  }
}

resource "cloudflare_record" "linux_dns_records" {
  count   = length(var.linux_ami_configs)
  zone_id = var.cloudflare_zone_id
  name    = "${var.linux_ami_configs[count.index].name}.${var.domain_name}"
  type    = "A"
  content   = aws_instance.linux_servers[count.index].public_ip
  ttl     = 3600
}

# Windows instances
# resource "aws_instance" "windows_servers" {
#   count           = length(var.windows_ami_configs)
#   ami             = var.windows_ami_configs[count.index].ami_id
#   instance_type   = var.windows_instance_type
#   key_name        = var.key_name
#   security_groups = [aws_security_group.JigneshSG.name]
#   user_data = templatefile("${path.module}/user_data/windows.ps1", {
#     server_name = var.windows_ami_configs[count.index].name
#     domain_name = var.domain_name
#   })

#   tags = {
#     Name = "WindowsServer-${var.windows_ami_configs[count.index].name}"
#   }
# }

# resource "cloudflare_record" "windows_dns_records" {
#   count   = length(var.windows_ami_configs)
#   zone_id = var.cloudflare_zone_id
#   name    = "${var.windows_ami_configs[count.index].name}.${var.domain_name}"
#   type    = "A"
#   content   = aws_instance.windows_servers[count.index].public_ip
#   ttl     = 3600
# }

output "linux_server_ips" {
  value = aws_instance.linux_servers[*].public_ip
}

# output "windows_server_ips" {
#   value = aws_instance.windows_servers[*].public_ip
# }
