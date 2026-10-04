output "vpc-id" {
  value       = aws_vpc.tf-vpc.id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value = [
    for subnet in aws_subnet.tf-subnet : subnet.id
  ]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value = [
    for subnet in aws_subnet.tf-private-subnet : subnet.id
  ]
}

output "ec2_instance_ids" {
  description = "IDs of the application EC2 instances"
  value = [
    for instance in aws_instance.tf_instance : instance.id
  ]
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer to access the application"
  value       = aws_lb.tf_lb.dns_name
}