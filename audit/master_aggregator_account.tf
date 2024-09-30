#Deploy in the audit account where the Central S3 bucket will reside and the delegated role for Config service. 

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_iam_session_context" "current" {}

locals {
  audit = "676206902400"
}

provider "aws" {
  region = "eu-west-2"
  alias = "audit"
  assume_role {
    role_arn = "arn:aws:iam::676206902400:role/OrganizationAccountAccessRole"
    external_id = "cross_account_terragrunt"
  }
}



#S3 bucket for config logs with policy attached for config service

resource "aws_s3_bucket" "access_logs" {
  provider = aws.audit
  bucket = "${var.access-logs_config_bucket_prefix}-${data.aws_caller_identity.current.account_id}"
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
  bucket = "${var.central_bucket_prefix}-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name = "Config History Logs"
  }
}

# S3 bucket Policy. This needs to be updaetd everytime a new account is added
resource "aws_s3_bucket_policy" "aws_config_bucket_policy" {

  bucket = aws_s3_bucket.config_bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSConfigBucketPermissionsCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.config_bucket.id}"
        },
        {
            "Sid": "AWSConfigBucketDelivery",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.config_bucket.id}/AWSLogs/${local.audit}/Config/*",
                "arn:aws:s3:::${aws_s3_bucket.config_bucket.id}/AWSLogs/${local.management}/Config/*",
                "arn:aws:s3:::${aws_s3_bucket.config_bucket.id}/AWSLogs/${local.awstest}/Config/*"
            ],
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

#actual recorder in that account
resource "aws_iam_service_linked_role" "aws_config" {
  aws_service_name = "config.amazonaws.com"
}

resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "config-recorder"
  role_arn = aws_iam_service_linked_role.aws_config.arn
}

resource "aws_config_delivery_channel" "config_delivery_channel" {
  name           = "config"
  s3_bucket_name = aws_s3_bucket.config_bucket.id
  #sns_topic_arn  = var.your_sns_topic_arn # optional
  depends_on     = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_configuration_recorder_status" "demo_recorder_status" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config_delivery_channel]
}


#examples of config rules to be applied
resource "aws_config_config_rule" "vpc_default_security_group_closed" {
  name = "vpc-default-security-group-closed"
  source {
    owner             = "AWS"
    source_identifier = "VPC_DEFAULT_SECURITY_GROUP_CLOSED"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::SecurityGroup"]
  }
}

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name                        = "s3-bucket-public-read-prohibited"
  maximum_execution_frequency = "TwentyFour_Hours"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
  }
}


# -----------------------------------------------------------
# set up a role for the Configuration Recorder to use
# -----------------------------------------------------------

resource "aws_iam_role_policy_attachment" "config_org_policy_attach" {
  role       = aws_iam_role.config_org_role
  policy_arn = aws_iam_policy.config_org_policy.arn
}

resource "aws_iam_role_policy_attachment" "config_policy_attach" {
  role       = aws_iam_role.config_org_role
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_iam_role_policy_attachment" "read_only_policy_attach" {
  role       = aws_iam_role.config_org_role
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_policy" "config_org_policy" {
  path        = "/"
  description = "IAM Policy for AWS Config Aggregator"
  name        = "AggregatorConfigPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "config:GetOrganizationConfigRuleDetailedStatus",
        "config:Put*",
        "iam:GetPasswordPolicy",
        "organizations:ListAccounts",
        "organizations:DescribeOrganization",
        "organizations:ListAWSServiceAccessForOrganization",
        "organization:EnableAWSServiceAccess"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
       "Effect": "Allow",
       "Action": ["s3:PutObject"],
       "Resource": ["arn:${data.aws_partition.current.partition}:s3:::config-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"],
       "Condition":
        {
          "StringLike":
            {
              "s3:x-amz-acl": "bucket-owner-full-control"
            }
        }
     },
     {
       "Effect": "Allow",
       "Action": ["s3:GetBucketAcl"],
       "Resource": "arn:${data.aws_partition.current.partition}:s3:::config-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
     }
  ]
}
EOF
}

resource "aws_iam_role" "config_org_role" {
  name = var.org_config_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# -----------------------------------------------------------
# set up the Config Aggregator
# -----------------------------------------------------------
resource "aws_config_configuration_aggregator" "organization" {
  name = var.org_aggregator_name

  organization_aggregation_source {
    all_regions = true
    role_arn    = aws.iam.role.config_org_role.arn
  }
}