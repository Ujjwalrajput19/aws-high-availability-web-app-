variable "aws_region" {
  description = "AWS Region used for the lab."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name used to identify the project resources."
  type        = string
  default     = "aws-high-availability-web-app"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "lab"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type used by the web tier."
  type        = string
  default     = "t3.micro"
}

variable "web_instance_count" {
  description = "Number of EC2 web servers maintained by the Auto Scaling Group."
  type        = number
  default     = 2

  validation {
    condition     = contains([1, 2], var.web_instance_count)
    error_message = "web_instance_count must be either 1 or 2 for this cost-controlled lab."
  }
}
