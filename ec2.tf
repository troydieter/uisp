# Provisions uisp

# AMI Info
data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20220322"]
  }
}

locals {
  user_data = <<-EOF
#!/bin/bash
sudo apt-get -y update && sudo apt-get -y install ca-certificates apt-transport-https
sudo apt-get clean
sudo curl -fsSL https://uisp.ui.com/v1/install > /tmp/uisp_inst.sh && sudo bash /tmp/uisp_inst.sh
EOF
}

# EC2 Deployment

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "${var.application}-${random_id.rando.hex}"

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.uisp.id}"]
  subnet_id              = tolist(module.vpc.public_subnets)[0]
  iam_instance_profile   = aws_iam_instance_profile.uisp.name
  user_data_base64       = base64encode(local.user_data)

  tags = local.common-tags
}

resource "aws_eip" "uisp" {
  vpc = true

  instance                  = module.ec2_instance.id
  associate_with_private_ip = module.ec2_instance.private_ip

  depends_on = [
    module.ec2_instance
  ]
  tags = merge(
    local.common-tags,
    {
      Name = "uisp-eip-${random_id.rando.hex}"
    },
  )
}

output "pubip" {
  value       = aws_eip.uisp.public_ip
  description = "Public IP Address for uisp"
}

output "ec2arn" {
  value       = module.ec2_instance.arn
  description = "ARN of the EC2 Instance"
}