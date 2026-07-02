output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs (worker nodes)"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs (ALB / NAT)"
  value       = module.vpc.public_subnet_ids
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required for kubeconfig"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS control plane ENIs"
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider, needed for wiring IRSA roles (LB Controller, EBS CSI, backend app)"
  value       = module.eks.oidc_provider_arn
}

output "node_security_group_id" {
  description = "Security group ID attached to worker nodes"
  value       = module.eks.node_security_group_id
}

output "configure_kubectl" {
  description = "Command to update local kubeconfig to talk to this cluster"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}
