# Praceholder for anything common to top level root Org
data "aws_organizations_organization" "example" {}

#config is delegated to the Audit account
resource "aws_organizations_delegated_administrator" "config" {
  account_id        = "676206902400" # DELEGATED ADMIN ACCOUNT ID
  service_principal = "config.amazonaws.com"

}

resource "aws_organizations_delegated_administrator" "multiaccountsetupconfig" {
  account_id        = "676206902400" # DELEGATED ADMIN ACCOUNT ID
  service_principal = "config-multiaccountsetup.amazonaws.com"
  
}

resource "aws_organizations_delegated_administrator" "cloudtrail" {
  account_id        = "676206902400" # DELEGATED ADMIN ACCOUNT ID
  service_principal = "cloudtrail.amazonaws.com"
}

/*

# Administrator account delegation
resource "aws_securityhub_organization_admin_account" "this" {
  depends_on = [data.aws_organizations_organization.example]

  admin_account_id = "676206902400"
}



# Administrator account delegation - GuardDuty
resource "aws_guardduty_organization_admin_account" "this" {
  depends_on = [data.aws_organizations_organization.example]

  admin_account_id = "890742580474"
}
*/








