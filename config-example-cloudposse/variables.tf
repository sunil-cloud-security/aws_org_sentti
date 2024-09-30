variable "region" {
  type        = string
  description = "AWS Region"
  default = "eu-west-2"
}
variable "create_iam_role" {
  description = "Flag to indicate whether an IAM Role should be created to grant the proper permissions for AWS Config"
  type        = bool
  default     = false
}

variable "create_sns_topic" {
  description = <<-DOC
    Flag to indicate whether an SNS topic should be created for notifications
    If you want to send findings to a new SNS topic, set this to true and provide a valid configuration for subscribers
  DOC

  type    = bool
  default = false
}

variable "force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable"
  default     = true
}

variable "managed_rules" {
  description = <<-DOC
    A list of AWS Managed Rules that should be enabled on the account. 

    See the following for a list of possible rules to enable:
    https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html
  DOC
  type = map(object({
    description      = string
    identifier       = string
    input_parameters = any
    tags             = map(string)
    enabled          = bool
  }))
  default = {}
}

variable "parameter_overrides" {
  type        = map(map(string))
  description = <<-DOC
    Map of parameters for interpolation within the YAML config templates

    For example, to override the maxCredentialUsageAge parameter in the access-keys-rotated.yaml rule, you would specify
    the following:

    parameter_overrides = {
      "access-keys-rotated" : { maxCredentialUsageAge : "120" }
    }
  DOC
  default     = {}
}

variable "global_resource_collector_region" {
  description = "The region that collects AWS Config data for global resources such as IAM"
  type        = string
  default = "eu-west-2"
}

# SCP targets - i.e. the OUs in our AWS Organization
variable "ou_targets" {
  type = map(any)
  default = {
    "securityOU" = "ou-8ujb-lg3em6ua",
    "testOU" = "ou-8ujb-fxhuqsag"
  }
}

variable "access-logs_config_bucket_prefix" {
  
  type = string
  description = "prefix of the S3 bucket"
  default = "config-access-logs"
}

variable "central_bucket_prefix" {
  type = string
  description = "prefix of the S3 bucket"
  default = "config-hist-logs"
}


