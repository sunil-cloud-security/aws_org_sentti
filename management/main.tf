# Praceholder for anything common to top level root Org
#delegate administration to the config, cloudtrail and guardduty to the audit account

# Provides a resource to create the securityOU and the Audit and Log-Archive accounts
data "aws_organizations_organization" "example" {}



/*
resource "aws_organizations_delegated_administrator" "config" {
  account_id        = "676206902400" # DELEGATED ADMIN ACCOUNT ID
  service_principal = "config.amazonaws.com"
}


resource "aws_organizations_delegated_administrator" "cloudtrail" {
  account_id        = "676206902400" # DELEGATED ADMIN ACCOUNT ID
  service_principal = "cloudtrail.amazonaws.com"
}
*/

/*
# Administrator account delegation
resource "aws_securityhub_organization_admin_account" "this" {
  depends_on = [aws_organizations_organization.example]

  admin_account_id = "676206902400"
}


# Administrator account delegation - GuardDuty
resource "aws_guardduty_organization_admin_account" "this" {
  depends_on = [aws_organizations_organization.example]

  admin_account_id = "676206902400"
}
*/

# Create S3 buckets in the Audit Account and attach a Policy to it

# Create S3 bucket for aws config logs to be sent to a centralised bucket in Audit Account
