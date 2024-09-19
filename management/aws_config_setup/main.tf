#
# Creating SCPs for the awstest environment
#aws provider with the assumption role

provider "aws" {
  region = "eu-west-2"
  alias = "logarchive"
  assume_role {
    role_arn = "arn:aws:iam::890742580474:role/OrganizationAccountAccessRole"
    external_id = "cross_account_terragrunt"
  }
}

# Provides a resource to create the securityOU and the Audit and Log-Archive accounts

# Get the existing OU or Account to apply the combined SCPs
data "aws_organizations_organization" "org" {}

data "aws_organizations_organizational_unit" "ou" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
  name      = "testOU"
}

resource "aws_organizations_delegated_administrator" "config" {
  account_id        = "676206902400" # DELEGATED ADMIN ACCOUNT ID
  service_principal = "config.amazonaws.com"
}


data "aws_s3_bucket" config_bucket {
  bucket = "aws-config-logs20240917145042022500000001"
  provider = aws.logarchive
}


resource "aws_iam_service_linked_role" "config_recorder" {
  aws_service_name = "config.amazonaws.com"
  provider = aws.logarchive
}

resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "config-recorder"
  role_arn = aws_iam_service_linked_role.config_recorder.arn
  provider = aws.logarchive

  recording_group {
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "config_recorder_delivery_channel" {
  provider = aws.logarchive
  depends_on = [aws_config_configuration_recorder.config_recorder]

  name           = "config-delivery-channel"
  s3_bucket_name = data.aws_s3_bucket.config_bucket.id
  #sns_topic_arn  = aws_sns_topic.config_recorder.arn

  snapshot_delivery_properties {
    delivery_frequency = "TwentyFour_Hours"
  }
}


resource "aws_s3_bucket_policy" "config" {
  provider = aws.logarchive
  bucket = data.aws_s3_bucket.config_bucket.id
  policy = data.aws_iam_policy_document.config_recorder.json
}

/*
resource "aws_sns_topic" "config_recorder" {
  provider = aws.logarchive
  name = "config-recorder"
}
*/

data "aws_iam_policy_document" "config_recorder" {
  provider = aws.logarchive
  statement {
    sid = "DenyUnsecuredTransport"
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    condition {
      test = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "true",
      ]
    }

    principals {
      type        = "Service"
      identifiers = [aws_iam_service_linked_role.config_recorder.aws_service_name]
    }

    resources = [
      data.aws_s3_bucket.config_bucket.arn,
      "${data.aws_s3_bucket.config_bucket.arn}/*",
    ]
  }
}






/*

module "aws_config" {
  source = "../../modules/terraform-aws-config"
  providers = {
    aws = aws.logarchive
  }
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  # Audit AWS Account is where the central config is. From here you can access all config events
  central_resource_collector_account = "676206902400"
  # Here we add member accounts so  it can be added to the central aggregator. Need to think of management account
  child_resource_collector_accounts = toset(["890742580474", "307946680224", "288761729658"])
  create_iam_role  = true
  create_organization_aggregator_iam_role = true
  #need to add other regiosn here if possible after first time
  disabled_aggregation_regions = [
    "ap-northeast-3",
    "us-east-1"
  ]
  force_destroy = true
  global_resource_collector_region = "eu-west-2"
  enabled = true
  is_organization_aggregator = true
  name = "core-config-org"
  #namespace = "sen"
  s3_bucket_arn = data.aws_s3_bucket.config_bucket.arn
  s3_bucket_id = data.aws_s3_bucket.config_bucket.id
  s3_key_prefix = "confighistory"
  #future need to add conformance packs and managed rules. This may be too much as we are also using Tenable, SCP and SecurityHub.
  #need to evaluate

}
*/

  
