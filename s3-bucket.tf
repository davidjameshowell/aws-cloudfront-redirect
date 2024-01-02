module "s3_redirect_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "dominaname-redirect-bucket"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = false
  }
}

module "s3_notifications" {
  source = "github.com/terraform-aws-modules/terraform-aws-s3-bucket///modules/notification"

  bucket = module.s3_redirect_bucket.s3_bucket_id

  eventbridge = true

  lambda_notifications = {
    csvlambda = {
      function_arn  = module.csv_lambda.lambda_function_arn
      function_name = module.csv_lambda.lambda_function_name
      events        = ["s3:ObjectCreated:Put"]
    }
  }
}