resource "aws_dynamodb_table" "tickets_history" {
  name         = "TicketsHistoryPoC"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ticket_id"

  attribute {
    name = "ticket_id"
    type = "S"
  }

  tags = {
    Environment = "PoC"
    Project     = "TicketsBedrock"
  }
}
