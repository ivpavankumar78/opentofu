# modules/ec2-instance/outputs.tf
# Output values exposed by the module

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "The ARN of the EC2 instance"
  value       = aws_instance.this.arn
}

output "private_ip" {
  description = "The private IP address of the instance"
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "The public IP address (if assigned)"
  value       = aws_instance.this.public_ip
}

output "private_dns" {
  description = "The private DNS name of the instance"
  value       = aws_instance.this.private_dns
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.instance.id
}

output "instance_state" {
  description = "The state of the instance"
  value       = aws_instance.this.instance_state
}

output "ami_id" {
  description = "The AMI ID used for the instance"
  value       = aws_instance.this.ami
}