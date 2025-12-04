terraform {
  backend "s3" {
    bucket       = "myproject-tf-bucket-dev"
    key          = "state/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
