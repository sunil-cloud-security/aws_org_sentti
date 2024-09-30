
data "aws_caller_identity" "current" {}


#install config in the management account
module "aws_config_management" {
  source = "cloudposse/config/aws"
  
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  central_resource_collector_account = var.central_config_aggregator_account_id
  child_resource_collector_accounts = toset(["${data.aws_caller_identity.current.account_id}"])
  create_iam_role  = true
  global_resource_collector_region = "eu-west-2"
  enabled = true
  #is_organization_aggregator = true
  name = "core-config-org"
  s3_bucket_arn = var.central_config_bucket_arn
  s3_bucket_id = var.central_config_bucket_id
  s3_key_prefix = "config"
  #future need to add conformance packs and managed rules. This may be too much as we are also using Tenable, SCP and SecurityHub.
  #need to evaluate

}

