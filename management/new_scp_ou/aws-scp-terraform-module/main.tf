data "aws_iam_policy_document" "scp_policy" {

  
  #aws regions Policies

dynamic "statement" {
    for_each = local.deny_aws_regions_access
    content {
      not_actions = [
                "a4b:*",
                "acm:*",
                "aws-marketplace-management:*",
                "aws-marketplace:*",
                "aws-portal:*",
                "awsbillingconsole:*",
                "budgets:*",
                "ce:*",
                "chime:*",
                "cloudfront:*",
                "config:*",
                "cur:*",
                "directconnect:*",
                "ec2:DescribeRegions",
                "ec2:DescribeTransitGateways",
                "ec2:DescribeVpnGateways",
                "fms:*",
                "globalaccelerator:*",
                "health:*",
                "iam:*",
                "importexport:*",
                "kms:*",
                "mobileanalytics:*",
                "networkmanager:*",
                "organizations:*",
                "pricing:*",
                "route53:*",
                "route53domains:*",
                "s3:GetAccountPublic*",
                "s3:ListAllMyBuckets",
                "s3:PutAccountPublic*",
                "shield:*",
                "sts:*",
                "support:*",
                "trustedadvisor:*",
                "waf-regional:*",
                "waf:*",
                "wafv2:*",
                "wellarchitected:*"
            ]
      resources = ["*"]
      effect    = "Deny"
      condition {
        test     = "StringNotEquals"
        variable = "aws:RequestedRegion"
        values = [
          "eu-west-2",
          "eu-north-1"
        ]
      }
      
      
    }
}

  dynamic "statement" {
    for_each = local.deny_aws_regions_actions_IAMRole
    content {
      actions = [
        "account:EnableRegion",
        "account:DisableRegion"
      ]
      resources = ["*"]
      effect    = "Deny"
      condition {
        test     = "StringNotEquals"
        variable = "aws:PrincipalARN"
        values = [
          "arn:aws:iam::*:role/OrganizationAccountAccessRole"
        ]
      }
    }
  }
  
  # Root account access
  dynamic "statement" {
    for_each = local.deny_root_account_access_statement
    content {
      actions   = ["*"]
      resources = ["*"]
      effect    = "Deny"
      condition {
        test     = "StringLike"
        variable = "aws:PrincipalArn"
        values   = ["arn:aws:iam::*:root"]
      }
    }
  }

  # IAM users and access keys deny Policy with an exception for an IAM Role
  dynamic "statement" {
    for_each = local.deny_iam_users_access_keys_creation
    content {
      actions = [
                "iam:CreateUser",
                "iam:CreateAccessKey"
            ]
      resources = ["*"]
      effect = "Deny"
      condition {
        test     = "StringNotEquals"
        variable = "aws:PrincipalARN"
        values = [
          "arn:aws:iam::*:role/OrganizationAccountAccessRole"
        ]
      }
      
    }
  }


  # IAM Role - Deny Changes to IAM roles in each account. This gives us security to not change the OrganizationAccountAccessRole
    dynamic "statement" {
        for_each = local.deny_key_iam_roles_deletion
        content {
          actions = [
                "iam:AttachRolePolicy",
                "iam:DeleteRole",
                "iam:DeleteRolePermissionsBoundary",
                "iam:DeleteRolePolicy",
                "iam:DetachRolePolicy",
                "iam:PutRolePermissionsBoundary",
                "iam:PutRolePolicy",
                "iam:UpdateAssumeRolePolicy",
                "iam:UpdateRole",
                "iam:UpdateRoleDescription"
            ]
          resources = [
                "arn:aws:iam::*:role/OrganizationAccountAccessRole",
                "arn:aws:iam::*:role/core-config-org-config",
                "arn:aws:iam::*:role/core-config-org-aggregator-config",
                "arn:aws:iam::*:role/aws-service-role/*"
            ]
            effect = "Deny"         
          
        }
  }

  #VPN Gateway changes
  dynamic "statement" {
    for_each = local.deny_vpn_gateway_changes_statement
    content {
      effect = "Deny"
      actions = [
        "ec2:DetachVpnGateway",
        "ec2:AttachVpnGateway",
        "ec2:DeleteVpnGateway",
        "ec2:CreateVpnGateway"
      ]
      resources = [
        "arn:aws:ec2:*:*:vpn-gateway/*",
        "arn:aws:ec2:*:*:vpc/*"
      ]
      condition {
        test     = "StringNotEquals"
        variable = "aws:PrincipalARN"
        values = [
          "arn:aws:iam::*:role/OrganizationAccountAccessRole"
        ]
      }
    }
  }

  # Deny Network changes
  #
  dynamic "statement" {
    for_each = local.deny_vpc_changes_statement
    content {
      effect = "Deny"
      actions = [
        "ec2:DeleteFlowLogs",
        "ec2:ModifyVpc*",
        "ec2:CreateVpc*",
        "ec2:DeleteVpc*",
        "ec2:AcceptVpcPeeringConnection",
        "ec2:DisassociateVpcCidrBlock"
      ]
      resources = [
        "*"
      ]
      condition {
        test     = "ForAnyValue:ArnNotLike"
        variable = "aws:PrincipalArn"
        values = [
          "arn:aws:iam::*:role/NetworkAdmin",
        ]
      }
    }
  }

  # Config changes for core
  dynamic "statement" {
    for_each = local.deny_config_changes_statement
    content {
      effect = "Deny"
      actions = [
        "config:DeleteConfigurationRecorder",
        "config:DeleteDeliveryChannel",
        "config:DeleteRetentionConfiguration",
        "config:PutConfigurationRecorder",
        "config:PutDeliveryChannel",
        "config:PutRetentionConfiguration",
        "config:StopConfigurationRecorder"
      ]
      resources = ["*"]
      condition {
        test     = "StringNotEquals"
        variable = "aws:PrincipalARN"
        values = [
          "arn:aws:iam::*:role/OrganizationAccountAccessRole"
        ]
      }
    }
  }

  # Deny Cloud Trail changes
  dynamic "statement" {
    for_each = local.deny_cloudtrail_changes_statement
    content {
      effect = "Deny"
      actions = [
        "cloudtrail:DeleteTrail",
        "cloudtrail:UpdateTrail",
        "cloudtrail:PutEventSelectors",
        "cloudtrail:StopLogging"
      ]
      resources = ["arn:aws:cloudtrail:*:*:trail/*"]
      condition {
        test     = "StringNotEquals"
        variable = "aws:PrincipalARN"
        values = [
          "arn:aws:iam::*:role/OrganizationAccountAccessRole"
        ]
      }
    }
  }

  #Deny Disable AWS SecurityHub
  dynamic "statement" {
    for_each = local.deny_securityhub_disable_statement
    content {
      actions = [
          "securityhub:DeleteInvitations",
          "securityhub:DisableSecurityHub",
          "securityhub:DisassociateFromMasterAccount",
          "securityhub:DeleteMembers",
          "securityhub:DisassociateMembers"
      ]
      resources = ["*"]
      effect = "Deny"
        
    }
  }

  #deny marketplace subscriptions
  dynamic "statement" {
    for_each = local.deny_awsmarketplace_subcriptions
    content {
      actions = [
        "aws-marketplace:Subscribe",
        "aws-marketplace:Unsubscribe",
        "aws-marketplace:CreatePrivateMarketplace",
        "aws-marketplace:CreatePrivateMarketplaceRequests",
        "aws-marketplace:AssociateProductsWithPrivateMarketplace",
        "aws-marketplace:DisassociateProductsFromPrivateMarketplace",
        "aws-marketplace:UpdatePrivateMarketplaceSettings"
      ]
      resources = ["*"]
      effect = "Deny"
      condition {
        test     = "StringNotEquals"
        variable = "aws:PrincipalARN"
        values = [
          "arn:aws:iam::*:role/OrganizationAccountAccessRole"
        ]
      }   
      
    }
 }

}

#deny marketplace subcriptions except for Organisation role




# Generate the SCP Policy
resource "aws_organizations_policy" "scp_document" {
  name        = var.name
  description = "${var.name} : SCP generated by org-scp module"
  content     = data.aws_iam_policy_document.scp_policy.json
}

# Create the attachment for the targets
resource "aws_organizations_policy_attachment" "scp_attachment" {
  for_each  = var.targets
  policy_id = aws_organizations_policy.scp_document.id
  target_id = each.value
}
