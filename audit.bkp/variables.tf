variable "config_s3_bucket_name" {
  description = "The name of the S3 bucket to store various audit logs."
  type        = string
  default     = "aws-config-history-"
}

variable "config_s3_bucket_access_logs_name" {
  description = "The name of the S3 bucket to store various audit logs."
  type        = string
  default     = "config-access-logs-"
}


variable "member_accounts" {
  description = "A list of AWS account IDs."
  type = list(object({
    account_id = string
    email      = string
  }))

  default = [
    #logarchive account
   /* {
        account_id = "890742580474"
        email      = "logsmanagementsicybersecltd@gmail.com"
    },
    
    #awstest account
    {
        account_id = "307946680224"
        email      = "awstestaccountsicybersecltd@gmail.com"
        
    }
    */
    #management account
   /* {
        account_id = "288761729658"
        email      = "sicybersecltd@gmail.com"
        
    }
    */
    
  ]
}

variable "region" {
  description = "The AWS region in which global resources are set up."
  type        = string
  default     = "eu-west-2"
}