data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_guardduty_detector" "existing" {}


module "delegated_admin" {
  source = "../../modules/terraform-aws-guardduty/modules/organizations_admin"
  auto_enable_org_config = true
  admin_account_id                 = data.aws_caller_identity.current.account_id
  auto_enable_organization_members = "ALL"
  guardduty_detector_id            = data.aws module.guardduty_detector.guardduty_detector.id
  enable_s3_protection         = false
  enable_kubernetes_protection = false
  enable_malware_protection    = false
  
}



module "guardduty_detector" {
  source = "../../modules/terraform-aws-guardduty"
  enable_guardduty = true
  publish_to_s3 = false
  #guardduty_s3_bucket = var.central-guardduty-findings-s3bucket
  enable_s3_protection         = false
  enable_kubernetes_protection = false
  enable_malware_protection    = false
  enable_snapshot_retention    = false
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  tags                         = {
     Creator = "terraform"
    Resource = "GuardDuty_Org"
    Owner = "AWS Security Team"
  }
}


  


  

