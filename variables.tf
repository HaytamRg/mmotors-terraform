variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "backend_image" {
  type    = string
  default = "428185450266.dkr.ecr.eu-west-3.amazonaws.com/fastapi-app:latest"
}

variable "container_port" {
  type    = number
  default = 8000
}

variable "db_username" {
  type    = string
  default = "mmotors_admin"
}

variable "db_password" {
  type      = string
  sensitive = true
}