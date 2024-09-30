data "aws_caller_identity" "current" {}

module "s3_bucket_for_config_history" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = "${var.central-config-history}${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  versioning = {
    status     = true
    mfa_delete = false
  }
  
  /*
  lifecycle_rule = [
    {
      id     = "2 years with transition after 1 year and then expire in 2 years"
      enabled = true
      expiration = {
      days = 730
      #expired_object_delete_marker = true
      }
      transition = [
        {
        days          = 365
        storage_class = "STANDARD_IA"
        }
      ]
    },
  ]
      
  logging = {
    target_bucket = var.access_log_s3_bucket
    target_prefix = "access-logs/"
  }
  */

  tags = {
    Name = "${var.central-config-history}",
    Creator = "terraform"
  }

}












