data "aws_route53_zone" "lab" {
  name         = "lab.younesblog.org"
  private_zone = false
}

resource "aws_route53_record" "lab" {
  zone_id = var.zone_id
  name    = "lab.younesblog.org"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}