# Each resource here must fail exactly one custom check in .github/checkov.

resource "aws_iam_role" "root_without_condition" {
  name = "fail-root"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = "sts:AssumeRole", Principal = { AWS = "arn:aws:iam::111122223333:root" } }]
  })
}

data "aws_iam_policy_document" "bare_account_id" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["111122223333"]
    }
  }
}

resource "aws_ram_resource_share" "external_allowed" {
  name                      = "fail-external"
  allow_external_principals = true
}

resource "aws_ecr_repository" "without_lifecycle" {
  name = "fail-without-lifecycle"
}

resource "aws_elasticache_replication_group" "default_subnet_group" {
  replication_group_id = "fail-default-subnet-group"
  description          = "fail"
}
