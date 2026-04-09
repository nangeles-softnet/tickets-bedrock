resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "tickets-bedrock-artifacts-${random_id.bucket_suffix.hex}"
  
  # For PoC purposes, we'll allow easy cleanup
  force_destroy = true

  tags = {
    Environment = "PoC"
    Project     = "TicketsBedrock"
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts_block" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "artifacts_versioning" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}
