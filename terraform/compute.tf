data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_launch_template" "web" {
  name_prefix   = "${local.name_prefix}-web-"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type

  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.web.name
  }

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    device_index                = 0
    security_groups             = [aws_security_group.web.id]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 8
      volume_type           = "gp3"
    }
  }

  user_data = base64encode(file("${path.module}/../scripts/user-data.sh"))

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-web"
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-web-volume"
    })
  }

  tags = {
    Name = "${local.name_prefix}-launch-template"
  }
}

resource "aws_autoscaling_group" "web" {
  name = "${local.name_prefix}-asg"

  desired_capacity = var.web_instance_count
  min_size         = var.web_instance_count
  max_size         = var.web_instance_count

  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns   = [aws_lb_target_group.web.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 180

  force_delete = true

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-web"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}