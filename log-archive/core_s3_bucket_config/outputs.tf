

output "central_config_bucket_id" {
  description = "Name id of the central config S3 bucket"
  value       = module.s3_bucket_for_config_history.s3_bucket_id  
}


output "central_config_bucket_arn" {
  description = "Name id of the central config S3 bucket"
  value       = module.s3_bucket_for_config_history.s3_bucket_arn  
}

output "central_config_bucket_name" {
  description = "Name id of the central config S3 bucket"
  value       = module.s3_bucket_for_config_history.s3_bucket_id
}

