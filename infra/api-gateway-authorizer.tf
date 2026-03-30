resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name          = "TicketsCognitoAuthorizer"
  rest_api_id   = aws_api_gateway_rest_api.tickets_api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.tickets_pool.arn]
}
