locals {

  deny_aws_regions_access                = var.deny_aws_regions_access ? [""] : []
  deny_aws_regions_actions_IAMRole       = var.deny_aws_regions_actions_IAMRole ? [""] : []
  deny_root_account_access_statement     = var.deny_root_account_access ? [""] : []
  deny_iam_users_access_keys_creation    = var.deny_iam_users_and_access_keys_creation ? [""] : []
  deny_key_iam_roles_deletion            = var.deny_key_iam_roles_deletion ? [""] : []
  deny_vpn_gateway_changes_statement     = var.deny_vpn_gateway_changes ? [""] : []
  deny_vpc_changes_statement             = var.deny_vpc_changes ? [""] : []
  deny_config_changes_statement          = var.deny_config_changes ? [""] : []
  deny_cloudtrail_changes_statement      = var.deny_cloudtrail_changes ? [""] : []
  deny_securityhub_disable_statement     = var.disable_securityhub_changes ? [""] : []
  deny_awsmarketplace_subcriptions       = var.deny_awsmarketplace_subcriptions ? [""] : []

}
