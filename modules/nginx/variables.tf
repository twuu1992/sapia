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

variable "ami_id_asg_template"{
    type = string
    default = "ami-08f0bc76ca5236b20"
    description = "AMI id for asg launch template, default to ubuntu"
}

variable "key_pair" {
  type = string
  default = "EC2-Key-Pair"
}