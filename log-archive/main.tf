#aws provider with the assumption role

provider "aws" {
  region = "eu-west-2"
  alias = "logarchive"
  assume_role {
    role_arn = "arn:aws:iam::890742580474:role/OrganizationAccountAccessRole"
    external_id = "cross_account_terragrunt"
  }
}



#S3 bucket for config logs with policy attached for config service

resource "aws_s3_bucket" "config_bucket" {
  provider = aws.logarchive
  bucket_prefix = "aws-config-logs"
  force_destroy = true
  /*lifecycle {
    prevent_destroy = true
  }
  */
  
}

/*
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.config_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.config_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.config_bucket.id
  acl    ="log-delivery-write"
}

*/



/*
resource "aws_s3_bucket_public_access_block" "config" {
  bucket = aws_s3_bucket.config_bucket.id
  depends_on = [aws_s3_bucket.config_bucket, ]
  provider = aws.logarchive

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
*/

/*

# Export the S3 bucket name
output "logging_bucket_name" {
  value = "${aws_s3_bucket.logging_bucket.id}"
}

output "bucket-arn" {
  value = "${aws_s3_bucket.logging_bucket.arn}"
}


resource "aws_s3_bucket_policy" "allow_config_access_from_another_account" {
  bucket = aws_s3_bucket.config_bucket.id
  #policy = data.aws_iam_policy_document.allow_config_access_from_another_account.json
  provider = aws.logarchive

  policy = jsonencode (
    
      {
        "Version": "2012-10-17",
        "Statement": [

            {
              "Sid": "config_bucket_policy",
              "Action": [
                "s3:GetObject",
                "s3:ListBucket",
                "s3:PutObject",
                "s3:GetObjectACL"                
              ],
              "Effect": "Allow",
              "Resource": [
                aws_s3_bucket.config_bucket.arn,
                "${aws_s3_bucket.config_bucket.arn}/*"
              ]
             "Condition": {
                "StringEquals": {
                  "aws:PrincipalOrgID": "o-4jsdkwq1yx"
                }
              },
              "Principal": {
                "Service": [
                  "config.amazonaws.com"
                ],
                "AWS": [
                  "arn:aws:iam::288761729658:role/core-config-org-config", 
                  "arn:aws:iam::288761729658:role/core-config-org-aggregator-config"

              ]
              }
            }
        ]

       

      }
       
      
        
      

  )

  

}



*/

