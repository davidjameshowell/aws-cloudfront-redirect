variable "cloudfront_domain_name" {
  description = "The domain name to use for the redirect"
  type        = string

  validation {
    condition     = can(regex("^([a-zA-Z0-9-]+)(\\.[a-zA-Z0-9-]+)*\\.[a-zA-Z]{2,}[^\\/]$", var.cloudfront_domain_name))
    error_message = "Domain name must be lowercase alphanumeric characters or hyphens, without protocol or trailing slash"
  }
}

variable "base_redirect_domain" {
  description = "The domain name to use for the CloudFront origin"
  type        = string

  validation {
    condition     = can(regex("^([a-zA-Z0-9-]+)(\\.[a-zA-Z0-9-]+)*\\.[a-zA-Z]{2,}[^\\/]$", var.base_redirect_domain))
    error_message = "Domain name must be lowercase alphanumeric characters or hyphens, without protocol or trailing slash"
  }
}

variable "namespace" {
  description = "The namespace to use for the redirect"
  type        = string

  # validation {
  #     condition     = can(regex("^(?!xn--|sthree-|sthree-configurator)[a-z0-9](?!.*\\.\\.)(?!.*192\\.168\\.)(?!.*--ol-s3$)([a-z0-9.\\-]{1,61}[a-z0-9])?$", var.namespace))
  #     error_message = "Namespace must confirm to S3 bucket naming specifications https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html#general-purpose-bucket-names"
  # }
}

variable "hostnames_files" {
  description = "The name of the file containing the hostnames to redirect"
  type        = string
  default     = "redirects"
}
