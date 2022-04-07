#IAM Users
resource "aws_iam_user" "cg-raynor" {
  name = "raynor-${var.cgid}"
  tags = {
    Name     = "cg-raynor-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

#IAM User Policies
resource "aws_iam_policy" "cg-raynor-policy" {
  name        = "cg-raynor-policy-${var.cgid}"
  description = "cg-raynor-policy"
  policy      = "${file("./terraform/IAM/policies/v1.json")}"
}

#IAM Policy Attachments
resource "aws_iam_user_policy_attachment" "cg-raynor-attachment" {
  user       = "${aws_iam_user.cg-raynor.name}"
  policy_arn = "${aws_iam_policy.cg-raynor-policy.arn}"
}


resource "null_resource" "cg-create-iam-user-policy-version-2" {
  provisioner "local-exec" {
      command = "aws iam create-policy-version --policy-arn ${aws_iam_policy.cg-raynor-policy.arn} --policy-document file://../assets/policies/v2.json --no-set-as-default --profile ${var.profile} --region ${var.region}"
  }
}
resource "null_resource" "cg-create-iam-user-policy-version-3" {
  provisioner "local-exec" {
      command = "aws iam create-policy-version --policy-arn ${aws_iam_policy.cg-raynor-policy.arn} --policy-document file://../assets/policies/v3.json --no-set-as-default --profile ${var.profile} --region ${var.region}"
  }
}
resource "null_resource" "cg-create-iam-user-policy-version-4" {
  provisioner "local-exec" {
      command = "aws iam create-policy-version --policy-arn ${aws_iam_policy.cg-raynor-policy.arn} --policy-document file://../assets/policies/v4.json --no-set-as-default --profile ${var.profile} --region ${var.region}"
  }
}
resource "null_resource" "cg-create-iam-user-policy-version-5" {
  provisioner "local-exec" {
      command = "aws iam create-policy-version --policy-arn ${aws_iam_policy.cg-raynor-policy.arn} --policy-document file://../assets/policies/v5.json --no-set-as-default --profile ${var.profile} --region ${var.region}"
  }
}