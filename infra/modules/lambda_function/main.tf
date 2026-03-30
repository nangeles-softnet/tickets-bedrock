resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "this" {
  function_name    = var.name
  filename         = var.filename
  description      = var.description
  handler          = var.handler
  role             = var.role_arn
  runtime          = "python3.11"
  timeout          = 30
  memory_size      = 1024
  architectures    = ["x86_64"]
  source_code_hash = filebase64sha256(var.filename)

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = var.envs
  }

  layers = var.layers

  dynamic "file_system_config" {
    for_each = var.efs_arn != "" ? [1] : []
    content {
      arn              = var.efs_arn
      local_mount_path = var.efs_mount_path
    }
  }

  dynamic "vpc_config" {
    for_each = length(var.subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  depends_on = [aws_cloudwatch_log_group.this]
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway-${var.name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_arn}/*/*"
}
