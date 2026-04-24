resource "aws_lambda_function" "this" {
  function_name = "producer-lambda"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = var.lambda_role_arn
  filename      = var.lambda_zip
  environment {
    variables = var.environment_variables
  }
}

resource "aws_lambda_permission" "alb_invoke" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = var.alb_arn
}

output "lambda_arn" {
  value = aws_lambda_function.this.arn
}
