resource "aws_iam_role" "iam_role" {
  name               = var.role_name
  description        = var.role_description
  assume_role_policy = var.assume_role_policy
}



resource "aws_iam_policy" "iam_policy" {
  name        = var.policy_name
  description = var.policy_description
  policy      = var.policy_content
}



resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}