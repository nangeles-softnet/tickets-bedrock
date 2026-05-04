locals {
  _domain_raw                   = lower(trimspace(var.custom_domain_name))
  api_domain_host               = length(local._domain_raw) > 0 ? trimsuffix(trim(replace(replace(local._domain_raw, "https://", ""), "http://", ""), "/"), "/") : ""
  _path_raw                     = trimspace(var.custom_domain_ticket_path)
  api_ticket_path               = startswith(local._path_raw, "/") ? local._path_raw : "/${local._path_raw}"
  api_gateway_public_ticket_url = local.api_domain_host != "" ? "https://${local.api_domain_host}${local.api_ticket_path}" : "${aws_api_gateway_stage.poc_stage.invoke_url}/ticket"
}

output "api_gateway_url" {
  value       = local.api_gateway_public_ticket_url
  description = "URL para POST /ticket: dominio custom (tfvars) si custom_domain_name está definido; si no, URL por defecto de API Gateway."
}

output "api_gateway_invoke_url" {
  value       = "${aws_api_gateway_stage.poc_stage.invoke_url}/ticket"
  description = "URL execute-api (interna AWS); la misma que api_gateway_url cuando no hay custom_domain_name."
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.tickets_pool.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.tickets_spa_client.id
}

output "cognito_idp_endpoint" {
  value       = "https://cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.tickets_pool.id}"
  description = "URL del issuer / IdP de Cognito (útil para JWT y configuración del frontend)"
}

output "aws_region" {
  value       = var.region
  description = "Región donde quedó desplegada la infraestructura"
}
