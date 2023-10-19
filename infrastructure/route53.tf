resource "aws_route53_zone" "private-zone" {
  name = terraform.workspace == "prod" ? "conquer.com" : "${local.project}.com"

  vpc {
    vpc_id = aws_vpc.conquer-vpc.id
  }
}
