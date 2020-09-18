terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "tf-test-d7d89193-84f4-903b-ff61-5cef9e565e11-backend"
    key = "terraform/webapp/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

//terraform {
//  backend "remote" {
//    hostname     = "app.terraform.io"
//    organization = "wallex"
//
//    workspaces {
//      name = "learn-terraform-circleci"
//    }
//  }
//}

provider "aws" {
  region = var.region
//  region = "ap-southeast-1"
}

provider "template" {
}

resource "aws_iam_user" "circleci" {
  name = var.user
  path = "/system/"
}

resource "aws_iam_access_key" "circleci" {
  user = aws_iam_user.circleci.name
}

data "template_file" "circleci_policy" {
  template = file("circleci_s3_access.tpl.json")
  vars = {
    s3_bucket_arn = aws_s3_bucket.portfolio.arn
  }
}

resource "local_file" "circle_credentials" {
  filename = "tmp/circleci_credentials"
  content  = "${aws_iam_access_key.circleci.id}\n${aws_iam_access_key.circleci.secret}"
}

resource "aws_iam_user_policy" "circleci" {
  name   = "AllowCircleCI"
  user   = aws_iam_user.circleci.name
  policy = data.template_file.circleci_policy.rendered
}

resource "aws_s3_bucket" "portfolio" {
  tags = {
    Name = "Portfolio Website Bucket"
  }

  bucket = "${var.app}.${var.label}"
  acl    = "public-read"

  website {
    index_document = "${var.app}.html"
    error_document = "error.html"
  }
  force_destroy = true

}

output "Endpoint" {
  value = aws_s3_bucket.portfolio.website_endpoint
}
