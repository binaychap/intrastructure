resource "aws_sqs_queue" "this" {
  name = "serverless-sqs-queue"
}

output "queue_url" {
  value = aws_sqs_queue.this.id
}
