Terraform template to deploy AWS infrastructure...

Networking:
It creates VPC, 2 public subnets, Internet gateways, route tables, security groups for load balancer and server instance(take care of cycle dependency)

Computing:
It can create multiple instances, and gets attached with Target group of Application Load Balancer.
With Userdata, server instance are read with http server and index page.

Once deployed, just do http with public Ip or DNS name to access index page.

Steps:
1. terraform init
2. terraform apply -auto-approve
3. terraform output
