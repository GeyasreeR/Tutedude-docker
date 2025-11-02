output "flask_backend_ecr_url" {
  value = aws_ecr_repository.flask_backend.repository_url
}

output "express_frontend_ecr_url" {
  value = aws_ecr_repository.express_frontend.repository_url
}
