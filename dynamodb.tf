module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name      = "${var.namespace}-redirect-hosts"
  hash_key  = "hostname"
  range_key = "hostname_path"

  attributes = [
    {
      name = "hostname"
      type = "S"
    },
    {
      name = "hostname_path"
      type = "S"
    },

  ]

  tags = {
    Terraform = "true"
  }
}
