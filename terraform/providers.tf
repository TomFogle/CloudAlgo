#
# Provider Configuration
#

provider "aws" {
  region = "us-east-1"
}

# Using these data sources to allow for the configuration to be
# generic for any region.
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

provider "http" {}