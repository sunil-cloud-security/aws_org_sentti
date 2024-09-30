# Root terragrunt hcl where
# region mostly where all the resources are built
#remote state of terraform is in an S3 bucket in the management account

# Indicate what region to deploy the resources into




locals {
  aws_role_arn               = "arn:aws:iam::288761729658:user/terragrunt"
  aws_region                 = "eu-west-2"
  aws_credentials_file       = "$HOME/.aws/credentials"
  #env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}


generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
    provider "aws" {
    #shared_credentials_file = "${pathexpand("~/.aws/credentials")}"
    profile                 = "terragrunt"
    #role_arn       = ${local.aws_role_arn}
    region                  = "${local.aws_region}" 
      }  
    EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "sicybersec-aws-org-tfstate"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.aws_region}"
    #role_arn       = "${local.aws_role_arn}"
    encrypt        = true
    dynamodb_table = "aws-org-lock-table"
  }
}

