resource "aws_cloudwatch_log_group" "chat_api" {
  name              = "/ecs/chat-api"
  retention_in_days = 7
}
