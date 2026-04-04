terraform {
  backend "s3" {
    bucket         = "ascendoai-assessment-terraform-state-1775273555"
    key            = "ascendoai/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true

  }
}