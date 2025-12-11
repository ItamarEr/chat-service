resource "aws_dynamodb_table" "messages_table" {
  name         = "${var.project_name}-messages"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
