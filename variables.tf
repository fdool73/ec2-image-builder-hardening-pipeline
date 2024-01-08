###################################
## Base
###################################
variable "image_name" {
  type        = string
  description = "Image name"
  default     = "amazon-linux-2-baseline"

  validation {
    condition     = can(regex("[a-zA-Z0-9-]{3,50}", var.image_name))
    error_message = "The image_name value must be between 3 and 50 characters, should contain alphanumeric and hyphen characters only."
  }
}

variable "recipe_version" {
  type        = string
  description = "Image recipe version. Example: 1.0.0"
}

variable "account_id" {
  type        = string
  description = "AWS account number"
}

variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "AWS Region to deploy in"
}

variable "vpc_name" {
  type        = string
  description = "Name for the VPC"
}

variable "ec2_iam_role_name" {
  type        = string
  description = "Name for the EC2 Instance Profile role"
}

variable "hardening_pipeline_role_name" {
  type        = string
  description = "Name for the role that will be used to deploy the hardening Pipeline"
}

variable "ecr_name" {
  type        = string
  description = "Name for ECR repo"
}

variable "aws_s3_ami_resources_bucket" {
  type        = string
  description = "Name for pipeline and container images S3 Bucket"
  validation {
    condition     = substr(var.aws_s3_ami_resources_bucket, 0, 1) != "/" && substr(var.aws_s3_ami_resources_bucket, -1, 1) != "/" && length(var.aws_s3_ami_resources_bucket) > 0
    error_message = "Parameter `aws_s3_ami_resources_bucket` cannot start and end with \"/\", as well as cannot be empty."
  }
}

variable "ebs_root_vol_size" {
  type        = number
  description = "Size (in gigabytes) of the EBS Root Volume"
}

variable "kms_key_alias" {
  type        = string
  description = "KMS Key name "
}
