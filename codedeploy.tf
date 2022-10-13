# Required Roles
## Common
### AWS managed policies
data "aws_iam_policy" "aws_codedeploy_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

data "aws_iam_policy" "aws_s3_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

data "aws_iam_policy" "aws_codedeploy_full_access" {
  arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}

### Trusted entities
data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codedeploy_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

## Roles
### EC2 role
resource "aws_iam_role" "ec2_role" {
  name               = "elon-kiosk-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "grant_s3_to_ec2" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = data.aws_iam_policy.aws_s3_full_access.arn
}

resource "aws_iam_role_policy_attachment" "grant_codedeploy_to_ec2" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = data.aws_iam_policy.aws_codedeploy_full_access.arn
}

resource "aws_iam_role_policy_attachment" "grant_codedeployrole_to_ec2" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = data.aws_iam_policy.aws_codedeploy_role.arn
}

### CodeDeploy role
resource "aws_iam_role" "codedeploy_role" {
  name               = "elon-kiosk-codedeploy-role"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "grant_codedeployrole_to_codedeploy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = data.aws_iam_policy.aws_codedeploy_role.arn
}

# CodeDeploy
resource "aws_codedeploy_app" "codedeploy_be" {
  compute_platform = "Server"
  name             = "elon-kiosk"
}

resource "aws_codedeploy_deployment_group" "codedeploy_be_dpy_group" {
  app_name              = aws_codedeploy_app.codedeploy_be.name
  deployment_group_name = "elon-kiosk-codedeploy-be-deployment-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      type  = "KEY_AND_VALUE"
      key   = "Tier"
      value = "api-server-layer"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
