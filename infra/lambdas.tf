# Se eliminan los recursos de layers ya que no se usan con contenedores

module "lambda_support_agent" {
  source      = "./modules/lambda_function"
  name        = var.properties_support_agent.name
  image_uri   = "${aws_ecr_repository.support_agent.repository_url}:latest"
  description = var.properties_support_agent.description
  role_arn    = aws_iam_role.lambda_support_role.arn
  api_arn     = aws_api_gateway_rest_api.tickets_api.execution_arn

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
