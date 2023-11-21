locals {
  # Everything is built around the AZs, increase one AZ that it will increase subnets, nats, eips and EKS nodes
  eks_availability_zones = toset([
    "us-east-1a",
    "us-east-1b"
  ])
}