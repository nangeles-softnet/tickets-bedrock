# --- Registro DNS para el API Gateway Custom Domain ---
resource "aws_route53_record" "api_alias" {
  name    = var.custom_domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    name                   = aws_api_gateway_domain_name.api_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_domain.regional_zone_id
    evaluate_target_health = false
  }
}
