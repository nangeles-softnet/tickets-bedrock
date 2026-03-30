output "api_gateway_url" {
  value = "${aws_api_gateway_stage.poc_stage.invoke_url}/ticket"
  description = "URL base para consultar peticiones de tickets desde la API"
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.tickets_pool.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.tickets_spa_client.id
}
