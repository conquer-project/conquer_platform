# EKS features https://aws.amazon.com/eks/features/
# EKS keeps one single tenant control plane per cluster and make sure its high availability


### EKS Control Plane ###
# EKS throubleshooting https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html
resource "aws_eks_cluster" "eks" {
  name     = "${local.project}-cluster" # The name must be unique within the AWS Region and AWS account
  role_arn = aws_iam_role.eks_role.arn

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  kubernetes_network_config {
    # CIDR block to assign to Kubernetes pod and service IP address
    # Recommendation is to do not overlap any other resources in other network that is peered with the cluster VPC
    # Can't overlap with any CIDR block assigned to the cluster VPC
    # Need to be between /24 and /12
    service_ipv4_cidr = "10.100.0.0/16"
    ip_family         = "ipv4"
  }

  vpc_config {
    subnet_ids              = [for az in local.eks_availability_zones : aws_subnet.eks_subnets_private[az].id] # You can't change which subnets you want to use after cluster creation.
    endpoint_public_access  = true
    endpoint_private_access = true          # Enable EKS public API server endpoint https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html
    public_access_cidrs     = ["0.0.0.0/0"] # EKS API server endpoint source IP, could be used to allow only VPN
    # security_group_ids = [] TODO: make the cluster private
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    #aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController
  ]

  # https://kubernetes.io/releases/
  # Supported versions by EKS https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
  version = "1.28" # no upgrades will occur except those automatically triggered by EKS

  tags = {
    ctf = "WW91IGdvdCBpdCEgbmljZS4="
  }

}

resource "aws_eks_addon" "example" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_update = "PRESERVE"
}

# Cluster outputs
output "endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value     = aws_eks_cluster.eks.certificate_authority[0].data
  sensitive = true
}

output "oidc-issuer" {
  value = aws_eks_cluster.eks.identity
}