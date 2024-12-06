provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "aws-terraform-project-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    project = "aws-terraform-project"
  }
}

data "aws_key_pair" "existing" {
  key_name = "jenkins-updated-keypair" # Replace with the name of your existing key pair
}

# EC2 Instances
resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Allow traffic for app servers"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id] # Allow SSH from Bastion Host
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-security-group"
  }
}


resource "aws_instance" "app" {
  count                  = 1
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = element(module.vpc.private_subnets, count.index)
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = data.aws_key_pair.existing.key_name

  tags = {
    Name = "AppServer-${count.index + 1}"
  }
}
