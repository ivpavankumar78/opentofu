# providers.tf
# AWS provider configuration

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "drift-detection-lab"
      Environment = var.environment
      ManagedBy   = "OpenTofu"
    }
  }
}