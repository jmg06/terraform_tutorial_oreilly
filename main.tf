# Resources are declared here.

# Terraform block
# Optional configuration for the terraform Engine.
# It is a best practice to include this block. It serves as a good way of documentation.
terraform {
  required_version = ">=1.17"
}

# Provider block
# Implement cloud specific API and Terraform API.
# Providers expose Data Sources and Resources to Terraform.
provider "aws" {
  # version = "~> 2.0" # This property is deprecated.
  region = "us-east-1"
  # access_key = "my-access-key"
  # secret_key = "my-secred-key"

  # Many providers also accept configuration via environment variables
  # or config files. The AWS provider will read the standard AWS CLI
  # settigns if they are present.
}

# Resources
# Objects managed by Terraform such as VMs or S3 Buckets.
# Declaring a Resource tells Terraform that it should CREATE
# and manage the Resource described. If the Resource already exists
# it must be imported into Terraform's state.
resource "aws_s3_bucket" "bucket1" {
  # bucket = "bucket1" # Terraform will automatically give it a name.
}

# Data Sources
# Objects NOT managed by Terraform.
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# Outputs
# Outputs are printed by the CLI after `apply`.
# These can reveal calculated values.
# Also used in more advenced use cases> modules, remote_state.
# Outputs can be retrieved at any time by running `terraform output`
output "bucket_info" {
  value = aws_s3_bucket.bucket1.bucket
}

output "aws_caller_info" {
  value = data.aws_caller_identity.current
}

output "aws_availability_zones" {
  value = data.aws_availability_zones.available
}

# Interpolation
# Substitute values in strings.
resource "aws_s3_bucket" "bucket2" {
  bucket = "${data.aws_caller_identity.current.account_id}-bucket-2"
}

# Dependency
# Resorces can depend on one another. Terraform will ensure that all
# dependencies are met before creating the resource. Dependency can
# be implicit or explicit
resource "aws_s3_bucket" "bucket3" {
  bucket = "${data.aws_caller_identity.current.account_id}-bucket3"
  tags = {
    # Implicit dependency
    dependency = aws_s3_bucket.bucket2.arn
  }
}

resource "aws_s3_bucket" "bucket4" {
  bucket = "${data.aws_caller_identity.current.account_id}-bucket4"
  # Explicit
  depends_on = [
    aws_s3_bucket.bucket3
  ]
}

# Variables
# Can be specified on the command line with -var bucket_name=my-bucket
# or in files: terraform.tfvars or *.auto.tfvars
# or in environment variables: TF_VARS_bucket_name
variable "bucket_name" {
  # `type` is an optional data type specification
  type = string

  # `default` is the optional default value. If `default` is ommited
  # then a value must be supplied.
  # defualt = "my-bucket"
}

resource "aws_s3_bucket" "bucket5" {
  bucket = var.bucket_name
}

# Locals
# Local values allow you to assign a name to an expression. Locals
# can make your code more readable.
locals {
  aws_account = "${data.aws_caller_identity.current.account_id}-${lower(data.aws_caller_identity.current.user_id)}"
}

resource "aws_s3_bucket" "bucket6" {
  bucket = "${local.aws_account}-bucket6"
}