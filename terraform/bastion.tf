resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH from anywhere"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (or your IP)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Bastion Host EC2 Instance in Public Subnet
resource "aws_instance" "bastion" {
  ami                         = var.ami_id # Specify your preferred AMI ID
  instance_type               = "t2.micro"
  subnet_id                   = element(module.vpc.public_subnets, 0) # Public subnet
  key_name                    = data.aws_key_pair.existing.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true # Ensure public IP is assigned

  tags = {
    Name = "BastionHost"
  }
}