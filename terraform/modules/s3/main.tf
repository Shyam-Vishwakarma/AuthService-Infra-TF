resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = merge(
    var.tags, {
      Environment = var.environment
      Project     = var.project_name
  })
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = var.versioning_status
  }
}
