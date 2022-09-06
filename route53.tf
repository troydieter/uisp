# Route53 Record

data "aws_route53_zone" "uisp" {
  name         = "${var.tld}."
  private_zone = false
}

resource "aws_route53_record" "uisp" {
  zone_id = data.aws_route53_zone.uisp.zone_id
  name    = "uisp.${var.tld}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.uisp.dns_name]
}

output "public_addr" {
  value       = aws_route53_record.uisp.fqdn
  description = "Public address for UISP"
}