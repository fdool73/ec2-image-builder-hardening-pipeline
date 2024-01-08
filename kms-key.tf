data "aws_iam_policy_document" "encryption_key" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
  }

  statement {
    sid       = "Allow access for Key Administrators"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_id}:role/${local.kms_admin_role_name}"
      ]
    }
  }

  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_id}:role/${local.kms_admin_role_name}"
      ]
    }
  }

  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_id}:role/${local.kms_admin_role_name}"
      ]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

# Creates and manages KMS CMK
resource "aws_kms_key" "encryption_key" {
  description             = "EC2 Image Builder key"
  is_enabled              = true
  enable_key_rotation     = true
  tags                    = local.core_tags
  policy                  = data.aws_iam_policy_document.encryption_key.json
  deletion_window_in_days = 30
}

# Add an alias to the key
resource "aws_kms_alias" "encryption_key" {
  name          = "alias/${var.kms_key_alias}"
  target_key_id = aws_kms_key.encryption_key.key_id
}