terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "01535325-2b87-3c79-b86f-e9c07720cc11-backend"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }
  # Partial configuration - define parameters on command line with terraform init
//  backend "s3" {}
}

provider "aws" {
  region  = var.region
  profile = "wallex-dev"
}

provider "template" {
}

resource "random_uuid" "randomid" {}

//resource "aws_iam_user" "circleci" {
//  name = var.user
//  path = "/system/"
//}

//resource "aws_iam_access_key" "circleci" {
//  user = aws_iam_user.circleci.name
//}

//data "template_file" "circleci_policy" {
//  template = file("circleci_s3_access.tpl.json")
//  vars = {
//    s3_bucket_arn = aws_s3_bucket.app.arn
//  }
//}

//resource "local_file" "circle_credentials" {
//  filename = "tmp/circleci_credentials"
//  content  = "${aws_iam_access_key.circleci.id}\n${aws_iam_access_key.circleci.secret}"
//}

//resource "aws_iam_user_policy" "circleci" {
//  name   = "AllowCircleCI"
//  user   = aws_iam_user.circleci.name
//  policy = data.template_file.circleci_policy.rendered
//}

resource "aws_s3_bucket" "app" {
  tags = {
    Name = "App Bucket"
  }

  bucket = "${var.app}.${var.label}.${random_uuid.randomid.result}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  force_destroy = true

}

resource "aws_s3_bucket_object" "app" {
  acl          = "public-read"
  key          = "index.html"
  bucket       = aws_s3_bucket.app.id
  content      = file("./assets/index.html")
  content_type = "text/html"

}

output "Endpoint" {
  value = aws_s3_bucket.app.website_endpoint
}
