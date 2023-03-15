variable "region" {
  type        = string
  description = "Region for AWS provider"
  default     = "eu-west-1"
}

variable "ami_id_asg_template" {
  type        = string
  description = "Ami id for fargate and fargate spot"
  default     = "ami-0d50e5e845c552faf"
}