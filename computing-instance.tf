# SCENARIO-1: Have Instance deployed first, and that will be part of target group as IP
# OR
# SCENARIO-2: Have AutoScaling take care of deploying instance and associate it with target group.

#EC2 Instance - launch single instance. target group code needs to update accordingly
# this code is not required actually - delete it,
# resource "aws_instance" "rearc-quest-tasks-trfm-instance" {
#     depends_on = [
#       aws_security_group.rearc-quest-tasks-trfm-sg-ec2,
#       aws_subnet.rearc-quest-tasks-trfm-subnet1-pub
#     ]

#   ami                         = var.rearc-quest-tasks-trfm-ec2-ami
#   instance_type               = var.rearc-quest-tasks-trfm-ec2-instance_type
#   associate_public_ip_address = true
#   security_groups             = [aws_security_group.rearc-quest-tasks-trfm-sg-ec2.id]
#   subnet_id                   = aws_subnet.rearc-quest-tasks-trfm-subnet1-pub.id
#   tags = {
#     "Name"      = "rearc-quest-tasks-trfm-instance"
#     "BelongsTo" = "rearc-quest-tasks-trfm"
#   }
#   user_data = file("apache-install.sh")
# }

# output "aws_instance_id_output" {
#     depends_on = [
#       aws_instance.rearc-quest-tasks-trfm-instance
#     ]
#   description = "Instance ID"
#   value       = aws_instance.rearc-quest-tasks-trfm-instance.id
# }


# Deploying multiple instance depending on the count
data "aws_availability_zones" "all" {}
resource "aws_instance" "rearc-quest-tasks-trfm-instance-count" {
  count             = var.rearc-quest-tasks-trfm-ec2-Number
  availability_zone = data.aws_availability_zones.all.names[count.index]
  ami               = var.rearc-quest-tasks-trfm-ec2-ami
  instance_type     = var.rearc-quest-tasks-trfm-ec2-instance_type

  associate_public_ip_address = true
  security_groups             = [aws_security_group.rearc-quest-tasks-trfm-sg-ec2.id]
  subnet_id                   = aws_subnet.rearc-quest-tasks-trfm-subnet1-pub.id
  tags = {
    "Name"      = "rearc-quest-tasks-trfm-instance"
    "BelongsTo" = "rearc-quest-tasks-trfm"
  }
  user_data = file("apache-install.sh")  
}


# Count is not supported in output, only in data, resource and module that too when count is in use. In Output we need to mention * to get
# all outputs,
output "aws_instance_id_output" {
    depends_on = [
      aws_instance.rearc-quest-tasks-trfm-instance-count
    ]
  description = "Instance ID"
  value       = aws_instance.rearc-quest-tasks-trfm-instance-count[*].id
}
