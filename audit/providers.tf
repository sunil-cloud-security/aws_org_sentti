# The default provider configuration; resources that begin with `aws_` will use
# it as the default, and it can be referenced as `aws`.
provider "aws" {
  region = "eu-west-2"
}

# Additional provider configuration for west coast region; resources can
# reference this as `aws.west`.
provider "aws" {
  region = "eu-west-2"
  alias = "audit"
  assume_role {
    role_arn = "arn:aws:iam::676206902400:role/OrganizationAccountAccessRole"
    external_id = "cross_account_terragrunt"
  }
}