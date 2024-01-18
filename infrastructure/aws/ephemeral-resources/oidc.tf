########### EKS Cluster IdP - Required to allow k8s serviceaccounts to assume IAM Roles ##############
# https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html

# Get information about the TLS certificate that protects the OIDC issuer URL embedded on every EKS clusters
# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate
data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

# Create an Identity Provider on AWS and trust on it (in this case, the embedded IdP of our eks cluster)
resource "aws_iam_openid_connect_provider" "eks-idp" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}
