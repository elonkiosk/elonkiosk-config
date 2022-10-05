terraform {
  backend "s3" {
    bucket          = "admin-tfstate-bucket"
    key             = "elon-kiosk-tfstate"
    region          = "ap-northeast-2"
    dynamodb_table  = "admin-tfstate-locking"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.17.1"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
}
