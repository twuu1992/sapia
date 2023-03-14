# Launch template for Fargate
resource "aws_launch_template" "ecs_fargate_template" {
  name = "ecs-fargate-template"
  description = "This template is for launch the ASG for ECS fargate"

  block_device_mappings {   # ebs definition
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20  # 20 Gigabytes
      volume_type = "gp2"
    }
  }

  image_id = var.ami_id_asg_template
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  key_name = var.key_pair

  monitoring {
    enabled = true  # Detailed Monitoring
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [var.ecs_sg_id]
    subnet_id = var.subnet_ids[0]
  }

  vpc_security_group_ids = [var.ecs_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ecs-fargate-instance"
    }
  }

#   user_data = filebase64("${path.module}/example.sh")
}

# Launch template for Fargate Spot
resource "aws_launch_template" "ecs_fargate_spot_template" {
  name = "ecs-fargate-spot-template"
  description = "This template is for launch the ASG for ECS fargate spot"

  block_device_mappings {   # ebs definition
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20  # 20 Gigabytes
      volume_type = "gp2"
    }
  }

  image_id = var.ami_id_asg_template
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  key_name = var.key_pair

  monitoring {
    enabled = true  # Detailed Monitoring
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [var.ecs_sg_id]
    subnet_id = var.subnet_ids[0]
  }

  vpc_security_group_ids = [var.ecs_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ecs-fargate-spot-instance"
    }
  }

  instance_market_options {     # Create Spot instances
    market_type = "spot"
    spot_options {
      max_price = "0.01"    # Hourly price paid for spot instance
      spot_instance_type = "one-time"
    }
  }

#   user_data = filebase64("${path.module}/example.sh")
}

# Create auto scaling group for fargate
resource "aws_autoscaling_group" "ecs_fargate_asg" {
  name                      = "ecs-fargate-asg"
  max_size                  = 5
  min_size                  = 1
  desired_capacity          = 1
  launch_template {
    id = aws_launch_template.ecs_fargate_template.id
    version = "$Latest"
  }
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true

  vpc_zone_identifier       = var.subnet_ids
  target_group_arns = [ aws_lb_target_group.nginx_http_tg.arn ]

  tag {
    key                 = "Name"
    value               = "ecs-fargate-asg"
    propagate_at_launch = true
  }
}

# Create auto scaling group for fargate spot
resource "aws_autoscaling_group" "ecs_fargate_spot_asg" {
  name                      = "ecs-fargate-spot-asg"
  max_size                  = 5
  min_size                  = 1
  desired_capacity          = 1
  launch_template {
    id = aws_launch_template.ecs_fargate_spot_template.id
    version = "$Latest"
  }
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true

  vpc_zone_identifier       = var.subnet_ids
  target_group_arns = [ aws_lb_target_group.nginx_http_tg.arn ]

  tag {
    key                 = "Name"
    value               = "ecs-fargate-spot-asg"
    propagate_at_launch = true
  }
}