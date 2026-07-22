output "frontend_bucket" {
  value = aws_s3_bucket.frontend.bucket
}

output "frontend_website_url" {
  value = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "documents_bucket" {
  value = aws_s3_bucket.documents.bucket
}

output "ecs_cluster" {
  value = aws_ecs_cluster.main.name
}

output "alb_dns" {
  description = "URL public du back-end"
  value       = aws_lb.backend.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "dev_instance_id" {
  value = aws_instance.dev.id
}
