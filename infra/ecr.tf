resource "aws_ecr_repository" "support_agent" {
  name                 = "tickets-support-agent"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true # Permite destruir el repo aunque tenga imágenes (útil para PoC)

  tags = {
    Environment = "PoC"
    Project     = "TicketsBedrock"
  }
}

# Política de ciclo de vida para no acumular imágenes viejas
resource "aws_ecr_lifecycle_policy" "support_agent_policy" {
  repository = aws_ecr_repository.support_agent.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Mantener solo las últimas 3 imágenes"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 3
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "ecr_repository_url" {
  value = aws_ecr_repository.support_agent.repository_url
}
