variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix used across resources"
  type        = string
  default     = "architectai"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}
# ======== vpc ========



#### VPC ####

variable "vpc_name" {
  type    = string
  default = "MyVPC"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "enable_nat_gateway" { type = bool }
variable "create_eip" { type = bool }

variable "create_app_sg" { type = bool }
variable "create_elb_sg" { type = bool }
variable "create_db_sg" { type = bool }

variable "elb_ingress_rules" {
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
}
####   SECRETS MANAGER


# variable "secrets_name" {
#   type = string
# }
# variable "mongo_uri" {
#   type      = string
#   sensitive = true
# }


####    ECR    ####

variable "frontend_repository_name" {
  type = string
}
variable "backend_repository_name" {
  type = string

}
variable "scan_on_push" {
  type = bool
}

# ACM

variable "domain_name" {
  type = string
}
variable "auto_validate_via_route53" {
  type = bool
}
variable "subject_alternative_names" {
  type = list(string)
}

# eks

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
  default     = "1.29"
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS public API endpoint is enabled"
  type        = bool
  default     = true
}
variable "enable_cluster_creator_admin_permissions" {
  type = bool
  
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project   = "architectai"
    ManagedBy = "terraform"
  }
}
#  ====================== EKS-ADD-ONs ============================
variable "enable_ebs_csi" {
  type = bool

}

variable "enable_efs_csi" {
  type = bool

}

variable "enable_lb_controller" {
  type = bool

}

variable "enable_karpenter" {
  type = bool

}

variable "enable_secrets_store_csi" {
  type = bool

}