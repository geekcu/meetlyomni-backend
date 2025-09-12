variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID"
  type = string
  default = "Z03216841ZIYVSB5QWHDY"
  
}

variable "alb_dns_name" {
  description = "ALB DNS Name"
  type = string
}

variable "alb_zone_id" {
  description = "ALB Zone ID"
  type = string
}
