terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.17.1"
    }
  }
}

provider "aws" {
  profile = "elon-kiosk"
  region  = "ap-northeast-2"
}
