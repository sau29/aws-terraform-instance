resource "aws_ecs_task_definition" "rearc-quest-tasks-trfm-tdef" {
  family                   = "rearc-quest-tasks-trfm-ecs"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  # cpu                      = 1024
  # memory                   = 2048
  container_definitions = <<DEFINITION
[
      {
        "entryPoint": [
          "sh",
          "-c"
        ],
        "portMappings": [
          {
            "hostPort": 80,
            "protocol": "tcp",
            "containerPort": 80
          }
        ],
        "command": [
          "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Saurabh's application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
        ],
        "cpu": 10,
        "secrets": null,
        "memory": 300,
        "image": "httpd:2.4",
        "essential": true,
        "name": "rearc-quest-tasks-trfm-tdef-contnr"
      }
]
DEFINITION
}

resource "aws_ecs_cluster" "rearc-quest-tasks-trfm-cluster" {
  name = "rearc-quest-tasks-trfm-cluster"
}

#Issue: service rearc-quest-tasks-trfm-tdef-service was unable to place a task 
#because no container instance met all of its requirements. Reason: No Container 
#Instances were found in your cluster. 
resource "aws_ecs_service" "rearc-quest-tasks-trfm-tdef-service" {
  name                = "rearc-quest-tasks-trfm-tdef-service"
  cluster             = aws_ecs_cluster.rearc-quest-tasks-trfm-cluster.id
  task_definition     = aws_ecs_task_definition.rearc-quest-tasks-trfm-tdef.arn
  desired_count       = 1
  scheduling_strategy = "REPLICA"
  launch_type         = "EC2"

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.hello_world.id
  #   container_name   = "hello-world-app"
  #   container_port   = 3000
  # }

  # depends_on = [aws_lb_listener.hello_world]
}


# Above code works partially fine, it creates cluster, task defination and service
#but unable to run task as ec2 container is not running, it seems to address that
#i need to have autoscaling and launch template and iam role(instance profile) 
#also configured;
# Referring to link for solution:
#https://medium.com/swlh/creating-an-aws-ecs-cluster-of-ec2-instances-with-terraform-85a10b5cfbe3


/*
│ Error: creating Auto Scaling Launch Configuration (terraform-20230201093315359300000001): couldn't find resource
│
│   with aws_launch_configuration.ecs_launch_config,
│   on computing-container.tf line 130, in resource "aws_launch_configuration" "ecs_launch_config":
│  130: resource "aws_launch_configuration" "ecs_launch_config" {

While usingg AMI ami-094d4d00fd7462815 getting error
People are suggesting to change AMI, and they have resolved the issue; Me too now
using ecs optimized ami from data type;
https://stackoverflow.com/questions/73146187/aws-launch-configuration-couldnt-find-resource-on-terraform-apply
*/

# AutoScaling and Launch Configuration
# instance is launched but it lacks public ip and also could not register with cluster; for debugging atleast have public ip;
# could not update desired capacity to 0 from 1 since getting following error:
# │ Error: deleting Auto Scaling Launch Configuration (terraform-20230201095140131800000001): ResourceInUse: Cannot delete launch configuration terraform-20230201095140131800000001 because it is attached to AutoScalingGroup rearc-quest-tasks-trfm-ecs-asg
# │       status code: 400, request id: fb166d17-87c2-4ad6-9739-6c05e1ec8e5b
# had to manually update 0's in console and when instance terminate, i execute code to update public ip; still got the same error message
# Again this is known issue:
# Cannot update launch configuration, it doesn't allow - because it is attached to AutoScalingGroup #8485
# https://github.com/hashicorp/terraform-provider-aws/issues/8485

#ECS Optimized AMI does not have support of ssh and ssm agent, bad boy - i struggled and wasted my time; now i have to figure out why this
#instance is not gettig part of cluster, is the userdata throwing some error...??
#Also, if i launch instance with same ami-id, instance profile and userdata - this instance gets register with cluster but not the instance which gets laucnhed with AScal :-(
resource "aws_launch_configuration" "rearc-quest-tasks-trfm-ecs-lnchcfg" {
  # image_id             = "ami-094d4d00fd7462815"
  image_id                    = data.aws_ami.ecs_ami.id
  iam_instance_profile        = aws_iam_instance_profile.rearc-quest-tasks-trfm-tdef-instprfl.name
  security_groups             = [aws_security_group.rearc-quest-tasks-trfm-sg-ecs.id]
  user_data                   = <<EOF
      #!/bin/bash 
      echo "ECS_CLUSTER=rearc-quest-tasks-trfm-cluster" > /etc/ecs/ecs.config
    EOF
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

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

#DEBUG 
# Check whether ECS agent is running on the EC2 instances.

# Login to EC2 instance as root.
# Run docker ps and check for whether ecs-agent container is running.
# Otherwise start manually by start ecs or restart ecs.