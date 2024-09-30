data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "s3_bucket_for_access_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = "${var.central-access-logs}${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  
  /*
  versioning = {
    status     = true
    mfa_delete = false
  }
  
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
*/
  tags = {
    Name = "${var.central-access-logs}",
    Creator = "terraform"
  }   

}
# Central Access S3 bucket_policy. Only the centralised cloudtrail and config history buckets send their access logs here
#Perhaps in the future we also send the Important S3 bucket Access Logs here 
resource "aws_s3_bucket_policy" "cross_account_policy" {
    bucket = module.s3_bucket_for_access_logs.s3_bucket_id
    policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

# Access logging policy attached to the access log bucket
data "aws_iam_policy_document" "allow_access_from_another_account" {
    statement {
      actions   = ["s3:PutObject"]
      effect    = "Allow"
      resources = [
          "arn:aws:s3:::${module.s3_bucket_for_access_logs.s3_bucket_id}/access-logs/*"
          ]
      principals {
          type = "Service"
          identifiers = ["logging.s3.amazonaws.com"]
      }
      condition {
          test     = "ArnLike"
          variable = "aws:SourceArn"

          values = [
              "arn:aws:s3:::${var.central-config-history}",
              "arn:aws:s3:::${module.s3_bucket_for_cloudtrail_logs.s3_bucket_id}",                   
          ]
      }       
    }
}

## CloudTrail Bucket Setup

module "s3_bucket_for_cloudtrail_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = "${var.central-cloudtrail-logs}${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  /*
  versioning = {
    status     = true
    mfa_delete = false
  }
  
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
    target_bucket = module.s3_bucket_for_access_logs.s3_bucket_id
    target_prefix = "access-logs/"
  }
*/
  tags = {
    Name = "${var.central-cloudtrail-logs}",
    Creator = "terraform"
  }

}

#Policy to attach to the CloudTrail

# Central Access S3 bucket_policy. Only the centralised cloudtrail and config history buckets send their access logs here
#Perhaps in the future we also send the Important S3 bucket Access Logs here 
resource "aws_s3_bucket_policy" "ctorg_account_policy" {
    bucket = module.s3_bucket_for_cloudtrail_logs.s3_bucket_id
    policy = data.aws_iam_policy_document.allow_ctorg_from_another_account.json
}

# Access logging policy attached to the access log bucket
data "aws_iam_policy_document" "allow_ctorg_from_another_account" {
    statement {
      actions   = ["s3:PutObject"]
      effect    = "Allow"
      resources = [
          "arn:aws:s3:::${module.s3_bucket_for_cloudtrail_logs.s3_bucket_id}/AWSLogs/${var.management_account_id}/*"
          #"arn:aws:s3:::${module.s3_bucket_for_cloudtrail_logs.s3_bucket_id}/AWSLogs/*"
          ]
      principals {
          type = "Service"
          identifiers = ["cloudtrail.amazonaws.com"]
      }
      condition {
          test     = "StringEquals"
          variable = "s3:x-amz-acl"

          values = [
              "bucket-owner-full-control",                                
          ]
      }      
      condition {
          test     = "StringEquals"
          variable = "aws:SourceArn"

          values = [
              "arn:aws:cloudtrail:eu-west-2:${var.management_account_id}:trail/${var.Trailname}"                                            
          ]
      }      
    }

    statement {
      actions   = ["s3:PutObject"]
      effect    = "Allow"
      resources = [
          "arn:aws:s3:::${module.s3_bucket_for_cloudtrail_logs.s3_bucket_id}/AWSLogs/${var.org_id}/*"
          ]
      principals {
          type = "Service"
          identifiers = ["cloudtrail.amazonaws.com"]
      }
      condition {
          test     = "StringEquals"
          variable = "s3:x-amz-acl"

          values = [
              "bucket-owner-full-control",
                                
          ]
      }
      
      condition {
          test     = "StringEquals"
          variable = "aws:SourceArn"

          values = [
              "arn:aws:cloudtrail:eu-west-2:${var.management_account_id}:trail/${var.Trailname}",
              #"arn:aws:cloudtrail:eu-west-2:288761729658:trail/orgtrail",                                
          ]
      }
    }

    statement {
      actions   = ["s3:GetBucketAcl"]
      effect    = "Allow"
      resources = [
          "arn:aws:s3:::${module.s3_bucket_for_cloudtrail_logs.s3_bucket_id}"
          ]
      principals {
          type = "Service"
          identifiers = ["cloudtrail.amazonaws.com"]
      }
      
      
      condition {
          test     = "StringEquals"
          variable = "aws:SourceArn"

          values = [
              "arn:aws:cloudtrail:eu-west-2:${var.management_account_id}:trail/${var.Trailname}",
              #"arn:aws:cloudtrail:eu-west-2:288761729658:trail/orgtrail",                                
          ]
      }       
    }


}

## GuaradDuty Bucket Setup

module "s3_bucket_for_gd_findings" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = "${var.central-guardduty-findings}${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  /*
  versioning = {
    status     = true
    mfa_delete = false
  }
  
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
    target_bucket = module.s3_bucket_for_access_logs.s3_bucket_id
    target_prefix = "access-logs/"
  }
*/
  tags = {
    Name = "${var.central-guardduty-findings}",
    Creator = "terraform"
  }

}

resource "aws_s3_bucket_policy" "gdorg_account_policy" {
    bucket = module.s3_bucket_for_gd_findings.s3_bucket_id
    policy = data.aws_iam_policy_document.allow_gdorg_from_another_account.json
}

# Access logging policy attached to the access log bucket
data "aws_iam_policy_document" "allow_gdorg_from_another_account" {
    statement {
      actions   = ["s3:GetBucketLocation","s3:ListBucket"]
      effect    = "Allow"
      resources = [
          "arn:aws:s3:::${module.s3_bucket_for_gd_findings.s3_bucket_id}"
          ]
      principals {
          type = "Service"
          identifiers = ["guardduty.amazonaws.com"]
      }
      condition {
          test     = "StringEquals"
          variable = "aws:SourceAccount"

          values = ["${data.aws_caller_identity.current.account_id}",]
      }        
    }
    
    statement {
      actions   = ["s3:PutObject"]
      effect    = "Allow"
      resources = [
          "arn:aws:s3:::${module.s3_bucket_for_gd_findings.s3_bucket_id}/*",
      ]
      principals {
          type = "Service"
          identifiers = ["guardduty.amazonaws.com"]
      }
      condition {
          test     = "StringEquals"
          variable = "aws:SourceAccount"

          values = [
              "${data.aws_caller_identity.current.account_id}",                              
          ]
      }      
      /*condition {
          test     = "StringEquals"
          variable = "aws:SourceArn"
          values = [
            "arn:aws:guardduty:${data.aws_caller_identity.current.account_id}:detector/SourceDetectorID",
                                
          ]
      }  */    
    }
    /*
    statement {
      actions   = ["s3:*"]
      effect    = "Deny"
      resources = [
          "arn:aws:s3:::${module.s3_bucket_for_gd_findings.s3_bucket_arn}/*"
      ]
      principals {
          type = "*"
          identifiers = ["*"]
      }
      condition {
          test     = "Bool"
          variable = "aws:SecureTransport"

          values = [
              "false",                              
          ]
      }      
      condition {
          test     = "StringEquals"
          variable = "aws:SourceArn"
          values = [
            "arn:aws:guardduty:${data.aws_caller_identity.current.account_id}:detector/SourceDetectorID",
                                
          ]
      }      
    }
    */

    


}



