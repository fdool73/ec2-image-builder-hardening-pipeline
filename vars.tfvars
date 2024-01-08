# Enter values for all of the following if you wish to avoid being prompted on each run.
account_id                   = "671742331123"
aws_region                   = "us-west-2"
vpc_name                     = "image-hardening-pipeline-vpc"
kms_key_alias                = "image-builder-container-key"
ec2_iam_role_name            = "image-hardening-instance-role"
hardening_pipeline_role_name = "image-hardening-pipeline-role"
aws_s3_ami_resources_bucket  = "image-hardening-ami-resources-bucket-0123"
image_name                   = "image-hardening-al2-container-image"
ecr_name                     = "image-hardening-container-repo"
recipe_version               = "1.0.0"
ebs_root_vol_size            = 30