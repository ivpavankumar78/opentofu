# Data source for available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module - Production Configuration
module "vpc" {
  source = "../../modules/vpc"
  
  project_name = var.project_name
  environment  = "prod"
  
  vpc_cidr = "10.1.0.0/16"
  
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
  
  subnet_configuration = {
    public = {
      enabled      = true
      count        = 4
      newbits      = 8
      netnum_start = 0
    }
    private = {
      enabled      = true
      count        = 3
      newbits      = 8
      netnum_start = 10
    }
    database = {
      enabled      = true
      count        = 3
      newbits      = 8
      netnum_start = 20
    }
  }
  
  # Multiple NAT gateways for high availability
  enable_nat_gateway  = true
  single_nat_gateway  = false
  
  # Production security groups
  security_groups = {
    alb = {
      description = "Security group for Application Load Balancer"
      ingress_rules = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTP from internet"
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS from internet"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow all outbound"
        }
      ]
    }
    
    web = {
      description = "Security group for web tier"
      ingress_rules = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
          description = "HTTP from ALB subnets"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow all outbound"
        }
      ]
    }
    
    app = {
      description = "Security group for application tier"
      ingress_rules = [
        {
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          cidr_blocks = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
          description = "App port from web tier"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow all outbound"
        }
      ]
    }
    
    database = {
      description = "Security group for database tier"
      ingress_rules = [
        {
          from_port   = 3306
          to_port     = 3306
          protocol    = "tcp"
          cidr_blocks = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
          description = "MySQL from app tier"
        }
      ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow all outbound"
        }
      ]
    }
    bastion = {
        description = "Security group for bastion host"
        ingress_rules = [
            {
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            cidr_blocks = ["13.232.226.192/32"]  # Replace with your IP
            description = "SSH from admin"
            }
        ]
        egress_rules = [
            {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            description = "Allow all outbound"
            }
        ]
    }
    bastion = {
        description = "Security group for bastion host"
        ingress_rules = [
            {
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            cidr_blocks = ["13.232.226.192/32"]  # Replace with your IP
            description = "SSH from admin"
            }
        ]
        egress_rules = [
            {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            description = "Allow all outbound"
            }
        ]
    }
  }
  
  tags = {
    Owner       = "ProdOps"
    CostCenter  = "Production"
    Compliance  = "Required"
  }
}

# Trust policy: VPC Flow Logs service can assume this role
data "aws_iam_policy_document" "vpc_flow_logs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name               = "${var.project_name}-vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_role.json
  tags = {
    Owner       = "ProdOps"
  }
}

#name_prefix = "${var.project_name}-${var.environment}"

resource "aws_flow_log" "main" {
  count = var.enable_flow_logs ? 1 : 0
  #iam_role_arn    = aws_iam_role.flow_logs[0].arn
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc.vpc_id
  tags = {
            Name = "${var.project_name}-flow-logs"
    }
  
}
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/vpc/flow-logs/${var.project_name}"
}

# Outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnet_ids
}

output "private_subnets" {
  value = module.vpc.private_subnet_ids
}

output "database_subnets" {
  value = module.vpc.database_subnet_ids
}

output "security_groups" {
  value = module.vpc.security_group_ids
}

output "db_subnet_group" {
  value = module.vpc.db_subnet_group_name
}