# Create logging S3 Bucket for Server Access Logs and VPC Flow Logs.
# This bucket is not needed if using in a best practice multi-account strategy environment. 
# In a Landing Zone or Control Tower environment, point to your Log Archive account buckets. 
# This S3 bucket does not have access logging enabled to avoid recursive logging
resource "aws_s3_bucket" "s3_pipeline_logging_bucket_logs" {
  bucket        = "${var.aws_s3_ami_resources_bucket}-logs"
  force_destroy = true

  tags = {
    Name = "${var.aws_s3_ami_resources_bucket}"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_pipeline_logging_bucket_enc" {
  bucket = aws_s3_bucket.s3_pipeline_logging_bucket_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "s3_pipeline_logging_bucket_version" {
  bucket = aws_s3_bucket.s3_pipeline_logging_bucket_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# resource "aws_s3_bucket_acl" "s3_pipeline_bucket_logs_acl" {
#   bucket = aws_s3_bucket.s3_pipeline_logging_bucket_logs.id
#   acl    = "private"
# }

resource "aws_s3_bucket_public_access_block" "s3_pipeline_bucket_logs_block" {
  bucket = aws_s3_bucket.s3_pipeline_logging_bucket_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create Pipeline S3 Bucket
resource "aws_s3_bucket" "s3_pipeline_bucket" {
  depends_on = [
    aws_s3_bucket.s3_pipeline_logging_bucket_logs
  ]
  bucket        = var.aws_s3_ami_resources_bucket
  force_destroy = true

  tags = {
    Name = "${var.aws_s3_ami_resources_bucket}"
  }
}

resource "aws_s3_bucket_logging" "s3_pipeline_bucket_log_cfg" {
  bucket        = aws_s3_bucket.s3_pipeline_bucket.id
  target_bucket = aws_s3_bucket.s3_pipeline_logging_bucket_logs.id
  target_prefix = "AccessLogs/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_pipeline_bucket_enc" {
  bucket = aws_s3_bucket.s3_pipeline_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# resource "aws_s3_bucket_acl" "s3_pipeline_bucket_acl" {
#   bucket = aws_s3_bucket.s3_pipeline_bucket.id
#   acl    = "private"
# }

resource "aws_s3_bucket_policy" "allow_access_from_pipeline_service_role" {
  bucket = aws_s3_bucket.s3_pipeline_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_pipeline_service_role.json
}

resource "aws_s3_bucket_public_access_block" "s3_pipeline_bucket_block" {
  bucket = aws_s3_bucket.s3_pipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "allow_access_from_pipeline_service_role" {
  depends_on = [
    aws_iam_role.hardening_pipeline_role
  ]
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:role/${var.hardening_pipeline_role_name}"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }

    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.s3_pipeline_bucket.arn,
      "${aws_s3_bucket.s3_pipeline_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_versioning" "s3_pipeline_bucket_version" {
  bucket = aws_s3_bucket.s3_pipeline_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_imagebuilder_image_pipeline" "this" {
  container_recipe_arn             = aws_imagebuilder_container_recipe.container_image.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.image_hardening.arn
  name                             = var.image_name
  status                           = "ENABLED"
  description                      = "Creates images."
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.container_image_distribution_config.arn

  schedule {
    # This cron schedule is for every Friday at 6 AM, modify it for your purposes.
    schedule_expression                = "cron(0 6 ? * fri)"
    pipeline_execution_start_condition = "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE"
  }

  image_tests_configuration {
    image_tests_enabled = true
  }

  tags = {
    "Name" = "${var.image_name}-hardening-container"
  }

  depends_on = [
    aws_imagebuilder_container_recipe.container_image,
    aws_imagebuilder_infrastructure_configuration.this,
    aws_imagebuilder_distribution_configuration.container_image_distribution_config,
  ]

  lifecycle {
    create_before_destroy = true
  }
}