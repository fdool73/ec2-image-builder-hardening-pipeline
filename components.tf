# Upload files to S3
resource "aws_s3_object" "component_files" {
  depends_on = [
    aws_s3_bucket.s3_pipeline_bucket,
    aws_kms_key.encryption_key
  ]

  for_each = fileset(path.module, "files/**/*.yml")

  bucket     = var.aws_s3_ami_resources_bucket
  key        = each.value
  source     = "${path.module}/${each.value}"
  kms_key_id = aws_kms_key.encryption_key.id
}

# Amazon Cloudwatch agent build component
resource "aws_imagebuilder_component" "cw_agent" {
  name       = "amazon-cloudwatch-agent-linux"
  platform   = "Linux"
  uri        = "s3://${var.aws_s3_ami_resources_bucket}/amazon-cloudwatch-agent-linux.yml"
  version    = "1.0.1"
  kms_key_id = aws_kms_key.encryption_key.arn

  depends_on = [
    aws_s3_bucket.aws_s3_ami_resources_bucket
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Update Amazon Linux AMI OS build component
resource "aws_imagebuilder_component" "update_linux_ami" {
  name       = "update-linux-ami"
  platform   = "Linux"
  uri        = "s3://${var.aws_s3_ami_resources_bucket}/update-linux.yml"
  version    = "1.0.1"
  kms_key_id = aws_kms_key.encryption_key.arn

  depends_on = [
    aws_s3_bucket.image_hardening
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Install AWS CLI build component
resource "aws_imagebuilder_component" "update_linux_ami" {
  name       = "update-linux-ami"
  platform   = "Linux"
  uri        = "s3://${var.aws_s3_ami_resources_bucket}/aws-cli-version-2-linux.yml"
  version    = "1.0.1"
  kms_key_id = aws_kms_key.encryption_key.arn

  depends_on = [
    aws_s3_bucket.image_hardening
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Reboot Linux OS test component
resource "aws_imagebuilder_component" "reboot_linux" {
  name       = "reboot-linux"
  platform   = "Linux"
  uri        = "s3://${var.aws_s3_ami_resources_bucket}/reboot-linux.yml"
  version    = "1.0.1"
  kms_key_id = aws_kms_key.encryption_key.arn

  depends_on = [
    aws_s3_bucket.image_hardening
  ]

  lifecycle {
    create_before_destroy = true
  }
}