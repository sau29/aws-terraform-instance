variable "rearc-quest-tasks-trfm-ec2-instance_type" {
  description = "Instance Type for server"
  type        = string
  default     = "t2.micro"
}

#option-1: have user enter AMI
variable "rearc-quest-tasks-trfm-ec2-ami" {
  description = "AMI for server instance"
  type        = string
  default     = "ami-0b5eea76982371e91"
}

variable "rearc-quest-tasks-trfm-ec2-Number" {
  description = "Number of Instances"
  type        = string
  default     = "1"
}

#option-2: have ami from data type - TODO

