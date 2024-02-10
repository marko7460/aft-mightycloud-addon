resource "aws_servicecatalog_principal_portfolio_association" "example" {
  portfolio_id  = var.portfolio_id
  principal_arn = module.aft_iam_roles.ct_management_exec_role_arn
  principal_type = "IAM"
}

resource "aws_iam_openid_connect_provider" "mightycloud" {
  provider = aws.aft_management
  url             = "https://securetoken.google.com/${var.project_id}"
  client_id_list  = [var.project_id]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
    "08745487e891c19e3078c1f2a07e452950ef36f6"
  ]
  tags = {
    AddonName = "mightycloud"
  }
}

data "aws_iam_policy_document" "mightycloud_oidc" {
  statement {
    sid    = "MightycloudOidcAuth"
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${var.aft_management_account_id}:oidc-provider/securetoken.google.com/${var.project_id}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.mightycloud.url}:aud"
      values   = [var.project_id]
    }

    dynamic "condition" {
      for_each = length(toset(var.mightycloud_organizations)) > 0 ? [1] : []
      content {
        test     = "StringEquals"
        variable = "${aws_iam_openid_connect_provider.mightycloud.url}:organization"
        values   = toset(var.mightycloud_organizations)
      }
    }

    dynamic "condition" {
      for_each = length(toset(var.mightycloud_uids)) > 0 ? [1] : []
      content {
        test     = "StringEquals"
        variable = "${aws_iam_openid_connect_provider.mightycloud.url}:sub"
        values   = toset(var.mightycloud_uids)
      }
    }

    dynamic "condition" {
      for_each = length(toset(var.mightycloud_architectures)) > 0 ? [1] : []
      content {
        test     = "StringEquals"
        variable = "${aws_iam_openid_connect_provider.mightycloud.url}:architecture"
        values   = toset(var.mightycloud_architectures)
      }
    }
  }
}

resource "aws_iam_role" "mightycloud_oidc" {
  provider = aws.aft_management
  name        = var.mightycloud_name
  path        = var.mightycloud_path
  description = "Role that allows mightycloud hyperautomation to use OIDC to authenticate users and assume AFT roles"

  assume_role_policy    = data.aws_iam_policy_document.mightycloud_oidc.json
  max_session_duration  = var.mightycloud_max_session_duration
  permissions_boundary  = var.mightycloud_permissions_boundary_arn
  force_detach_policies = var.mightycloud_force_detach_policies

  tags = {
    "Addon" = "mightycloud"
  }
}

resource "aws_iam_role_policy_attachment" "mightycloud-oidc-policy-attachment" {
  provider = aws.aft_management
  role       = aws_iam_role.mightycloud_oidc.name
  policy_arn = aws_iam_policy.mightycloud-policy.arn
}

data "aws_iam_policy_document" "mightycloud-policy-definition" {
  statement {
    sid       = "MightyCloudAFTRoleAssume"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::*:role/AWSAFTAdmin"]
  }
}

resource "aws_iam_policy" "mightycloud-policy" {
  provider = aws.aft_management
  name        = "mightycloud-aft-hyperautomation-policy"
  description = "Policy used by mightycloud automation for admin access"
  policy      = data.aws_iam_policy_document.mightycloud-policy-definition.json
}

output "mightycloud_hyperautomation_role_arn" {
  description = "The ARN of the role that allows mightycloud hyperautomation to use OIDC to authenticate users and assume AFT roles"
  value       = aws_iam_role.mightycloud_oidc.arn
}