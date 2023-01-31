# /*
# In this domain, we will configure:
# Target Group - aws_lb_target_group
# Target Group Attachment - aws_lb_target_group_attachment

# Listener - aws_lb_listener
# Listener Rule - aws_lb_listerner_rule
# TLS certificate with Load Balancer - aws_lb_listerner_certificate

# Load Balancer - aws_lb

# EC2 Instance - aws_instance
# */


# NOTE: Through console we can create target group, even when no instance are available. Later we can do it manually.
# Need to see what needs to be done in terraform. Either we will have instance launch first, then wait for it by applying "depends on"
# and then create target group.
# What will happen when that instance will terminate, will new instance launched will get updated.
# solution could be to have autoscaling configured - lets explore both the scenarios.

#Target Group - aws_lb_target_group
resource "aws_lb_target_group" "rearc-quest-tasks-trfm-targetgroup" {
  name     = "rearc-quest-tasks-trfm-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.rearc-quest-tasks-trfm-vpc.id
}

#Target Group Attachment - aws_lb_target_group_attachment
#depends on instance
resource "aws_lb_target_group_attachment" "rearc-quest-tasks-trfm-targetgroup-atchmt" {
  depends_on = [
    aws_lb_target_group.rearc-quest-tasks-trfm-targetgroup
  ]

  #TODO - Post question in linkedin for terraform, why can't they update target_id of type list to take multiple values??
  # 3 Scenarios
  # 1 target group with 1 instance each
  # 1 target group with multiple instance
  # multiple target group with single instance each
  # having 1 resource to deploy multiple instance, and use index, OR
  # having seperate resource for each instance
  count            = var.rearc-quest-tasks-trfm-ec2-Number
  target_group_arn = aws_lb_target_group.rearc-quest-tasks-trfm-targetgroup.arn
  #TODO: If registered instance gets terminated, will they get update again here, when we launch through TRFM?
  #target_id is mandatory parameter, as against configuring through console - JFI
  target_id        = aws_instance.rearc-quest-tasks-trfm-instance-count[count.index].id
  port             = 80
}

#Listener - aws_lb_listener
resource "aws_lb_listener" "rearc-quest-tasks-trfm-listener-http" {
  depends_on = [
    aws_lb_target_group.rearc-quest-tasks-trfm-targetgroup
  ]

  load_balancer_arn = aws_alb.rearc-quest-tasks-trfm-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rearc-quest-tasks-trfm-targetgroup.arn
  }
}


# #Listener Rule - aws_lb_listerner_rule

#TLS certificate with Load Balancer - aws_lb_listerner_certificate
# resource "aws_lb_listener" "rearc-quest-tasks-trfm-listener-https" {
#   load_balancer_arn = aws_lb.rearc-quest-tasks-trfm-alb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.rearc-quest-tasks-trfm-targetgroup.arn
#   }
# }

#Load Balancer - aws_lb
resource "aws_alb" "rearc-quest-tasks-trfm-alb" {
  name               = "rearc-quest-tasks-trfm-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.rearc-quest-tasks-trfm-sg-alb.id]

  subnets = [aws_subnet.rearc-quest-tasks-trfm-subnet1-pub.id, aws_subnet.rearc-quest-tasks-trfm-subnet2-pub.id]

  #   enable_deletion_protection = true



  # Having permission issue in s3 buclet, will come back to it later
  # │ Error: failure configuring LB attributes: InvalidConfigurationRequest: Access Denied for bucket: rearc-quest-tasks-trfm-s3-alb. Please check S3bucket permission
  # │       status code: 400, request id: 156758e3-ac14-420f-b7b8-1e6430245346
  # depends_on = [
  #   aws_s3_bucket.rearc-quest-tasks-trfm-s3-alb
  # ]
  #   access_logs {
  #     bucket  = aws_s3_bucket.rearc-quest-tasks-trfm-s3-alb.bucket
  #     prefix  = "logs/rearc-quest-tasks-trfm-alb-logs"
  #     enabled = true
  #   }

  tags = {
    "Name"      = "rearc-quest-tasks-trfm-alb"
    "BelongsTo" = "rearc-quest-tasks-trfm"
  }

}

# # create s3 bucket to store alb logs
# resource "aws_s3_bucket" "rearc-quest-tasks-trfm-s3-alb" {
#   bucket = "rearc-quest-tasks-trfm-s3-alb"

#   tags = {
#     "Name"      = "rearc-quest-tasks-trfm-s3-alb"
#     "BelongsTo" = "rearc-quest-tasks-trfm"
#   }
# }

# resource "aws_s3_bucket_acl" "rearc-quest-tasks-trfm-s3-alb-acl" {
#   bucket = aws_s3_bucket.rearc-quest-tasks-trfm-s3-alb.id
#   acl    = "private"
# }

