variable "central-config-history" {
  type = string
  description = "central S3 bucket which collects config history logs for all Accounts in the AWS Organisation"
  default = "central-config-history-"
}

variable "access_log_s3_bucket" {
  type = string
  description = "central S3 access log bucket"
}






