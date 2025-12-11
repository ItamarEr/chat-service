resource "aws_sqs_queue" "messages_queue" {
  name                      = "${var.project_name}-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400 # 1 day
}
