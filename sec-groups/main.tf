resource "aws_security_group" "allow" {
  name        = "${var.name}-sgallow-${var.environment}"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Enable HTTP,SSH Access"
    from_port        = 0
    to_port          = 0
    protocol         = "all"
    self = true
  }
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "enable https and ssh"
  }
}

output "security_group_id" {
  value = aws_security_group.allow.id
}