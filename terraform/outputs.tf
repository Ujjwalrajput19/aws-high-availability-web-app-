output "aws_region" {
  description = "AWS Region containing the lab resources."
  value       = var.aws_region
}

output "vpc_id" {
  description = "ID of the lab VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the two public subnets."
  value       = aws_subnet.public[*].id
}

output "alb_dns_name" {
  description = "DNS hostname assigned to the Application Load Balancer."
  value       = aws_lb.web.dns_name
}

output "alb_url" {
  description = "HTTP URL for testing the Application Load Balancer."
  value       = "http://${aws_lb.web.dns_name}"
}

output "target_group_arn" {
  description = "ARN of the ALB target group."
  value       = aws_lb_target_group.web.arn
}

output "autoscaling_group_name" {
  description = "Name of the web-tier Auto Scaling Group."
  value       = aws_autoscaling_group.web.name
}