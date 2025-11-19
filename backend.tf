terraform {
  backend "s3" {
    bucket       = "terraformbucket-tf496"
    key          = "dev/my-project/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
