############## EKS Control Plane ####################
data "aws_iam_policy_document" "assume_eks_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_role" {
  name               = "${local.project}-eks-role"
  assume_role_policy = data.aws_iam_policy_document.assume_eks_role.json
}

# https://docs.aws.amazon.com/eks/latest/userguide/security-iam-awsmanpol.html#security-iam-awsmanpol-AmazonEKSClusterPolicy
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

# Optionally, enable Security Groups for Pods
# https://aws.amazon.com/blogs/containers/introducing-security-groups-for-pods/

# resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#   role       = aws_iam_role.example.name
# }


################# EKS WORKER NODES ROLE ###################
data "aws_iam_policy_document" "assume_eks-worker_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_worker_role" {
  name               = "${local.project}-eks-worker-role"
  assume_role_policy = data.aws_iam_policy_document.assume_eks-worker_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2RoleforSSM" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.eks_worker_role.name
}



# https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html
# You can attach the policy to the Amazon EKS node IAM role, or to a separate IAM role. 
# We recommend that you assign it to a separate role.
# TODO: Create a separate role for this policy
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_role.name
}

# TODO: Import SSM roles for terraform
# If the instance is private and do not have internet access through NAT or internet gateway
# We need to enable the instance to some endpoints
# Reference: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-privatelink.html