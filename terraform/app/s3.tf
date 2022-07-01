resource "aws_s3_bucket" "s3-bucket" {
  bucket = "${local.application}-${var.env}-s3-bucket"
  lifecycle { prevent_destroy = true }

  tags = local.tags
}

resource "aws_s3_bucket_acl" "s3-bucket-acl" {
  bucket = aws_s3_bucket.s3-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "s3-bucket-versioning" {
  bucket = aws_s3_bucket.s3-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-bucket-block-public-access" {
  bucket = aws_s3_bucket.s3-bucket.id

  restrict_public_buckets = true
  block_public_policy = true
}