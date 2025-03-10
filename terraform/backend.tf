terraform {
  backend "s3" {
    bucket = "ilios-tf-backend"
    key    = "ilios-golang-api/terraform.tfstate"
    region = "us-east-1"
  }
}