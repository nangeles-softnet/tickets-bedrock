resource "aws_api_gateway_deployment" "poc_deployment" {
  depends_on = [
    aws_api_gateway_integration.post_ticket_integration,
    aws_api_gateway_integration.options_ticket_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.tickets_api.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "poc_stage" {
  deployment_id = aws_api_gateway_deployment.poc_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.tickets_api.id
  stage_name    = "poc"
}
