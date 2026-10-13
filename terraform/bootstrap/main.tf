data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:Younes-22@124288775/adminforge-ecs-project@1270373489:ref:refs/heads/main"
      ]
    }
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

resource "aws_iam_role" "github_ecr" {
  name = "${var.project_name}-github-ecr-role"

  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json
}

resource "aws_iam_role" "github_terraform" {
  name = "${var.project_name}-github-terraform-role"

  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json
}