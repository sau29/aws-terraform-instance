resource "aws_launch_configuration" "rearc-quest-tasks-trfm-ecs-lnchcfg" {
  # image_id             = "ami-094d4d00fd7462815"
  image_id                    = data.aws_ami.ecs_ami.id
  iam_instance_profile        = aws_iam_instance_profile.rearc-quest-tasks-trfm-tdef-instprfl.name
  security_groups             = [aws_security_group.rearc-quest-tasks-trfm-sg-ecs.id]
  user_data = file("apache-install.sh")  
#   user_data                   = <<EOF
#       #!/bin/bash 
#       echo "ecs_CLUSTER=rearc-quest-tasks-trfm-cluster" > /etc/ecs/ecs.config
#     EOF
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
}

resource "aws_autoscaling_group" "rearc-quest-tasks-trfm-ecs-asg" {
  name                 = "rearc-quest-tasks-trfm-ecs-asg"
  vpc_zone_identifier  = [aws_subnet.rearc-quest-tasks-trfm-subnet1-pub.id]
  launch_configuration = aws_launch_configuration.rearc-quest-tasks-trfm-ecs-lnchcfg.name

  desired_capacity          = 0
  min_size                  = 0
  max_size                  = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.rearc-quest-tasks-trfm-ecs-asg.id
  lb_target_group_arn    = aws_lb_target_group.rearc-quest-tasks-trfm-targetgroup.arn
}