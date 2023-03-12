# Create ECS Cluster
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "nginx-cluster"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  tags = {
    Environment = "Development"
    Name = "nginx-cluster"
  }
}

# Create the ECS task definition
resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = jsonencode([
    {
    name = "nginx",
    image = "nginx:latest",
    cpu = 256,
    memory = 512,
    essential = true,
    portMappings = [
        {
            containerPort = 80,
            hostPort = 80
            protocol = "tcp"
        }
    ]
    }
  ])
}

# Create the ECS service
resource "aws_ecs_service" "nginx" {
  name            = "nginx-service"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.nginx_task.id
  desired_count   = 1
  # iam_role        = aws_iam_role.foo.arn
  # depends_on      = [aws_iam_role_policy.foo]

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx_http_tg.arn
    container_name   = "nginx-container"
    container_port   = 80
  }

  network_configuration {
    assign_public_ip = true
    security_groups = [ aws_security_group.nginx_http_sg ]
    subnets = data.aws_subnet_ids.default.ids
  }
}