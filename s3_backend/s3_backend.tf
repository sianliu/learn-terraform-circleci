terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "ap-southeast-1"
  profile = "wallex-dev"
}

resource "random_uuid" "randomid" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${random_uuid.randomid.result}-backend"
  # Enable versioning so we can see the full revision history of our
  # state files
  force_destroy = true
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "wallex-dev-bucket-policy" {
  depends_on = [aws_s3_bucket.terraform_state]
  bucket     = aws_s3_bucket.terraform_state.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Effect : "Allow",
          Action : "s3:ListBucket",
          Resource : "arn:aws:s3:::mybucket"
          Principal = {
            //            AWS = "arn:aws:iam::821353914239:role/OrganizationAccountAccessRole"
            AWS = "arn:aws:iam::821353914239:user/jonathan"
          }
        },
        {
          Effect : "Allow",
          Action : ["s3:GetObject", "s3:PutObject"],
          Resource : "arn:aws:s3:::mybucket/path/to/my/key"
          Principal = {
            AWS = "arn:aws:iam::821353914239:role/OrganizationAccountAccessRole"
            //            AWS = "arn:aws:iam::821353914239:user/jonathan"
          }
        }
      ]
    }
  )
}

output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}
