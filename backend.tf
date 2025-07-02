terraform {
  backend "s3" {
    bucket = "backend-s3-2323"
    key    = "backend/terraform.tfstate"
    region = "us-east-1"
  }
}