terraform {
  backend "s3" {
    bucket       = "auth-service-tf-bucket"
    key          = "dev/auth-service-dev.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
