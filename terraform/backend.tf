terraform {
  backend "s3" {
    bucket         = "meetlyomni-tf-state-bucket-dev"  
    key            = "dev/terraform.tfstate"        
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks-dev"
    encrypt        = true
  }
}
