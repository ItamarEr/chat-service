resource "aws_lambda_function" "worker" {
  function_name = "${var.project_name}-worker"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.12"
  timeout       = 20

  filename         = "${path.module}/../../worker/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../../worker/lambda.zip")

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.messages_table.name
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.messages_queue.arn
  function_name    = aws_lambda_function.worker.arn
  batch_size       = 1
}

