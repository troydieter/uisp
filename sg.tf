# Security Group

resource "aws_security_group" "uisp" {
  name_prefix = "${var.application}-${random_id.rando.hex}"
  vpc_id      = module.vpc.vpc_id
  description = "${var.application}-${var.environment}-${random_id.rando.hex}-sg"
  tags        = local.common-tags
}

resource "aws_security_group_rule" "allow_all" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = [var.public_internet]
  security_group_id = aws_security_group.uisp.id
}

resource "aws_security_group_rule" "uisp-public" {
  description = "${var.application}-${var.environment}-${random_id.rando.hex}-${each.key}"
  for_each = {
    2055 = "udp"
    0    = "icmp"
  }

  from_port         = each.key
  to_port           = each.key
  protocol          = each.value
  security_group_id = aws_security_group.uisp.id
  type              = "ingress"
  cidr_blocks       = [var.public_internet]
}

resource "aws_security_group_rule" "uisp-private" {
  description = "${var.application}-${var.environment}-${random_id.rando.hex}-${each.key}"
  for_each = {
    80   = "tcp"
    443  = "tcp"
    2055 = "udp"
    81   = "tcp"
  }

  from_port         = each.key
  to_port           = each.key
  protocol          = each.value
  security_group_id = aws_security_group.uisp.id
  type              = "ingress"
  cidr_blocks       = ["${local.ifconfig_co_json.ip}/32"]
}

# AWS LB

resource "aws_security_group" "lb" {
  name_prefix = "${var.application}-lb-${random_id.rando.hex}"
  vpc_id      = module.vpc.vpc_id
  description = "${var.application}-${var.environment}-${random_id.rando.hex}-lb-sg"
  tags        = local.common-tags
}

resource "aws_security_group_rule" "lb_allow_all" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = [var.public_internet]
  security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "lb" {
  description = "${var.application}-${var.environment}-${random_id.rando.hex}-lb-${each.key}"
  for_each = {
    443 = "tcp"
  }

  from_port         = each.key
  to_port           = each.key
  protocol          = each.value
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
  cidr_blocks       = [var.public_internet]
}

resource "aws_security_group_rule" "lb2ec2" {
  description = "${var.application}-${var.environment}-${random_id.rando.hex}-lb2ec2-${each.key}"
  for_each = {
    443 = "tcp"
  }

  from_port                = each.key
  to_port                  = each.key
  protocol                 = each.value
  security_group_id        = aws_security_group.uisp.id
  type                     = "ingress"
  source_security_group_id = aws_security_group.lb.id
}