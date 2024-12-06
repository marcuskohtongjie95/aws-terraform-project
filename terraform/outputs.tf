output "db_password" {
  value     = jsondecode(data.aws_secretsmanager_secret_version.db_password_version.secret_string)["db-password"]
  sensitive = true
}