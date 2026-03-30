resource "aws_api_gateway_rest_api" "tickets_api" {
  name        = "TicketsPoCAPI"
  description = "API para Portal de Soporte PoC Bedrock"
}
