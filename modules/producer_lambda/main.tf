resource "aws_lambda_function" "this" {
  function_name = "producer-lambda"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = var.lambda_role_arn
  filename      = var.lambda_zip
  source_code_hash = filebase64sha256(var.lambda_zip)
  environment {
    variables = var.environment_variables
  }
}

output "lambda_arn" {
  value = aws_lambda_function.this.arn
}
