variable "vpc_id" {
  description = "ID da VPC"
}
variable "environment" {
  description = "nome do ambiente"
}
variable "public_subnet_id" {
  description = "ID da subnet publica"
}
variable "sec_group_id" {
  description = "ID do grupo de segurança"
}

variable "user_data" {
  description = "Script a ser executado durante a criação da instância."

  default = <<-EOF
              #!/bin/bash
              sudo su
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EC2AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
              echo '<center><h1> Esta EC2 esta na Zona: AZID </h1></center>' > /var/www/html/index.txt
              sed "s/AZID/$EC2AZ/" /var/www/html/index.txt > /var/www/html/index.html
              EOF
}