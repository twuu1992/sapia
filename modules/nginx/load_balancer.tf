# Create application load balancer for nginx server
resource "aws_lb" "alb_nginx" {
  name               = "alb-nginx"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = true

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "alb_nginx_"
  #   enabled = true
  # }

  tags = {
    Name = "alb-nginx"
  }
}

# Target Group
resource "aws_lb_target_group" "nginx_http_tg" {
  name     = "tf-nginx-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    port     = 80
    protocol = "HTTP"
    interval = 60
    timeout  = 10
    path     = "/"
  }

  tags = {
    "Name" = "nginx-target-group"
  }
}

# Listener
resource "aws_lb_listener" "nginx_http" {
  load_balancer_arn = aws_lb.alb_nginx.arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_http_tg.arn
  }
  tags = {
    "Name" = "nginx-lb-listener"
  }
}