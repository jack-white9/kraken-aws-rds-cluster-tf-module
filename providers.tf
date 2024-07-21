terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.48.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      Module = "aws_rds_cluster"
    }
  }
}
