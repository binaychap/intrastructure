variable "lambda_role_arn" {
  type = string
}

variable "lambda_zip" {
  type = string
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}
