module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"

  aliases = ["redirect.domain.com"]

  comment             = "Redirect POC"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true

  origin = {
    djhdomain = {
      domain_name = "otherdomain.com"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id           = "djhdomain"
    viewer_protocol_policy     = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  ordered_cache_behavior = [
  ]

  viewer_certificate = {
    acm_certificate_arn = "arn:aws:acm:us-east-1:456509733385:certificate/e92a4d58-34bd-460b-81a6-973daadf41cc"
    ssl_support_method  = "sni-only"
  }
}