data "aws_route53_zone" "selected" {
  zone_id = var.hosted_zone_id
}

resource "aws_route53_record" "alb_dns_name" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "meetlyomni-api.dilab.click"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
