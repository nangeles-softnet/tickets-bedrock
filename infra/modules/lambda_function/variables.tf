variable "name" {
  type = string
}

variable "filename" {
  type = string
}

variable "description" {
  type = string
}

variable "handler" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "api_arn" {
  type = string
}

variable "envs" {
  type    = map(string)
  default = {}
}

variable "efs_arn" {
  type    = string
  default = ""
}

variable "efs_mount_path" {
  type    = string
  default = ""
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "layers" {
  type    = list(string)
  default = []
}
