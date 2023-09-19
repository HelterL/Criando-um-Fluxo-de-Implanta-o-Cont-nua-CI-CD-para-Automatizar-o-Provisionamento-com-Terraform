provider "aws" {
  region = "us-east-1"
  version = "~>5.9"

}
terraform {
  backend "s3" {
    bucket = "projetodevopstf"
    key = "projetodevops.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
module "vpc" {
  source = "./vpc"
  name = var.name
  environment = var.environment
  cidr = var.cidr
  private_subnet = var.private_subnet
  public_subnet = var.public_subnet
  availability_zones = var.availability_zones
}

module "security_groups" {
  source         = "./sec-groups"
  name           = var.name
  vpc_id         = module.vpc.id
  environment    = var.environment
}

module "ec2" {
  source = "./ec2"
  vpc_id = module.vpc.id
  environment = var.environment
  public_subnet_id = module.vpc.public_subnets.id
  sec_group_id = module.security_groups.security_group_id
}