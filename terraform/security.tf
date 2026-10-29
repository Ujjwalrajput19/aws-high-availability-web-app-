resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Controls traffic for the Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-alb-sg"
  }
}

resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "Controls traffic for the EC2 web servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP from the internet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_to_web" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP from the ALB to the web servers"

  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_ingress_rule" "web_from_alb" {
  security_group_id = aws_security_group.web.id
  description       = "Allow HTTP from the ALB"

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "web_https" {
  security_group_id = aws_security_group.web.id
  description       = "Allow HTTPS for SSM and package repositories"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}