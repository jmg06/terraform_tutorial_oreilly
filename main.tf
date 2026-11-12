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