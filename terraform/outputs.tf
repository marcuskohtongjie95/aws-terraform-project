output "db_password" {
  value     = jsondecode(data.aws_secretsmanager_secret_version.db_password_version.secret_string)["db-password"]
  sensitive = true
}

output "ec2_instance_ids" {
  value = aws_instance.app[*].id
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

/*output "s3_bucket_name" {
  value = aws_s3_bucket.static.bucket
}*/