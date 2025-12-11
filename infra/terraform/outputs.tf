output "aws_region" {
  value = var.aws_region
}

output "project_name" {
  value = var.project_name
}

output "sqs_url" {
  value = aws_sqs_queue.messages_queue.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.messages_table.name
}

output "ecr_repo_url" {
  value = aws_ecr_repository.chat_api.repository_url
}

output "alb_dns_name" {
  value = aws_lb.chat_api.dns_name
}
