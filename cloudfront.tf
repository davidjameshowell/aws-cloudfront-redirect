module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"

  aliases = [var.cloudfront_domain_name]

  comment             = "Redirect POC - ${var.namespace}"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true

  origin = {
    main = {
      domain_name = var.base_redirect_domain
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "main"
    viewer_protocol_policy = "allow-all"

    allowed_methods      = ["GET", "HEAD"]
    cached_methods       = ["GET", "HEAD"]
    compress             = true
    query_string         = true
    use_forwarded_values = false

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AllViewer

    lambda_function_association = {

      origin-request = {
        lambda_arn   = module.lambda_at_edge.lambda_function_qualified_arn
        include_body = false
      }
    }
  }

  viewer_certificate = {
    acm_certificate_arn      = module.acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
