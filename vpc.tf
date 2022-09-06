###############
# VPC Resources
###############

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${var.application}-vpc-${random_id.rando.hex}"
  cidr = "10.77.0.0/18"

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  public_subnets  = ["10.77.0.0/24", "10.77.1.0/24", "10.77.2.0/24"]
  private_subnets = ["10.77.3.0/24", "10.77.4.0/24", "10.77.5.0/24"]

  create_database_subnet_group = false
  enable_dns_hostnames         = true
  enable_dns_support           = true

  tags = local.common-tags
}

data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  ifconfig_co_json = jsondecode(data.http.my_public_ip.body)
}