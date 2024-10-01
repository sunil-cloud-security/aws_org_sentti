#
# Creating SCPs for the awstest environment

# Provides a resource to create the securityOU and the Audit and Log-Archive accounts

# Get the existing OU or Account to apply the combined SCPs
data "aws_organizations_organization" "org" {}

data "aws_organizations_organizational_unit" "ou" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
  name      = "testOU"
}



#
# Creating SCPs for the Production environment
#
module "aws-scp-terraform-module" {
  source  = "./aws-scp-terraform-module"
  targets = toset([var.ou_targets.testOU])
  #targets = "ou-8ujb-fxhuqsag"
  name    = "testOU"

  deny_root_account_access                = true
  deny_vpn_gateway_changes                = true
  deny_vpc_changes                        = true
  deny_config_changes                     = true
  deny_cloudtrail_changes                 = true
  disable_securityhub_changes             = true
  deny_aws_regions_access                 = true
  deny_aws_regions_actions_IAMRole        = true
  deny_iam_users_and_access_keys_creation = true
  deny_key_iam_roles_deletion             = true


}