provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  providers = {
    aws = aws.us-east-1
  }

  domain_name            = var.cloudfront_domain_name
  create_route53_records = false

  validation_method    = "DNS"
  validate_certificate = false
}
