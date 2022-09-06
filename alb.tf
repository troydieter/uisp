# AWS Application Load Balancer

data "aws_subnets" "public" {

  tags = {
    Reach = "public"
  }
}

data "aws_subnet" "public" {
  for_each = toset(module.vpc.public_subnets)
  id       = each.value
  depends_on = [
    module.vpc
  ]
}

resource "aws_lb" "uisp" {
  name               = "lb-${var.application}-${random_id.rando.hex}"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for s in data.aws_subnet.public : s.id]
  security_groups    = [aws_security_group.lb.id]

  enable_deletion_protection = false

  tags = local.common-tags
  depends_on = [
    module.vpc
  ]
}

resource "aws_lb_target_group" "lb-443" {
  name     = "lb-443tg-${var.application}-${random_id.rando.hex}"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = module.vpc.vpc_id
  health_check {
    enabled             = true
    matcher             = "302"
    healthy_threshold   = 5
    protocol            = "HTTPS"
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "lb-443" {
  target_group_arn = aws_lb_target_group.lb-443.arn
  target_id        = module.ec2_instance.id
  port             = 443
}

resource "aws_lb_listener" "listener-443" {
  load_balancer_arn = aws_lb.uisp.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.alb_sec_policy
  certificate_arn   = module.acm_request_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-443.arn
  }
}

module "acm_request_certificate" {
  source = "cloudposse/acm-request-certificate/aws"

  domain_name                       = var.tld
  subject_alternative_names         = ["${var.application}.${var.tld}"]
  process_domain_validation_options = true
  ttl                               = "300"
}