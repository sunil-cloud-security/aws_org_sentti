variable "access-logs_config_bucket_prefix" {
  
  type = string
  description = "prefix of the S3 bucket"
  default = "config-access_logs"
}

variable "central_bucket_prefix" {
  
  type = string
  description = "prefix of the S3 bucket"
  default = "config-hist-logs"
}

variable "config_role_name" {
  description = "Name of Config Role"
  default = "ConfigRecorderRole"
}
variable "org_config_role_name" {
  description = "Name of Organization Config Role"
  default = "OrganizationConfigRole"
}

variable "org_aggregator_name" {
  description = "Name of Config Aggregator"
  default = "organization-aggregator"
}