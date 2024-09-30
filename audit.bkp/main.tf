# assume audit role
locals {
  aws_role_arn               = "arn:aws:iam::676206902400:role/OrganizationAccountAccessRole"
  aws_region                 = "eu-west-2"
  external_id                = "cross_account_terragrunt_assume"
  
}


provider "aws" {
  region = local.aws_region
  alias = "audit" 
  assume_role {
    role_arn = local.aws_role_arn
    external_id = local.external_id
  }
}

#aws provider with the assumption role
/*
provider "aws" {
  region = "eu-west-2"
  alias = "logarchive"
  assume_role {
    role_arn = "arn:aws:iam::890742580474:role/OrganizationAccountAccessRole"
    external_id = "cross_account_terragrunt"
  }
}
*/

# access logs s3 bucket
resource "aws_s3_bucket" "access_logs" {
  provider = aws.audit
  bucket_prefix = "conf-logs-"
  force_destroy = true
  /*lifecycle {
    prevent_destroy = true
  }
  */
  
}

# config history S3 buckets logs s3
resource "aws_s3_bucket" "config_logs" {
  provider = aws.audit
  bucket_prefix = "conf-hist-"
  force_destroy = true
  /*lifecycle {
    prevent_destroy = true
  }
  */
  
}






#configure config in the audit account
module "secure_baseline" {
  source = "../modules/terraform-aws-secure-baseline"  
  account_type                         = "master"
  #member_accounts                      = var.member_accounts
  audit_log_bucket_name                = aws_s3_bucket.config_logs.id
  audit_log_bucket_access_logs_name    = aws_s3_bucket.access_logs.id
  aws_account_id                       = "676206902400"
  region                               = var.region
  support_iam_role_principal_arns      = [
    #"arn:aws:iam::676206902400:role/config-for-organization-role20240922072211362300000001", 
    #"arn:aws:iam::676206902400:role/config-for-organization-role20240922072211362300000001",
    "arn:aws:iam::676206902400:role/aws-service-role/config-multiaccountsetup.amazonaws.com/AWSServiceRoleForConfigMultiAccountSetup"#audit role
    #"arn:aws:iam::288761729658:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig",
    #"arn:aws:iam::288761729658:role/OrganizationAccountAccessRole"#management role
    #"arn:aws:iam::890742580474:role/OrganizationAccountAccessRole"#log archive role
  ]
  config_baseline_enabled = true
  config_global_resources_all_regions = true
  audit_log_lifecycle_glacier_transition_days = "0"
  vpc_enable = false
  vpc_changes_enabled = false
  cloudtrail_baseline_enabled = false
  guardduty_enabled = false
  securityhub_enabled = false
  analyzer_baseline_enabled = false
  iam_baseline_enabled = false
  s3_baseline_enabled = true
  alarm_baseline_enabled = false
  no_mfa_console_signin_enabled = false
  aws_config_changes_enabled = false
  iam_changes_enabled = false

  
  target_regions = ["eu-west-2"]
  #guardduty_disable_email_notification = true

  # Setting it to true means all audit logs are automatically deleted
  #   when you run `terraform destroy`.
  # Note that it might be inappropriate for highly secured environment.
  audit_log_bucket_force_destroy = true

  
  providers = {
    aws = aws.audit
    aws.ap-northeast-1 = aws.ap-northeast-1
    aws.ap-northeast-2 = aws.ap-northeast-2
    aws.ap-northeast-3 = aws.ap-northeast-3
    aws.eu-west-1      = aws.eu-west-1
    aws.eu-west-2      = aws.eu-west-2
    aws.eu-west-3      = aws.eu-west-3
    aws.ap-south-1     = aws.ap-south-1
    aws.ap-southeast-1 = aws.ap-southeast-1
    aws.ap-southeast-2 = aws.ap-southeast-2
    aws.us-east-1      = aws.us-east-1
    aws.us-east-2      = aws.us-east-2
    aws.us-west-1      = aws.us-west-1
    aws.us-west-2      = aws.us-west-2
    aws.ca-central-1   = aws.ca-central-1
    aws.eu-central-1   = aws.eu-central-1
    aws.eu-north-1     = aws.eu-north-1
    aws.sa-east-1      = aws.sa-east-1    
  }
  
}
