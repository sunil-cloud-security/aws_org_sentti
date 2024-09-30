terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.3"
    }
    
  }
}

provider "aws" {
  region = "eu-west-2"
  alias = "audit"
  assume_role {
    role_arn = "arn:aws:iam::676206902400:role/OrganizationAccountAccessRole"
    external_id = "cross_account_terragrunt"
  }
}


provider "aws" {
  region = "eu-west-2"
  alias = "logarchive"
  assume_role {
    role_arn = "arn:aws:iam::890742580474:role/OrganizationAccountAccessRole"
    external_id = "cross_account_terragrunt"
  }
}


provider "random" {
  # Configuration options
}
