#!/bin/bash

# Script to use in case region changes, destroy the resources that are regional in infrastructure/

set -eo pipefail

# Will plan to destroy only the VPC and the subnets that are the global resources in infrastructure/
terraform plan -destroy -target=aws_vpc.conquer-vpc -target=aws_subnet.eks_subnets\["eu-north-1b"\] -target=aws_subnet.eks_subnets\["eu-north-1a"\] -out=plan.out

# Apply
terraform apply --auto-approve