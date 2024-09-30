# Provides a resource to create an AWS organization.
# set the services that we want to enable
# enable policy types
resource "aws_organizations_organization" "new-org" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "config-multiaccountsetup.amazonaws.com",
    "account.amazonaws.com",
    "member.org.stacksets.cloudformation.amazonaws.com",
    "controltower.amazonaws.com",
    #"guardduty.amazonaws.com",
    "health.amazonaws.com",
    "inspector2.amazonaws.com",
    #"securityhub.amazonaws.com",
    "servicecatalog.amazonaws.com",
    "sso.amazonaws.com",
    "ssm.amazonaws.com",
    "tagpolicies.tag.amazonaws.com",
  ]
  
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY",
  ]
  
  feature_set = "ALL"
}



