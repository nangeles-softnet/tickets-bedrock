resource "aws_lambda_layer_version" "support_agent_layer" {
  filename            = var.support_layer_filename
  layer_name          = "support-agent-dependencies"
  compatible_runtimes = ["python3.11"]
  source_code_hash    = filebase64sha256(var.support_layer_filename)
}

locals {
  support_agent_filename = fileexists(var.properties_support_agent.filename) ? var.properties_support_agent.filename : (
    fileexists("support-agent.zip") ? "support-agent.zip" : "support_agent.zip"
  )
}

module "lambda_support_agent" {
  source      = "./modules/lambda_function"
  name        = var.properties_support_agent.name
  filename    = local.support_agent_filename
  description = var.properties_support_agent.description
  handler     = var.properties_support_agent.handler
  role_arn    = aws_iam_role.lambda_support_role.arn
  api_arn     = aws_api_gateway_rest_api.tickets_api.execution_arn

  # Capa de dependencias
  layers = [aws_lambda_layer_version.support_agent_layer.arn]

  # Mapeo de EFS opcional (solo si se provee)
  efs_arn            = var.efs_arn
  efs_mount_path     = var.efs_mount_path
  subnet_ids         = var.vpc_subnet_ids
  security_group_ids = var.vpc_security_group_ids

  # INYECCIÓN CERO HARDCODING
  envs = {
    MODEL_ID       = var.model_id
    AWS_REGION     = var.region
    DYNAMODB_TABLE = aws_dynamodb_table.tickets_history.name
    EFS_MOUNT_PATH = var.efs_mount_path
    COHERE_API_KEY = var.cohere_api_key
  }
}
