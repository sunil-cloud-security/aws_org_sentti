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
/*
#Variables to receive from the main calling module
variable "central_config_bucket_id" {
  description = "Name id of the central config S3 bucket"
  type        = string  
}


variable "central_config_bucket_arn" {
  description = "Name id of the central config S3 bucket"
  type        = string
}
*/

variable "central_config_aggregator_account_id" {
    type = string
    default = "676206902400"#audit account - Delegated Administrator
}

variable "cloudtrail_log_s3_bucket" {
  type = string
  description = "central S3 access log bucket"
}

variable "Trailname" {
  type = string
  description = "The new Org Trail name"
  default = "orgtrail"#Need to hardcode this. Need to change this later.
}






