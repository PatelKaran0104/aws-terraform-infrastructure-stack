# AWS Educate Configuration

env = "educate"
vpc_conf = {
  cidr                 = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
}
region = "us-east-1"  # Most commonly supported region in AWS Educate

# Subnet Configurations for us-east-1
public_subnets = {
  "us-east-1a" = "10.0.1.0/24"
  "us-east-1b" = "10.0.2.0/24"
}

private_subnets = {
  "us-east-1a" = "10.0.3.0/24"
  "us-east-1b" = "10.0.4.0/24"
}

# EC2 Configuration - Using t2.micro for free tier eligibility
instance_type = "t2.micro"
ami_id        = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI for us-east-1

# ALB Security Group Rules
alb_sg_ingress_rules = {
  http = {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

alb_sg_egress_rules = {
  all = {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Security Group Rules
ec2_sg_ingress_rules = {
  http = {
    description = "HTTP from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow from VPC CIDR
  }
  ssh = {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

ec2_sg_egress_rules = {
  all = {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Configuration
rds_conf = {
  allocated_storage       = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "appdb"
  username               = "admin"
  multi_az               = false  # Single AZ for cost savings in AWS Educate
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted      = false  # Disable encryption for simplicity
  backup_retention_period = 0     # Disable backups for cost savings
}

# RDS Security Group Rules
rds_sg_ingress_rules = {
  mysql = {
    description = "MySQL from EC2"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]  # Private subnets only
  }
}

rds_sg_egress_rules = {
  all = {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
