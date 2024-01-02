provider "aws" {
    alias = "ue1"
    region = "us-east-1"
}

module "lambda_at_edge" {
  source = "terraform-aws-modules/lambda/aws"

  lambda_at_edge = true

  function_name = "lambda-at-edge-redirect"
  description   = "DDB redirect"
  handler       = "index.lambda_handler"
  runtime       = "python3.12"

  source_path = "./redirect-lambda-edge"

  tags = {
    Module = "lambda-at-edge"
  }

  providers = {
    aws = aws.ue1 
  }
}

# attach DynamoDB read only policy to lambda
resource "aws_iam_role_policy_attachment" "ddb_read_only" {
  role       = module.lambda_at_edge.lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}
