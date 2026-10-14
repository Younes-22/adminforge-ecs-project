data "aws_caller_identity" "current" {}

locals {
  ecr_repository_arn = "arn:aws:ecr:eu-west-2:${data.aws_caller_identity.current.account_id}:repository/${var.ecr_repository_name}"

  terraform_state_bucket = "adminforge-terraform-state-872450837551-eu-west-2"
  terraform_state_key    = "adminforge/terraform.tfstate"
}

# ECR role

data "aws_iam_policy_document" "github_ecr" {
  statement {
    sid       = "GetEcrAuthorizationToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "PushImageToAdminForgeRepository"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [local.ecr_repository_arn]
  }
}

resource "aws_iam_policy" "github_ecr" {
  name        = "${var.project_name}-github-ecr-policy"
  description = "Permissions for GitHub Actions to push the Admin Forge image to ECR"
  policy      = data.aws_iam_policy_document.github_ecr.json
}

resource "aws_iam_role_policy_attachment" "github_ecr" {
  role       = aws_iam_role.github_ecr.name
  policy_arn = aws_iam_policy.github_ecr.arn
}

# Terraform role

data "aws_iam_policy_document" "github_terraform" {
  statement {
    sid    = "ManageInfrastructure"
    effect = "Allow"

    actions = [
      "ec2:*",
      "ecs:*",
      "elasticloadbalancing:*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageEcrRepository"
    effect = "Allow"

    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetLifecyclePolicy",
      "ecr:GetRepositoryPolicy",
      "ecr:ListTagsForResource",
      "ecr:PutImageScanningConfiguration",
      "ecr:PutImageTagMutability",
      "ecr:SetRepositoryPolicy",
      "ecr:TagResource",
      "ecr:UntagResource"
    ]

    resources = [local.ecr_repository_arn]
  }

  statement {
    sid    = "CreateEcrRepository"
    effect = "Allow"

    actions = [
      "ecr:CreateRepository",
      "ecr:DescribeRepositories"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageEcsExecutionRole"
    effect = "Allow"

    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DetachRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:PassRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecs-task-execution-role",
      "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    ]
  }

  statement {
    sid       = "ManageLogs"
    effect    = "Allow"
    actions   = ["logs:*"]
    resources = ["*"]
  }

  statement {
    sid    = "ManageCertificates"
    effect = "Allow"

    actions = [
      "acm:AddTagsToCertificate",
      "acm:DeleteCertificate",
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:ListTagsForCertificate",
      "acm:RequestCertificate"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageDnsRecords"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:GetChange",
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource"
    ]

    resources = ["*"]
  }

  statement {
    sid       = "AccessTerraformStateBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${local.terraform_state_bucket}"]
  }

  statement {
    sid    = "AccessTerraformStateObject"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::${local.terraform_state_bucket}/${local.terraform_state_key}",
      "arn:aws:s3:::${local.terraform_state_bucket}/${local.terraform_state_key}.tflock"
    ]
  }
}

resource "aws_iam_policy" "github_terraform" {
  name        = "${var.project_name}-github-terraform-policy"
  description = "Permissions for GitHub Actions to deploy the Admin Forge infrastructure"
  policy      = data.aws_iam_policy_document.github_terraform.json
}

resource "aws_iam_role_policy_attachment" "github_terraform" {
  role       = aws_iam_role.github_terraform.name
  policy_arn = aws_iam_policy.github_terraform.arn
}
