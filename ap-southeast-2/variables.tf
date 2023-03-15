variable "region" {
  type        = string
  description = "Region for AWS provider"
  default     = "ap-southeast-2"
}

variable "ami_id_asg_template" {
  type        = string
  description = "Ami id for fargate and fargate spot"
  default     = "ami-08f0bc76ca5236b20"
}