variable "central-access-logs" {
  
  type = string
  description = "central S3 bucket which collects access logs for all S3 buckets in Log Archive which are defined below"
  default = "central-bucket-access-logs"
}

variable "central-cloudtrail-logs" {
  
  type = string
  description = "central S3 bucket which collects Cloudtrail for all Accounts in the AWS Organisation using an Organisation Trail"
  default = "central-cloudtrail-logs-"
}

variable "central-guardduty-findings" {
  
  type = string
  description = "central S3 bucket which has all the GuardDuty findings sent to it"
  default = "central-guardyduty-findings-"
}

variable "central-config-history" {
  
  type = string
  description = "central Config history S3 bucket"
  
}

variable "org_id" {
  type = string
  description = "Actual Value of the new AWS Org ID"
  default = "o-4jsdkwq1yx"#Need to hardcode this. Need to change this later.
}
variable "Trailname" {
  type = string
  description = "The new Org Trail name"
  default = "orgtrail"#Need to hardcode this. Need to change this later.
}

variable "management_account_id" {
  type = string
  description = "The new Org Trail name will always be deployed in the management account and not the delegated admin account"
  default = "288761729658"
  #Need to hardcode this. Need to change this later.
}










