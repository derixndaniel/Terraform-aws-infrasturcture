resource "aws_vpc" "tf-vpc" {

  cidr_block = var.cidr_block
  tags = {
    Name        = "tf-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "tf-subnet" {

  for_each                = var.public_subnet_ranges
  vpc_id                  = aws_vpc.tf-vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.AZ
  map_public_ip_on_launch = true

  tags = {
    Name        = "tf-${each.key}"
    Environment = var.environment
  }
}

resource "aws_subnet" "tf-private-subnet" {

  for_each                = var.private_subnet_ranges
  vpc_id                  = aws_vpc.tf-vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.AZ
  map_public_ip_on_launch = false

  tags = {
    Name        = "tf-${each.key}"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "tf-ig" {

  vpc_id = aws_vpc.tf-vpc.id
  tags = {
    Name        = "tf-igw"
    Environment = var.environment
  }

}

resource "aws_route_table" "tf-routetable" {

  vpc_id = aws_vpc.tf-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-ig.id
  }

  tags = {
    Name        = "tf-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "aws_route_table_association" {

  for_each       = aws_subnet.tf-subnet
  route_table_id = aws_route_table.tf-routetable.id
  subnet_id      = each.value.id

}

resource "aws_security_group" "alb-security_group" {

  name   = "alb-sec-group"
  vpc_id = aws_vpc.tf-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "tf-alb-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "app_sec_group" {

  name   = "app-sec-group"
  vpc_id = aws_vpc.tf-vpc.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-security_group.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "tf-app-sg"
    Environment = var.environment
  }

}

resource "aws_instance" "tf_instance" {

  for_each               = aws_subnet.tf-private-subnet
  ami                    = "ami-0f8a61b66d1accaee"
  instance_type          = var.instance_type
  subnet_id              = each.value.id
  vpc_security_group_ids = [aws_security_group.app_sec_group.id]

  user_data = <<-EOF
    #!/bin/bash

    mkdir -p /opt/web

    echo "<h1>Terraform AWS Infrastructure</h1>
    <h2>Application Load Balancer Working Successfully!</h2>
    <p>Environment: ${var.environment}</p>
    <p>Server: ${each.key}</p>" > /opt/web/index.html

    cd /opt/web
    nohup python3 -m http.server 80 > /var/log/webserver.log 2>&1 &
  EOF
  tags = {
    Name        = "tf-app-${each.key}"
    Environment = var.environment
  }
}

resource "aws_lb" "tf_lb" {


  name               = "tf-alb"
  load_balancer_type = "application"
  internal           = false
  subnets = [
    for subnet in aws_subnet.tf-subnet : subnet.id
  ]
  security_groups = [aws_security_group.alb-security_group.id]
  tags = {
    Name        = "tf-alb"
    Environment = var.environment
  }

}

resource "aws_lb_target_group" "tf-lb-tg" {

  name     = "tf-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tf-vpc.id

  tags = {
    Name        = "tf-lb-tg"
    Environment = var.environment
  }
}

resource "aws_lb_target_group_attachment" "tf-lb-tg-attachment" {

  for_each         = aws_instance.tf_instance
  target_group_arn = aws_lb_target_group.tf-lb-tg.arn
  port             = 80
  target_id        = each.value.id
}

resource "aws_lb_listener" "tf_lb_listener" {

  load_balancer_arn = aws_lb.tf_lb.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf-lb-tg.arn
  }
}