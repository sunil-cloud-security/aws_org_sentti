variable "name" {
  description = "SCP name"
  type        = string
}

variable "targets" {
  description = "Lits of OU and account id's to attach SCP"
  type        = set(string)
  default     = []
}


# SCP rule toggles

#aws regions policies
variable "deny_aws_regions_access" {
  description = "Deny usage of AWS regions except eu-west-2"
  default     = false
  type        = bool
}

variable "deny_aws_regions_actions_IAMRole" {
  description = "restricts users from enabling/disabling AWS regions except if the change was being done by that specified role"
  default     = false
  type        = bool
}

#IAM Policies

variable "deny_root_account_access" {
  description = "Deny usage of AWS account root"
  default     = false
  type        = bool
}

variable "deny_iam_users_and_access_keys_creation" {
  description = "restricts IAM principals from creating new IAM users or IAM Access Keys in an AWS account except for a special IAM role"
  default     = false
  type        = bool
}

variable "deny_key_iam_roles_deletion" {
  description = "restricts IAM principals in accounts from making changes to an IAM role created in an AWS account (This could be a common administrative IAM role created in all accounts in your organization"
  default     = false
  type        = bool
}

variable "deny_vpn_gateway_changes" {
  description = "Deny changes to VPN gateways"
  default     = false
  type        = bool
}

variable "deny_vpc_changes" {
  description = "Deny VPC related changes"
  default     = false
  type        = bool
}

variable "deny_config_changes" {
  description = "Deny AWS Config related changes"
  default     = false
  type        = bool
}

variable "deny_cloudtrail_changes" {
  description = "Deny AWS CloudTrail related changes"
  default     = false
  type        = bool
}

variable "disable_securityhub_changes" {
  description = "Disable AWS securityhub in any account"
  default     = false
  type        = bool
}

variable "deny_awsmarketplace_subcriptions" {
  description = "Disable AWS securityhub in any account"
  default     = false
  type        = bool
}

