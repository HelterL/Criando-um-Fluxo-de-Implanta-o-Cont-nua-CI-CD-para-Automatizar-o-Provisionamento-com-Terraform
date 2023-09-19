variable "name" {
 default = "devteste"
 type = string
}

variable "environment" {
  default = "Terraforminfra"
  type = string
}

variable "cidr" {
  default = "10.0.0.0/16"
  type = string
}

variable "public_subnet" {
  default = "10.0.1.0/24"
  type = string
}

variable "private_subnet" {
  default = "10.0.2.0/24"
  type = string
}

variable "availability_zones" {
  default = "us-east-1a"
  type = string
}