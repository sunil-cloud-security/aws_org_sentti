output "central_accesslogs_bucket_id" {
  description = "Name id of the central access_logs S3 bucket"
  value       = module.s3_bucket_for_access_logs.s3_bucket_id
}

output "central_cloudtrail_bucket_id" {
  description = "Name id of the central access_logs S3 bucket"
  value       = module.s3_bucket_for_cloudtrail_logs.s3_bucket_id
}

output "central_guardduty_bucket_id" {
  description = "Name id of the central access_logs S3 bucket"
  value       = module.s3_bucket_for_gd_findings.s3_bucket_id
}
