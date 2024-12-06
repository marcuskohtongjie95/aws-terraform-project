data "aws_secretsmanager_secret" "db_password" {
  name = "db-password"
}

data "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}

resource "aws_db_subnet_group" "main" {
  name       = "aws-terraform-project-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "aws-terraform-project-db-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = module.vpc.vpc_id # Ensure this matches your VPC

  ingress {
    description     = "Allow MySQL traffic"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  tags = {
    Name = "rds-security-group"
  }
}



#RDS database
resource "aws_db_instance" "mysql" {
  #identifier         = "multi-tier-mysql"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "aws_terraform_project_db"
  username               = "admin"
  password               = jsondecode(data.aws_secretsmanager_secret_version.db_password_version.secret_string)["db-password"]
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = true
}