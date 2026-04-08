variable "aws_profile" {
  type        = string
  description = "Perfil de AWS CLI a utilizar"
}

variable "region" {
  type        = string
  description = "Región de AWS"
  default     = "us-east-1"
}

variable "model_id" {
  type        = string
  description = "ID del modelo fundacional en Amazon Bedrock"
}

variable "cohere_api_key" {
  type        = string
  description = "API Key para Cohere"
  sensitive   = true
}

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "Subnets para la Lambda (requeridas para EFS)"
  default     = []
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Security Groups para la Lambda (requeridas para EFS)"
  default     = []
}

variable "efs_arn" {
  type        = string
  description = "ARN del Access Point de EFS"
  default     = ""
}

variable "efs_mount_path" {
  type        = string
  description = "Ruta local donde se montará EFS"
  default     = "/mnt/efs"
}

variable "properties_support_agent" {
  type        = map(string)
  description = "Propiedades de empaquetado y nombre de la Lambda de soporte"
}

variable "support_layer_filename" {
  type        = string
  description = "Nombre del archivo zip de la capa de dependencias"
  default     = "support-layer.zip"
}

variable "custom_domain_name" {
  type        = string
  description = "Variable opcional heredada del tfvars compartido (no usada en este stack)"
  default     = ""
}

variable "zone_id" {
  type        = string
  description = "Variable opcional heredada del tfvars compartido (no usada en este stack)"
  default     = ""
}

variable "acm_certificate_arn" {
  type        = string
  description = "Variable opcional heredada del tfvars compartido (no usada en este stack)"
  default     = ""
}
