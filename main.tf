# ============ Providers ======================
provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "hope4all-dev"
}

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "hope4all-dev"
  }
}

# ---------------------------------------------------------------------------
# VPC 
# ---------------------------------------------------------------------------
module "vpc" {
  source = "../modules/VPC"

  project_name    = var.project_name
  environment     = var.environment
  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs

  enable_nat_gateway = var.enable_nat_gateway
  create_eip         = var.create_eip

  create_app_sg = var.create_app_sg
  create_elb_sg = var.create_elb_sg
  create_db_sg  = var.create_db_sg

  elb_ingress_rules = var.elb_ingress_rules

  app_ingress_rules = [
    {
      from_port       = 5001
      to_port         = 5001
      protocol        = "tcp"
      security_groups = [module.vpc.elb_sg_id]
    }
  ]
}

# =================== ECR-Backend ==========================
module "ecr_backend" {
  source = "../modules/ECR"

  project_name    = var.project_name
  environment     = var.environment
  repository_name = var.backend_repository_name
  scan_on_push    = var.scan_on_push

  tags = {
    Project = var.project_name
    Env     = var.environment
  }
}

# =================== ECR-Frontend ==========================
module "ecr_frontend" {
  source = "../modules/ECR"

  project_name    = var.project_name
  environment     = var.environment
  repository_name = var.frontend_repository_name
  scan_on_push    = var.scan_on_push

  tags = {
    Project = var.project_name
    Env     = var.environment
  }
}
# ==================== ACM ========================
module "acm" {
  source = "../modules/ACM"

  project_name = var.project_name
  environment  = var.environment

  domain_name               = var.domain_name
  auto_validate_via_route53 = var.auto_validate_via_route53
  subject_alternative_names = var.subject_alternative_names

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# ---------------------------------------------------------------------------
# EKS Cluster - official terraform-aws-modules, fed by your VPC's outputs
# ---------------------------------------------------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  enable_irsa = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types
      capacity_type  = "ON_DEMAND"

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      vpc_security_group_ids = [module.vpc.app_sg_id]
    }
  }

  tags = var.tags
}

# =============== EKS-Add-Ons =============================
module "eks_addons" {
  source = "../modules/EKS-Addons"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  vpc_id            = module.vpc.vpc_id

  node_iam_role_arns = [module.eks.eks_managed_node_groups["default"].iam_role_arn]

  enable_ebs_csi           = var.enable_ebs_csi
  enable_efs_csi           = var.enable_efs_csi
  enable_lb_controller     = var.enable_lb_controller
  enable_karpenter         = var.enable_karpenter
  enable_secrets_store_csi = var.enable_secrets_store_csi

  # backend_secret_arns = [module.mongo_secret.secret_arn]
  tags                = var.tags

  depends_on = [module.eks]
}