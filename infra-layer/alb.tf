resource "aws_iam_policy" "alb_policy" {
  name        = "${local.name}-alb-policy"
  description = "Allow ALB to access ECS"
  policy = file("files/iam_policy.json")
}