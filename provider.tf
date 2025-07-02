terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = local.region_default
}

provider "aws" {
  alias  = "sp"
  region = local.region_sp
}