resource "aws_ecr_repository" "conquer-ecr-repo" {
  name                 = "${local.project}-ecr-repo"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
