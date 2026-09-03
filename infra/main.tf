# Infraestructura de ejemplo (demo).
# Versión base segura. Las ramas de feature introducirán variantes con
# problemas intencionales para demostrar el gate de Copilot code review.

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "customer_uploads" {
  bucket = "demo-customer-uploads"

  tags = {
    owner       = "payments-team"
    environment = "demo"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "customer_uploads" {
  bucket = aws_s3_bucket.customer_uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
