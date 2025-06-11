resource "aws_iam_policy" "alb_policy" {
  name        = "${local.name}-${var.environment_identifier}-alb-policy"
  description = "Allow ALB to access EKS"
  policy      = file("files/iam_policy.json")
}