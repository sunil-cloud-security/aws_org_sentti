# Indicate where to source the terraform module from.
# The URL used here is a shorthand for
# "tfr://registry.terraform.io/terraform-aws-modules/vpc/aws?version=5.8.1".
# Note the extra `/` after the protocol is required for the shorthand
# notation.
include "root" {
  path = find_in_parent_folders("../terragrunt.hcl")
  expose = true
  merge_strategy = "deep"
}




