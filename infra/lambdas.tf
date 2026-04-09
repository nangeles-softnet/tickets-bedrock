# Subir el ZIP optimizado del Layer a S3 primero
resource "aws_s3_object" "support_layer_s3" {
  bucket = aws_s3_bucket.artifacts.id
  key    = "layers/${var.support_layer_filename}"
  source = "${path.module}/${var.support_layer_filename}"
  etag   = filemd5("${path.module}/${var.support_layer_filename}")
}

resource "aws_lambda_layer_version" "support_agent_layer" {
  s3_bucket           = aws_s3_bucket.artifacts.id
  s3_key              = aws_s3_object.support_layer_s3.key
  s3_object_version   = aws_s3_object.support_layer_s3.version_id
  layer_name          = "support-agent-dependencies"
  compatible_runtimes = ["python3.11"]

  # Se elimina source_code_hash ya que usamos el versioning y etag de S3
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
