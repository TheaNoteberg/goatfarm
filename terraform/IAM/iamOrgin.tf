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

#IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "cg-banking-WAF-Role-policy-attachment-s3" {
  role = "${aws_iam_role.cg-banking-WAF-Role.name}"
  policy_arn = "${data.aws_iam_policy.s3-full-access.arn}"
}

#IAM Instance Profile
resource "aws_iam_instance_profile" "cg-ec2-instance-profile" {
  name = "cg-ec2-instance-profile-${var.cgid}"
  role = "${aws_iam_role.cg-banking-WAF-Role.name}"
}