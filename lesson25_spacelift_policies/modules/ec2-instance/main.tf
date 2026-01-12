# modules/ec2-instance/main.tf
# Main resource definitions for EC2 instance module

locals {
  ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id

  common_tags = merge(
    {
      Name        = var.instance_name
      Environment = var.environment
      ManagedBy   = "OpenTofu"
      Module      = "ec2-instance"
    },
    var.tags
  )
}

# Security Group for EC2 Instance
resource "aws_security_group" "instance" {
  name_prefix = "${var.instance_name}-"
  description = "Security group for ${var.instance_name}"
  vpc_id      = var.vpc_id

  # Egress: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# SSH Ingress Rule (only if CIDRs specified)
resource "aws_security_group_rule" "ssh_ingress" {
  count = length(var.allowed_ssh_cidrs) > 0 ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ssh_cidrs
  security_group_id = aws_security_group.instance.id
  description       = "SSH access from allowed CIDRs"
}

# EC2 Instance
resource "aws_instance" "this" {
  ami           = local.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids      = [aws_security_group.instance.id]
  associate_public_ip_address = var.associate_public_ip
  key_name                    = var.key_name != "" ? var.key_name : null
  monitoring                  = var.enable_monitoring

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true

    tags = merge(local.common_tags, {
      Name = "${var.instance_name}-root"
    })
  }

  # Enable IMDSv2 (security best practice)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [ami]
  }
}