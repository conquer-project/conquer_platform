data "aws_vpc" "conquer-vpc" {
  filter {
    name = "tag:Name"
    values = [
      "${local.project}-vpc"
    ]
  }
}

# Need to be at least two subnets in two different AZs
# Public subnets
resource "aws_subnet" "eks_subnets_public" {
  for_each          = local.eks_availability_zones
  vpc_id            = data.aws_vpc.conquer-vpc.id
  cidr_block        = "10.0.${index(tolist(local.eks_availability_zones), each.value) + length(local.eks_availability_zones) + 1}.0/24" # 254 IPs available to pods with this configuration
  availability_zone = each.value                                                                                                        # Ensure multi zones
  tags = {
    Name = "${local.project}-public_subnet_${each.value}"
    Tier = "Public"
  }
}

# Private subnets
resource "aws_subnet" "eks_subnets_private" {
  for_each          = local.eks_availability_zones
  vpc_id            = data.aws_vpc.conquer-vpc.id
  cidr_block        = "10.0.${index(tolist(local.eks_availability_zones), each.value) + 1}.0/24" # 254 IPs available to pods with this configuration
  availability_zone = each.value                                                                 # Ensure multi zones
  tags = {
    Name = "${local.project}-private_subnet_${each.value}"
    Tier = "Private"
  }
}

# Route tables

## Private subnets route tables
## One route table per AZ, respectively on route table per private subnet
resource "aws_route_table" "private_subnet_rt" {
  for_each = local.eks_availability_zones
  vpc_id   = data.aws_vpc.conquer-vpc.id

  tags = {
    Name = "${local.project}-nat-${each.value}-rt"
  }
}

resource "aws_route_table_association" "private_subnet_rt_association" {
  for_each       = local.eks_availability_zones
  subnet_id      = aws_subnet.eks_subnets_private["${each.value}"].id
  route_table_id = aws_route_table.private_subnet_rt["${each.value}"].id
}

# NAT configuration

## One public IP per AZ
resource "aws_eip" "vpc_eip" {
  for_each = local.eks_availability_zones
  tags = {
    Name = "${local.project}-eip-${each.value}"
  }
}

## One nat per AZ, respectively one nat per public subnet
resource "aws_nat_gateway" "nat_gw" {
  for_each      = local.eks_availability_zones
  allocation_id = aws_eip.vpc_eip["${each.value}"].id
  subnet_id     = aws_subnet.eks_subnets_public["${each.value}"].id

  depends_on = [aws_eip.vpc_eip]

  tags = {
    Name = "${local.project}-nat-gw-public-subnet-${each.value}"
  }
}

# Routes
resource "aws_route" "nat_access" {
  for_each               = local.eks_availability_zones
  route_table_id         = aws_route_table.private_subnet_rt["${each.value}"].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw["${each.value}"].id
}
