resource "aws_vpc" "main" {
  cidr_block = var.cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name}-vpc-${var.environment}"
    Enviroment = var.environment
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-igw-${var.environment}"
    Enviroment = var.environment
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.private.id

 tags = {
    Name = "${var.name}-ngw-${var.environment}"
    Enviroment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "nat" {
  domain = "vpc"
tags = {
    Name = "${var.name}-eip-ngw-${var.environment}"
    Enviroment = var.environment
    }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet
  availability_zone = var.availability_zones
    tags = {
    Name = "${var.name}-public_subnet-${var.environment}"
    Enviroment = var.environment
  }
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet
    tags = {
    Name = "${var.name}-private_subnet-${var.environment}"
    Enviroment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-route_table_public-${var.environment}"
    Enviroment = var.environment
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-route_table_private-${var.environment}"
    Enviroment = var.environment
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route" "private" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

output "id" {
  value = aws_vpc.main.id
}
output "cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnets" {
  value = aws_subnet.public
}

output "private_subnets" {
  value = aws_subnet.private
}