resource "aws_ecr_repository" "backend" {
  name = "langserve"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "frontend" {
  name = "langserve-frontend"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


# Expire old images to save cost of storage
# data "aws_ecr_lifecycle_policy_document" "example" {
#   rule {
#     priority    = 1
#     description =  "Expire images older than 14 days"

#     selection {
#       tag_status      = "untagged"
#       count_type      = "sinceImagePushed"
#       count_unit      = "days"
#       count_number    = 14
#     }

#     action {
#       type = "expire"
#     }
#   }
# }

# resource "aws_ecr_lifecycle_policy" "be" {
#   repository = aws_ecr_repository.backend.name
#   policy = data.aws_ecr_lifecycle_policy_document.example.json
# }

# resource "aws_ecr_lifecycle_policy" "fe" {
#   repository = aws_ecr_repository.frontend.name
#   policy = data.aws_ecr_lifecycle_policy_document.example.json
# }
