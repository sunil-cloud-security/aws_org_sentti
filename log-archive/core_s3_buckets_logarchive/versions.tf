#this is needed in all modules to avoid the warning from terraform. Perhaps put this in a version.tf file in the module.
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}


