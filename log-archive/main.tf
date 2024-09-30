#main calling function
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


module "core_config_s3_audit" {
  providers = {
      aws = aws.audit
    }
  source = "./core_s3_bucket_config"
  access_log_s3_bucket = module.create_core_s3_logarchive.central_accesslogs_bucket_id

}

module "create_core_s3_logarchive" {
    providers = {
      aws = aws.audit
      
    }
  source = "./core_s3_buckets_logarchive"
  central-config-history = module.core_config_s3_audit.central_config_bucket_id
   
  }

  

  module "create_core_s3_config_aggregator" {
    providers = {
      aws = aws.audit
    }
    source = "./core_config_Org_Aggregator_setup"
    #Variables to receive from the main calling module
      central_config_bucket_id = module.core_config_s3_audit.central_config_bucket_id

      central_config_bucket_arn = module.core_config_s3_audit.central_config_bucket_arn

      central_config_bucket_name = module.core_config_s3_audit.central_config_bucket_name

         
  }

  
  module "create_organisation_trail" {
    source = "./core_cloudtrail_setup"
    #Variables to receive from the main calling module
      cloudtrail_log_s3_bucket = module.create_core_s3_logarchive.central_cloudtrail_bucket_id      
  }
  

  module "create_config_new_account" {
    source = "./new_account_config_setup"
    #Variables to receive from the main calling module
    central_config_bucket_id = module.core_config_s3_audit.central_config_bucket_id

    central_config_bucket_arn = module.core_config_s3_audit.central_config_bucket_arn

    central_config_bucket_name = module.core_config_s3_audit.central_config_bucket_name
         
}

locals {
  guardduty_features = {
  s3 = {
    auto_enable = "ALL"
    name        = "S3_DATA_EVENTS"
  }
  eks = {
    auto_enable = "NONE"
    name        = "EKS_AUDIT_LOGS"
  }
  eks_runtime_monitoring = {
    # EKS_RUNTIME_MONITORING is deprecated and should thus be explicitly disabled
    auto_enable = "NONE"
    name        = "EKS_RUNTIME_MONITORING"
    additional_configuration = [
      {
        auto_enable = "NONE"
        name        = "EKS_ADDON_MANAGEMENT"
      },
    ]
  }
  runtime_monitoring = {
    auto_enable = "NONE"
    name        = "RUNTIME_MONITORING"
    additional_configuration = [
      {
        auto_enable = "NONE"
        name        = "EKS_ADDON_MANAGEMENT"
      },
      {
        auto_enable = "NONE"
        name        = "ECS_FARGATE_AGENT_MANAGEMENT"
      },
      {
        auto_enable = "NONE"
        name        = "EC2_AGENT_MANAGEMENT"
      }
    ]
  }
  malware = {
    auto_enable = "NONE"
    name        = "EBS_MALWARE_PROTECTION"
  }
  rds = {
    auto_enable = "NONE"
    name        = "RDS_LOGIN_EVENTS"
  }
  lambda = {
    auto_enable = "NONE"
    name        = "LAMBDA_NETWORK_LOGS"
  }
}

}

data "aws_caller_identity" "audit" {
  provider = aws.audit
}


resource "aws_guardduty_detector" "audit" {
  provider = aws.audit
}

resource "aws_guardduty_organization_admin_account" "this" {
  #provider         = aws.management
  admin_account_id = data.aws_caller_identity.audit.account_id
  depends_on       = [aws_guardduty_detector.audit]
}

resource "aws_guardduty_organization_configuration" "this" {
  provider                         = aws.audit
  auto_enable_organization_members = "ALL"
  detector_id                      = aws_guardduty_detector.audit.id
  depends_on                       = [aws_guardduty_organization_admin_account.this]
}

resource "aws_guardduty_organization_configuration_feature" "this" {
  provider    = aws.audit
  for_each    = local.guardduty_features
  auto_enable = each.value.auto_enable
  detector_id = aws_guardduty_detector.audit.id
  name        = each.value.name
  dynamic "additional_configuration" {
    for_each = try(each.value.additional_configuration, [])
    content {
      auto_enable = additional_configuration.value.auto_enable
      name        = additional_configuration.value.name
    }
  }
  depends_on = [aws_guardduty_organization_admin_account.this]
}


resource "aws_guardduty_detector_feature" "audit" {
  provider    = aws.audit
  for_each    = local.guardduty_features
  detector_id = aws_guardduty_detector.audit.id
  name        = each.value.name
  status      = each.value.auto_enable == "NONE" ? "DISABLED" : "ENABLED"
  dynamic "additional_configuration" {
    for_each = try(each.value.additional_configuration, [])
    content {
      status = additional_configuration.value.auto_enable == "NONE" ? "DISABLED" : "ENABLED"
      name   = additional_configuration.value.name
    }
  }
}



/*

module "create_GD_org_Detector" {
  providers = {
      aws = aws.audit
    }
  source = "./enable_GuardDuty_Org"
  central-guardduty-findings-s3bucket = module.create_core_s3_logarchive.central_cloudtrail_bucket_id  
}
*/








  

