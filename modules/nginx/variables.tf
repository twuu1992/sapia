variable "vpc_id" {
  type = string
}

variable "ecs_sg_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "ecs_role_arn" {
  type = string
}

variable "ecs_role_policy" {
  type = any
}