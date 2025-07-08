# IAM Role for Karpenter
data "aws_iam_policy_document" "kp_assume" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [ replace(var.oidc_issuer, "https://", "") ]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }
  }
}

resource "aws_iam_role" "karpenter" {
  name               = "${var.cluster_name}-karpenter-role"
  assume_role_policy = data.aws_iam_policy_document.kp_assume.json
}

resource "aws_iam_role_policy_attachment" "karpenter_controller" {
  role       = aws_iam_role.karpenter.name
  policy_arn = "arn:aws:iam::aws:policy/KarpenterControllerPolicy"
}

output "karpenter_role_arn" {
  value = aws_iam_role.karpenter.arn
}
