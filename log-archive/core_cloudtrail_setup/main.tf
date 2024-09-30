data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "cloudtrail_organisation_trail" {
  source = "cloudposse/cloudtrail/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"
  enable_log_file_validation    = true
  name                          = var.Trailname
  include_global_service_events = true
  enabled                       = true
  is_multi_region_trail         = false
  enable_logging                = true
  is_organization_trail         = true
  #s3_key_prefix                 = "cloudtrail_logs"
  s3_bucket_name                = var.cloudtrail_log_s3_bucket
}






