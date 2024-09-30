
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "random_uuid" "uuid" {
}

resource "random_string" "uuid" {
  length  = 10
  special = false
  upper   = false
  
}

locals {
  logarchive = "890742580474"
  management = "288761729658"
  audit = "676206902400"
}

#S3 bucket for config logs with policy attached for config service

resource "aws_s3_bucket" "access_logs" {
  provider = aws.audit
  bucket = "${var.access-logs_config_bucket_prefix}-${random_string.uuid.result}"
  force_destroy = true
  /*lifecycle {
    prevent_destroy = true
  }
  */
  tags = {
    Name = "Config S3 Access Logs"
  }
  
}


# Create a log bucket for centralised config-logs
resource "aws_s3_bucket" "config_bucket" {
  provider = aws.audit
  bucket = "${var.central_bucket_prefix}-${random_string.uuid.result}"
  force_destroy = true
  tags = {
    Name = "Config History Logs"
  }
}

/*
variable "storage_bucket_id" {
  type = string
  description = "Bucket Name (aka ID)"
  default = aws_s3_bucket.config_bucket.id
}

variable "storage_bucket_arn" {
  type = string
  description = "Bucket ARN"
  default = aws_s3_bucket.config_bucket.id
}
*/



#send the access logs to the access_logs_ bucket




# S3 bucket Policy. This needs to be updated everytime a new account is added
resource "aws_s3_bucket_policy" "aws_config_bucket_policy" {
  provider = aws.audit
  bucket = aws_s3_bucket.config_bucket.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSConfigBucketPermissionsCheck",
            "Effect": "Allow",
            "Principal": {"AWS": "*" },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.config_bucket.id}",
            "Condition": {
                "StringEquals": {
                    "aws:PrincipalOrgID": ["o-4jsdkwq1yx"]
                }
            }
        },
        {
            "Sid": "AWSConfigBucketDelivery",
            "Effect": "Allow",
            "Principal": {"AWS": "*" },
            "Action": "s3:PutObject",
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.config_bucket.id}/config/AWSLogs/${local.audit}/Config/*",
                "arn:aws:s3:::${aws_s3_bucket.config_bucket.id}/config/AWSLogs/${local.management}/Config/*",
                "arn:aws:s3:::${aws_s3_bucket.config_bucket.id}/config/AWSLogs/${local.logarchive}/Config/*",
                "arn:aws:s3:::${aws_s3_bucket.config_bucket.id}/config/AWSLogs/${local.awstest}/Config/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:PrincipalOrgID": ["o-4jsdkwq1yx"]
                }
            }
        }
    ]
}
POLICY

}

module "aws_config" {
  source = "cloudposse/config/aws"
  providers = {
    aws = aws.audit
  }
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  # Audit AWS Account is where the central config is. From here you can access all config events
  central_resource_collector_account = "676206902400"
  # Here we add member accounts so  it can be added to the central aggregator. Need to think of management account
  child_resource_collector_accounts = toset(["288761729658"])
  create_iam_role  = true
  create_organization_aggregator_iam_role = true
  #need to add other regiosn here if possible after first time
  disabled_aggregation_regions = [
    "ap-northeast-3",
    "us-east-1"
    
  ]
  #force_destroy = true
  global_resource_collector_region = "eu-west-2"
  enabled = true
  is_organization_aggregator = true
  name = "core-config-org"
  s3_bucket_arn = aws_s3_bucket.config_bucket.arn
  s3_bucket_id = aws_s3_bucket.config_bucket.id

  s3_key_prefix = "config"
  #future need to add conformance packs and managed rules. This may be too much as we are also using Tenable, SCP and SecurityHub.
  #need to evaluate

}


module "aws_config_member" {
  source = "cloudposse/config/aws"
  providers = {
    aws = aws.logarchive
  }
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  # Audit AWS Account is where the central config is. From here you can access all config events
  central_resource_collector_account = "676206902400"
  # Here we add member accounts so  it can be added to the central aggregator. Need to think of management account
  #child_resource_collector_accounts = toset(["890742580474"])
  create_iam_role  = true
  #create_organization_aggregator_iam_role = true
  #need to add other regiosn here if possible after first time
  #disabled_aggregation_regions = [
   # "ap-northeast-3",
   # "us-east-1"
  #]
  #force_destroy = true
  global_resource_collector_region = "eu-west-2"
  enabled = true
  #is_organization_aggregator = true
  name = "core-config-org"
  #s3_bucket_arn = aws_s3_bucket.config_bucket.arn
  #s3_bucket_id = aws_s3_bucket.config_bucket.id
  s3_bucket_arn = aws_s3_bucket.config_bucket.arn
  s3_bucket_id = aws_s3_bucket.config_bucket.id
  s3_key_prefix = "config"
  #future need to add conformance packs and managed rules. This may be too much as we are also using Tenable, SCP and SecurityHub.
  #need to evaluate

}

module "aws_config_management" {
  source = "cloudposse/config/aws"
  
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  # Audit AWS Account is where the central config is. From here you can access all config events
  central_resource_collector_account = "676206902400"
  # Here we add member accounts so  it can be added to the central aggregator. Need to think of management account
  #child_resource_collector_accounts = toset(["890742580474"])
  create_iam_role  = true
  #create_organization_aggregator_iam_role = true
  #need to add other regiosn here if possible after first time
  #disabled_aggregation_regions = [
   # "ap-northeast-3",
   # "us-east-1"
  #]
  #force_destroy = true
  global_resource_collector_region = "eu-west-2"
  enabled = true
  #is_organization_aggregator = true
  name = "core-config-org"
  #s3_bucket_arn = aws_s3_bucket.config_bucket.arn
  #s3_bucket_id = aws_s3_bucket.config_bucket.id
  s3_bucket_arn = aws_s3_bucket.config_bucket.arn
  s3_bucket_id = aws_s3_bucket.config_bucket.id
  s3_key_prefix = "config"
  #future need to add conformance packs and managed rules. This may be too much as we are also using Tenable, SCP and SecurityHub.
  #need to evaluate

}