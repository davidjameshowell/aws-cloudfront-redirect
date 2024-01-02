module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name      = "redirect-hosts"
  hash_key  = "hostname"

  attributes = [
    {
      name = "hostname"
      type = "S"
    }
  ]

  tags = {
    Terraform   = "true"
  }
}
