resource "aws_ecr_repository" "hardening_pipeline_repo" {
  name                 = var.ecr_name
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.encryption_key.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}

resource "aws_imagebuilder_distribution_configuration" "container_image_distribution_config" {
  name           = "image-builder-distribution-config"
  description    = "Distribution configuration for ECR"

  # distribution {
  #   ami_distribution_configuration {

  #     ami_tags = {
  #       Name = "${var.image_name}-{{ imagebuilder:buildDate }}"
  #     }

  #     name = "${var.image_name}-{{ imagebuilder:buildDate }}"

  #     launch_permission {
  #       user_ids = [var.account_id]
  #     }

  #     kms_key_id = aws_kms_key.encryption_key.arn
  #   }
  #   region = var.aws_region
  # }

  distribution {
    container_distribution_configuration {
      target_repository {
        repository_name = aws_ecr_repository.hardening_pipeline_repo.arn
        service = "ECR"
      }      
    }
      region = var.aws_region
  }
}