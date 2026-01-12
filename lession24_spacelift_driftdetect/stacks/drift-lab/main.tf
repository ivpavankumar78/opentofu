# main.tf
# Resources for drift detection demonstration

# Random suffix for unique naming
resource "random_id" "suffix" {
  byte_length = 4
}

# S3 Bucket - Simple resource for drift demo
resource "aws_s3_bucket" "demo" {
  bucket = "${var.bucket_prefix}-${random_id.suffix.hex}"
  
  tags = {
    Name        = "Drift Detection Demo Bucket"
    Purpose     = "Training"
    CostCenter  = "Training-001"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "demo" {
  bucket = aws_s3_bucket.demo.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Security Group - Common drift target
resource "aws_security_group" "demo" {
  name        = "drift-demo-sg-${random_id.suffix.hex}"
  description = "Security group for drift detection demo"
  
  # SSH access - restricted to specific CIDR
  ingress {
    description = "SSH from allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  
  # HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "drift-demo-sg"
  }
}

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}