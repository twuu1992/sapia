# Import VPC from data source
data "aws_vpc" "default" {
  default = true
}

# Import subnet ids from VPC
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Security Group for nginx
resource "aws_security_group" "nginx_http_sg" {
  name        = "allow_http_nginx"
  description = "Allow http inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "Http from alb to nginx ECS Cluster"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [ aws_security_group.alb_http_sg ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http_nginx"
  }
}

# Security Group for alb
resource "aws_security_group" "alb_http_sg" {
  name        = "allow_http_alb"
  description = "Allow http inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Http to application load balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http_alb"
  }
}