terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Como es un entorno PoC y el bucket original podría no estar preparado para ti,
  # puedes configurar un local tfstate. Si prefieres backend "s3", descomenta.
  # backend "s3" {
  #   bucket = "softnet-configs"
  #   key    = "demo-tickets-infra/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.region
}
