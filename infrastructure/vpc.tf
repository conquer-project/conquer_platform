# VPC
# Reference https://github.com/hashicorp/learn-terraform-provision-eks-cluster/blob/57e1156420c1f4893c7fc50da8b8dbf322961d34/main.tf#L26
resource "aws_vpc" "conquer-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true # Defaults to true, but for reference since EKS nodes needs this to be true in order to work properly
  enable_dns_hostnames = true
  tags = {
    "Name" = "${local.project}-vpc"
  }
}

# VPC Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.conquer-vpc.id

  tags = {
    Name = "${local.project}-vpc-igw"
  }
}

# VPC Default route table with internet gateway route
resource "aws_default_route_table" "vpc_default_rt" {
  default_route_table_id = aws_vpc.conquer-vpc.main_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.project}-vpc-default-rt"
  }
}