# --- CONFIGURACIÓN DE DOMINIO PERSONALIZADO ---
resource "aws_api_gateway_domain_name" "api_domain" {
  domain_name              = var.custom_domain_name
  regional_certificate_arn = var.acm_certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# --- MAPEADO DE RUTA (CONECTAR DOMINIO CON EL API) ---
resource "aws_api_gateway_base_path_mapping" "api_mapping" {
  api_id      = aws_api_gateway_rest_api.tickets_api.id
  stage_name  = aws_api_gateway_stage.poc_stage.stage_name
  domain_name = aws_api_gateway_domain_name.api_domain.domain_name
}
