module "s3" {
  source            = "../../modules/s3"
  project_name      = var.project_name
  bucket_name       = "auth-service-dev-releases"
  versioning_status = "Enabled"
}
