
locals {
  ec2_tagging = {
    Name        = "myec2_demo_locals"
    Environment = "dev"
    Owner       = "HUL"
  }
}

locals {
  sg_tagging = {
    Name        = "sg_demo_locals"
    Environment = "dev"
    Owner       = "HUL"
  }
}

locals {
  ingress_info = {
    "80"   = "Apache Port"
    "443"  = "SSL Communication port"
    "5432" = "Application admin port"
    "1433" = "DB Port"
  }
}

locals {
  egress_info = {
    "80"   = "10.0.0.1/32"
    "443"  = "10.0.0.2/32"
    "5432" = "10.0.0.3/32"
    "1433" = "10.0.0.4/32"
    "0"    = "0.0.0.0/0"
  }
}

resource "aws_instance" "myec2" {
  ami                    = "ami-0d5eff06f840b45e9"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  key_name               = "dev"
  root_block_device {
    volume_size = 10
  }
  tags = local.ec2_tagging
}

resource "aws_security_group" "db_sg" {
  name        = "DB-sg"
  description = "Created for DB access"
  vpc_id      = "vpc-8a8f1bf7"

  dynamic "ingress" {
    for_each = local.ingress_info
    content {
      description = ingress.value
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = local.egress_info
    content {
      description = "Dynamic block Egress rules"
      from_port   = egress.key
      to_port     = egress.key
      protocol    = "all"
      cidr_blocks = [egress.value]
    }
  }
  tags = local.sg_tagging
}
