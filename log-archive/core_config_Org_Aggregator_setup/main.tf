data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# local values of core_aws_accounts
locals {
  aws_account_ids = toset([
    "288761729658",#management
    "676206902400",#audit
    "890742580474",#logarchive
  ])
}

# Central Config History Access S3 bucket_policy. All AWS Accounts send their Config logs here
resource "aws_s3_bucket_policy" "config_cross_account_policy" {
    bucket = var.central_config_bucket_name
    policy = data.aws_iam_policy_document.allow_config_access_from_accounts.json
}

# Config logging policy attached to the config log bucket
data "aws_iam_policy_document" "allow_config_access_from_accounts" {
    
    dynamic "statement" {
        for_each = local.aws_account_ids
        content {
            actions   = ["s3:GetBucketAcl","s3:ListBucket"]
            effect    = "Allow"
            resources = [
                "arn:aws:s3:::${var.central_config_bucket_id}",
            ]
            principals {
                type = "AWS"
                identifiers = ["*"]
            }
            condition {
                test     = "StringEquals"
                variable = "aws:PrincipalOrgID"
                values   = ["o-4jsdkwq1yx"]               
            }
        }
    }

    dynamic "statement" {
        for_each = local.aws_account_ids
        content {
            actions   = ["s3:PutObject"]
            effect    = "Allow"
            resources = [
                "arn:aws:s3:::${var.central_config_bucket_id}/config/AWSLogs/${statement.value}/Config/*",
            ]
            principals {
                type = "AWS"
                identifiers = ["*"]
            }
            condition {
                test     = "StringEquals"
                variable = "aws:PrincipalOrgID"
                values   = ["o-4jsdkwq1yx"]               
            }
            

        }
    }

}  

module "aws_config" {
  source = "cloudposse/config/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  # Audit AWS Account is where the central config is. From here you can access all config events
  #central_resource_collector_account = "676206902400"
  central_resource_collector_account = var.central_config_aggregator_account_id

  # Here we add member accounts so  it can be added to the central aggregator. Need to think of management account
  #child_resource_collector_accounts = toset(["${data.aws_caller_identity.current.account_id}"])
  create_iam_role  = true
  create_organization_aggregator_iam_role = true
  #need to add other regiosn here if possible after first time
  disabled_aggregation_regions = [
    "ap-northeast-3",
    "us-east-1"
  ]
  
  global_resource_collector_region = var.global_resource_collector_region
  enabled = true
  is_organization_aggregator = true
  name = "core-config-org"
  s3_bucket_arn = var.central_config_bucket_arn
  s3_bucket_id = var.central_config_bucket_id

  s3_key_prefix = "config"
  #future need to add conformance packs and managed rules. This may be too much as we are also using Tenable, SCP and SecurityHub.
  #need to evaluate

}


