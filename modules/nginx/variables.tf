variable "ami_id_asg_template"{
    type = string
    default = "ami-08f0bc76ca5236b20"
    description = "AMI id for asg launch template, default to ubuntu"
}

variable "key_pair" {
  type = string
  default = "EC2-Key-Pair"
}