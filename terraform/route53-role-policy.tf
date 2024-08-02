# Retrieves the current AWS account ID to dynamically reference it in the policy document
data "aws_caller_identity" "current" {}

# Policy document for the Route53CertManagerPolicy
data "aws_iam_policy_document" "route53_policy" {
  version = "2012-10-17"
    statement {
      effect = "Allow"
      actions = ["route53:GetChange"]
      resources = ["arn:aws:route53:::change/*"]
    }
    statement {
      effect = "Allow"
      actions = ["route53:ListHostedZones"]
      resources = ["*"]
    }
    statement {
      effect = "Allow"
      actions = [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ]
      resources = ["arn:aws:route53:::hostedzone/*"]
    }
    statement {
      effect = "Allow"
      actions = [ 
        "route53:ListHostedZonesByName",
        "sts:AssumeRoleWithWebIdentity"
      ]
      resources = ["*"]
    }
}

# Create an IAM policy for Route53 that grants the necessary permissions for managing Route 53 DNS records based on the above policy document
resource "aws_iam_policy" "route53cmpolicy" {
  name = "Route53CertManagerPolicy"
  policy = data.aws_iam_policy_document.route53_policy.json
}

# Strip the "https://" prefix from the OIDC issuer URL
locals {
  cluster_oidc_issuer = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
}

# Trust relationship policy document for the Route53CertManagerRole we will create
data "aws_iam_policy_document" "oidc_assume_role" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.cluster_oidc_issuer}"]
    }
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    condition {
      test     = "StringEquals"
      variable = "${local.cluster_oidc_issuer}:sub"
      values   = [
        "system:serviceaccount:${var.namespace}:${var.service_account_name}"
      ]
    }
    
    condition {
      test     = "StringEquals"
      variable = "${local.cluster_oidc_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# Create IAM Role for service account
resource "aws_iam_role" "Route53CertManagerRole" {
  name               = "Route53CertManagerRole"
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role.json
}

# Attach the Route53CertManagerPolicy to the Route53CertManagerRole
resource "aws_iam_role_policy_attachment" "Route53CertManager" {
  role = aws_iam_role.Route53CertManagerRole.name
  policy_arn = aws_iam_policy.route53cmpolicy.arn
}