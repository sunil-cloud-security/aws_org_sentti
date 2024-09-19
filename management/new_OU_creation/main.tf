# Provides a resource to create the securityOU and the Audit and Log-Archive accounts
data "aws_organizations_organization" "example" {}


resource "aws_organizations_organizational_unit" "example" {
  name      = "securityOU"
  parent_id = data.aws_organizations_organization.example.roots[0].id

}


resource "aws_organizations_account" "account" {
  name  = "Audit"
  email = "audit-sicybersecltd@gmail.com"
  iam_user_access_to_billing = "DENY"
  parent_id = aws_organizations_organizational_unit.example.id
  role_name = "OrganizationAccountAccessRole"
  tags = {
    Name  = "Audit"
    Owner = "Sunil"
    Role  = "CloudSecurity"
  }

}

resource "aws_organizations_account" "logarchive" {
  name  = "Log-Archive"
  email = "logsmanagementsicybersecltd@gmail.com"
  iam_user_access_to_billing = "DENY"
  parent_id = aws_organizations_organizational_unit.example.id
  role_name = "OrganizationAccountAccessRole"
  tags = {
    Name  = "Log-Archive"
    Owner = "Sunil"
    Role  = "CloudSecurity"
  }

}


# Provides a resource to create the TestingOU and the awsTesting account


resource "aws_organizations_organizational_unit" "testOU" {
  name      = "testOU"
  parent_id = data.aws_organizations_organization.example.roots[0].id

}

resource "aws_organizations_account" "awstest" {
  name  = "awstestaccount"
  email = "awstestaccountsicybersecltd@gmail.com"
  iam_user_access_to_billing = "DENY"
  parent_id = aws_organizations_organizational_unit.testOU.id
  role_name = "OrganizationAccountAccessRole"
  tags = {
    Name  = "awstestaccount"
    Owner = "Sunil"
    Role  = "CloudSecurity"
  }

}


