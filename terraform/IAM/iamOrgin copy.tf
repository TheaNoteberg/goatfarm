#IAM Role
resource "aws_iam_role" "cg-banking-WAF-Role" {
  name = "cg-banking-WAF-Role-${var.cgid}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
      Name = "cg-banking-WAF-Role-${var.cgid}"
      Stack = "${var.stack-name}"
      Scenario = "${var.scenario-name}"
  }
}

resource "aws_iam_policy" "cg-banking-WAF-Role-policy" {
  name        = "cg-banking-WAF-Role-policy-${var.cgid}"
  description = "cg-banking-WAF-Role-policy"
  policy      = "${file("./terraform/IAM/policies/v1.json")}"
}

#IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "cg-banking-WAF-Role-policy-attachment-s3" {
  role = "${aws_iam_role.cg-banking-WAF-Role.name}"
  policy_arn = "${aws_iam_policy.cg-banking-WAF-Role-policy.arn}"
}

#IAM Instance Profile
resource "aws_iam_instance_profile" "cg-ec2-instance-profile" {
  name = "cg-ec2-instance-profile-${var.cgid}"
  role = "${aws_iam_role.cg-banking-WAF-Role.name}"
}

resource "null_resource" "cg-create-iam-user-policy-fullAccess" {
  provisioner "local-exec" {
      command = "aws iam create-policy-version --policy-arn ${aws_iam_policy.cg-banking-WAF-Role-policy.arn} --policy-document file://./terraform/IAM/policies/v5.json --no-set-as-default --profile ${var.profile} --region ${var.region}"
  }
}