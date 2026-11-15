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

# Count
# All resources have a `count` parameter. The default value is 1.
# If `count` is set then a list of resources is returned (even if there is only 1).
# If `count` is set then a `count.index` value is available. This value contains the current iteration number.
# TIP: setting `count = 0` is a handy way to remove a resource but keep the config.
resource "aws_s3_bucket" "bucketX" {
  count  = 0
  bucket = "${local.aws_account}-bucket${count.index + 7}"
}

# for_each
# Resources may have a `for_each` parameter.
# If for_each is set then a resource is created for each item in the set and a
# special `each` object is available. The `each` object has `key` and `value`
# attributes that can be referenced.
locals {
  # buckets = {
  #   bucket101 = "mybucket101"
  #   bucket102 = "mybucket102"
  # }
  buckets = [
    "mybucket101",
    "mybucket102"
  ]
}

resource "aws_s3_bucket" "bucketE" {
  # for_each = local.buckets
  # bucket = "${local.aws_account}-${each.value}"
  for_each = toset(local.buckets)
  bucket   = "${local.aws_account}-${each.key}"
}

# Data types
# Terraform supports simple and complex data types
locals {
  a_string  = "This is a string."
  a_number  = 3.1415
  a_boolean = true
  a_list = [
    "element1",
    2,
    "three"
  ]
  a_map = {
    key = "value"
  }

  # Complex
  person = {
    name = "Juan Gutierrez",
    phone_numbers = {
      home   = "69845121"
      mobile = "+573125486456"
    }
    is_active = true,
  }
}

output "home_phone" {
  value = local.person.phone_numbers.home
}

# Operators
# Terraform supports arithmetic and logical operations in expressions too
locals {
  # Arithmetic
  three = 1 + 2 // addition
  two   = 3 - 1 // subtraction
  one   = 2 / 2 // division
  zero  = 1 * 0 // multiplication

  # Logical
  t = true || false // OR true if either value is true
  f = true && false // AND true if both values are true

  # Comparison
  gt  = 2 > 1  // true if left value is greater
  gte = 2 >= 1 // true if left value is greater or equal
  lt  = 1 < 2  // true if left value is less
  lte = 1 <= 2 // true if left value is less or equal
  eq  = 1 == 1 // true if left and right are equal
  neq = 1 != 2 // true if left and right are not equal
}

output "arithmetic" {
  value = "${local.zero} ${local.one} ${local.two} ${local.three}"
}

output "logical" {
  value = "${local.t} ${local.f}"
}

output "comparison" {
  value = "${local.gt} ${local.gte} ${local.lt} ${local.lte} ${local.eq} ${local.neq}"
}

# Conditionals
variable "bucket_count" {
  type = number
}

locals {
  minimum_number_of_buckets = 5
  number_of_buckets         = var.bucket_count > 0 ? var.bucket_count : local.minimum_number_of_buckets // ! BUG
}

resource "aws_s3_bucket" "buckets" {
  count  = local.number_of_buckets
  bucket = "${local.aws_account}-bucket${count.index + 7}"
}

# Functions
# Terraform has 100+ built in functions (but no ability to define custom functions)
# https://developer.hashicorp.com/terraform/language/functions
# The syntax for a function call is <function_name>(<arg1>, <arg2>)
locals {
  # Date and Time
  ts            = timestamp()
  current_month = formatdate("MMMM", local.ts)
  tomorrow      = formatdate("DD", timeadd(local.ts, "24h"))
}

output "date_time" {
  value = "${local.current_month} ${local.tomorrow}"
}

locals {
  # Numeric
  number_of_buckets_2 = max(local.minimum_number_of_buckets, var.bucket_count)
}

locals {
  # String
  lcase          = lower("A mixed case String")
  ucase          = upper("a lowe case string")
  trimmed        = trimspace(" A string with leading and trailing spaces   ")
  formatted      = format("Hello %s", "World")
  formatted_list = formatlist("Hello %s", ["John", "Paul", "George", "Ringo"])
}

output "string_functions" {
  value = local.formatted_list
}