# Terraform Infrastructure Deployment - AWS EC2 Image Hardening Pipeline

This Terraform configuration deploys an AWS infrastructure stack used for creating a hardened container image using EC2 Image Builder. The resulting image is based on Amazon Linux 2 and follows the guidelines outlined in the Red Hat Enterprise Linux (RHEL) 7 STIG Version 3 Release 7 ‒ Medium.

## Usage Overview

The infrastructure includes an EC2 Image Builder pipeline, Docker-based Amazon Linux 2 container image, and associated components. It also uses two Amazon EventBridge rules: one triggering the pipeline based on Amazon Inspector findings, and the other notifying an Amazon Simple Queue Service (SQS) queue upon a successful image push to Amazon Elastic Container Registry (ECR).

## Prerequisites

- An AWS account for deployment.
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) 
- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed and configured.
- A role within the AWS account for creating resources.
- All variables defined in the [.tfvars]file or provided during Terraform apply.

## Limitations

- The solution creates an Amazon Virtual Private Cloud (Amazon VPC) with a NAT gateway and internet gateway for internet connectivity. VPC endpoints are not supported due to the bootstrap process installing AWS CLI version 2 from the internet.

## Module Structure

The module structure is outlined in the directory tree, with key files such as `main.tf`, `variables.tf`, and `.tfvars` for configuration.

## Deployment Steps

### Local Deployment

Follow these steps for local deployment:

1. Set up temporary AWS credentials using `aws configure`.
2. Clone the repository using HTTPS or SSH.
3. Navigate to the solution directory.
4. Update variables in `vars.tfvars`.
5. Run the following commands for initialization, validation, and application:

   ```bash
   terraform init && terraform validate && terraform apply -var-file *.tfvars -auto-approve
   ```

6. After successful completion, you should see a message indicating the added resources.

7. *(Optional)* Tear down the infrastructure using:

   ```bash
   terraform init && terraform validate && terraform destroy -var-file *.tfvars -auto-approve
   ```

## Author

* Frank Dooling (fdool73@gmail.com)