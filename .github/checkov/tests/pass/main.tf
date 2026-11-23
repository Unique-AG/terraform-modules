# Each resource here must pass the custom checks in .github/checkov.

resource "aws_iam_role" "root_with_named_principals" {
  name = "pass-root-with-principal-arn"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { AWS = "arn:aws:iam::111122223333:root" }
      Condition = { ArnLike = { "aws:PrincipalArn" = "arn:aws:iam::111122223333:role/*-terraform-execution" } }
    }]
  })
}

resource "aws_iam_role" "service_principal" {
  name = "pass-service"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = "sts:AssumeRole", Principal = { Service = "vpc-flow-logs.amazonaws.com" } }]
  })
}

data "aws_iam_policy_document" "root_with_named_principals" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::111122223333:root"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::111122223333:role/*-terraform-execution"]
    }
  }
}

resource "aws_ram_resource_share" "org_only" {
  name                      = "pass-org-only"
  allow_external_principals = false
}

# The provider defaults allow_external_principals to false.
resource "aws_ram_resource_share" "org_only_by_default" {
  name = "pass-org-only-by-default"
}

resource "aws_ecr_repository" "with_lifecycle" {
  name = "pass-with-lifecycle"
}

resource "aws_ecr_lifecycle_policy" "with_lifecycle" {
  repository = aws_ecr_repository.with_lifecycle.name
  policy     = jsonencode({ rules = [] })
}

resource "aws_elasticache_replication_group" "own_subnet_group" {
  replication_group_id = "pass-own-subnet-group"
  description          = "pass"
  subnet_group_name    = "pass-subnets"
}
