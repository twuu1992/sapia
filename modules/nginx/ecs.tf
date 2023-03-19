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
    Name        = "nginx-cluster"
  }
}

# Create the ECS task definition
resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx-task"
  requires_compatibilities = ["FARGATE"] # TODO: Add Fargate spot by using capacity provider
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = "nginx",
      image     = "nginx:latest",
      cpu       = 256,
      memory    = 512,
      essential = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80
          protocol      = "tcp"
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
  iam_role        = aws_iam_role.ecs_role.arn
  depends_on      = [aws_iam_role_policy.ecs_policy]
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx_http_tg.arn
    container_name   = "nginx-container"
    container_port   = 80
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = [ aws_security_group.nginx_http_sg.id ]
    subnets          = data.aws_subnet_ids.default.ids
  }

  
}

# Create Capacity Provider for Fargate
resource "aws_ecs_capacity_provider" "fargate" {
  name = "fargate_capacity_provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_fargate_asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 80  # reach 80% utilization
    }
  }
}

# Create Capacity Provider for Fargate Spot
resource "aws_ecs_capacity_provider" "fargate_spot" {
  name = "fargate_spot_capacity_provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_fargate_spot_asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 80  # reach 80% utilization
    }
  }
}

# Create Cluster Capacity Provider to link both above
resource "aws_ecs_cluster_capacity_providers" "cluster_cp" {
  cluster_name = module.ecs.cluster_name

  capacity_providers = [aws_ecs_capacity_provider.fargate.name, aws_ecs_capacity_provider.fargate_spot.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 50
    capacity_provider = aws_ecs_capacity_provider.fargate.name
  }

  default_capacity_provider_strategy {
    base              = 1
    weight            = 50
    capacity_provider = aws_ecs_capacity_provider.fargate_spot.name
  }
}