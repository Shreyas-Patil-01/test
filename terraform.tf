terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  # Using local state instead of S3 backend
  # State will be stored in the GitHub Actions runner during execution
}