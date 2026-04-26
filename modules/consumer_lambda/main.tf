
resource "aws_lambda_function" "this" {
  function_name = "consumer-lambda"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = var.lambda_role_arn
  filename      = var.lambda_zip
  source_code_hash = filebase64sha256(var.lambda_zip)
  environment {
    variables = var.environment_variables
  }
}

resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = var.sqs_arn
  function_name    = aws_lambda_function.this.arn
  batch_size       = 10
  enabled          = true
}

output "lambda_arn" {
  value = aws_lambda_function.this.arn
}
