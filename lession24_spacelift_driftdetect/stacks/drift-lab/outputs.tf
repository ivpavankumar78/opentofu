# outputs.tf
# Output values for reference and verification

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.demo.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.demo.arn
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.demo.id
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.demo.name
}