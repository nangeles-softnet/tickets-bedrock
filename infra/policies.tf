# Rol base para la ejecución de Lambda
resource "aws_iam_role" "lambda_support_role" {
  name = "lambda-support-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach política básica de ejecución (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_support_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach política VPC Access (requerida para EFS)
resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.lambda_support_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Política para DynamoDB, Bedrock y EFS
resource "aws_iam_policy" "support_agent_policy" {
  name        = "SupportAgentPolicy"
  description = "Permisos para DynamoDB, Bedrock invoke, y EFS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.tickets_history.arn
      },
      {
        Effect   = "Allow"
        Action   = [
          "bedrock:InvokeModel"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "support_agent_attach" {
  role       = aws_iam_role.lambda_support_role.name
  policy_arn = aws_iam_policy.support_agent_policy.arn
}
