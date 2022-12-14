resource "aws_s3_bucket" "example" {
  bucket = "aws-ab3-bucket-ibanov-${var.aws_region}"
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.example.id
  acl    = "private"
}

resource "aws_ecr_repository" "sample" {
  for_each             = toset(var.registries)
  name                 = "${var.app_name}-${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_iam_role" "example" {
  name = "example"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "example" {
  role = aws_iam_role.example.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.example.arn}",
        "${aws_s3_bucket.example.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "example" {
  for_each = toset(["dev", "homol", "prod", "security"])

  name          = "${each.key}-test-project"
  description   = "test_codebuild_project"
  build_timeout = "15"
  service_role  = aws_iam_role.example.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true
    environment_variable {
        name = "AWS_DEFAULT_REGION"
        value = var.aws_region
      }
    environment_variable {
        name = "AWS_ACCOUNT_ID"
        value = data.aws_caller_identity.current.id
     }
    environment_variable {
        name = "IMAGE_REPO_NAME"
        value = "${var.app_name}-${each.key}"
      }

  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/iagobanov/sample-app-repo.git"
    git_clone_depth = 1
    buildspec  = file("./${each.key}-buildspec.yaml")


    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "main"

  tags = {
    Environment = "Test"
  }
}


