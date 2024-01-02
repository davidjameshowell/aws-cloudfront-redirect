module "csv_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  lambda_at_edge = false

  function_name = "process-csv-s3"
  description   = "CSV process"
  handler       = "index.lambda_handler"
  runtime       = "python3.12"

  source_path = "./python-lambda-csv"

  tags = {
    Module = "lambda-at-edge"
  }
}

# attach dynamodb full access policy to lambda
resource "aws_iam_role_policy_attachment" "ddb_full_access" {
  role       = module.csv_lambda.lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# attach s3 read only access policy to lambda
resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = module.csv_lambda.lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
