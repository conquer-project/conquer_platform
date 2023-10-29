locals {
  # Everything is built around the AZs, increase one AZ that it will increase subnets, nats, eips and EKS nodes
  eks_availability_zones = toset([
    "eu-north-1a",
    "eu-north-1b"
  ])
}