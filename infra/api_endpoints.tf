resource "aws_api_gateway_resource" "tickets_resource" {
  rest_api_id = aws_api_gateway_rest_api.tickets_api.id
  parent_id   = aws_api_gateway_rest_api.tickets_api.root_resource_id
  path_part   = "ticket" # /ticket
}

# ==== MÉTODO POST (Crear ticket / Chat) ====
resource "aws_api_gateway_method" "post_ticket" {
  rest_api_id   = aws_api_gateway_rest_api.tickets_api.id
  resource_id   = aws_api_gateway_resource.tickets_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_integration" "post_ticket_integration" {
  rest_api_id             = aws_api_gateway_rest_api.tickets_api.id
  resource_id             = aws_api_gateway_resource.tickets_resource.id
  http_method             = aws_api_gateway_method.post_ticket.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_support_agent.invoke_arn
}

# ==== CONFIGURACIÓN CORS (OPTIONS) ====
resource "aws_api_gateway_method" "options_ticket" {
  rest_api_id   = aws_api_gateway_rest_api.tickets_api.id
  resource_id   = aws_api_gateway_resource.tickets_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_ticket_integration" {
  rest_api_id = aws_api_gateway_rest_api.tickets_api.id
  resource_id = aws_api_gateway_resource.tickets_resource.id
  http_method = aws_api_gateway_method.options_ticket.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_ticket_200" {
  rest_api_id = aws_api_gateway_rest_api.tickets_api.id
  resource_id = aws_api_gateway_resource.tickets_resource.id
  http_method = aws_api_gateway_method.options_ticket.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_ticket_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.tickets_api.id
  resource_id = aws_api_gateway_resource.tickets_resource.id
  http_method = aws_api_gateway_method.options_ticket.http_method
  status_code = aws_api_gateway_method_response.options_ticket_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options_ticket_integration]
}
