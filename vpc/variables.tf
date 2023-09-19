variable "name" {
  description = "nome do vpc"
}

variable "environment" {
  description = "nome do ambiente"
}

variable "cidr" {
  description = "bloco de endereços IPs"
}

variable "public_subnet" {
  description = "bloco de ip da subnet pública"
}

variable "private_subnet" {
  description = "bloco de ip da"
}

variable "availability_zones" {
  description = "lista de zonas disponiveis"
}