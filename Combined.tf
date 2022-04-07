
#Security Groups
resource "aws_security_group" "cg-ec2-ssh-security-group" {
  name = "cg-ec2-ssh-${var.cgid}"
  description = "CloudGoat ${var.cgid} Security Group for EC2 Instance over SSH"
  vpc_id = "${aws_vpc.cg-vpc.id}"
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = var.cg_whitelist
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [
          "0.0.0.0/0"
      ]
  }
  tags = {
    Name = "cg-ec2-ssh-${var.cgid}"
    Stack = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
resource "aws_security_group" "cg-ec2-http-security-group" {
  name = "cg-ec2-http-${var.cgid}"
  description = "CloudGoat ${var.cgid} Security Group for EC2 Instance over HTTP"
  vpc_id = "${aws_vpc.cg-vpc.id}"
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = var.cg_whitelist
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [
          "0.0.0.0/0"
      ]
  }
  tags = {
    Name = "cg-ec2-http-${var.cgid}"
    Stack = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
#AWS Key Pair
resource "aws_key_pair" "cg-ec2-key-pair" {
  key_name = "cg-ec2-key-pair-${var.cgid}"
  public_key = "${file(var.ssh-public-key-for-ec2)}"
}
#EC2 Instance
resource "aws_instance" "ec2-vulnerable-proxy-server" {
    ami = "ami-0a313d6098716f372"
    instance_type = "t2.micro"
    iam_instance_profile = "${aws_iam_instance_profile.cg-ec2-instance-profile.name}"
    subnet_id = "${aws_subnet.cg-public-subnet-1.id}"
    associate_public_ip_address = true
    vpc_security_group_ids = [
        "${aws_security_group.cg-ec2-ssh-security-group.id}",
        "${aws_security_group.cg-ec2-http-security-group.id}"
    ]
    key_name = "${aws_key_pair.cg-ec2-key-pair.key_name}"
    root_block_device {
        volume_type = "gp2"
        volume_size = 8
        delete_on_termination = true
    }
    provisioner "file" {
      source = "./assets/proxy.com"
      destination = "/home/ubuntu/proxy.com"
      connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${file(var.ssh-private-key-for-ec2)}"
        host = self.public_ip
      }
    }
    user_data = <<-EOF
        #!/bin/bash
        apt-get update
        apt-get install -y nginx
        ufw allow 'Nginx HTTP'
        cp /home/ubuntu/proxy.com /etc/nginx/sites-enabled/proxy.com
        rm /etc/nginx/sites-enabled/default
        systemctl restart nginx
        EOF
    volume_tags = {
        Name = "CloudGoat ${var.cgid} EC2 Instance Root Device"
        Stack = "${var.stack-name}"
        Scenario = "${var.scenario-name}"
    }
    tags = {
        Name = "ec2-vulnerable-proxy-server-${var.cgid}"
        Stack = "${var.stack-name}"
        Scenario = "${var.scenario-name}"
    }
}
#Secret S3 Bucket
locals {
  # Ensure the bucket suffix doesn't contain invalid characters
  # "Bucket names can consist only of lowercase letters, numbers, dots (.), and hyphens (-)."
  # (per https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html) 
  bucket_suffix = replace(var.cgid, "/[^a-z0-9-.]/", "-")
}

resource "aws_s3_bucket" "cg-cardholder-data-bucket" {
  bucket = "cg-cardholder-data-bucket-${local.bucket_suffix}"
  force_destroy = true
  tags = {
      Name = "cg-cardholder-data-bucket-${local.bucket_suffix}"
      Description = "CloudGoat ${var.cgid} S3 Bucket used for storing sensitive cardholder data."
      Stack = "${var.stack-name}"
      Scenario = "${var.scenario-name}"
  }
}
resource "aws_s3_bucket_object" "cardholder-data-primary" {
  bucket = "${aws_s3_bucket.cg-cardholder-data-bucket.id}"
  key = "cardholder_data_primary.csv"
  source = "./assets/cardholder_data_primary.csv"
  tags = {
    Name = "cardholder-data-${var.cgid}"
    Stack = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
resource "aws_s3_bucket_object" "cardholder-data-secondary" {
  bucket = "${aws_s3_bucket.cg-cardholder-data-bucket.id}"
  key = "cardholder_data_secondary.csv"
  source = "./assets/cardholder_data_secondary.csv"
  tags = {
    Name = "cardholder-data-${var.cgid}"
    Stack = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
resource "aws_s3_bucket_object" "cardholder-data-corporate" {
  bucket = "${aws_s3_bucket.cg-cardholder-data-bucket.id}"
  key = "cardholders_corporate.csv"
  source = "./assets/cardholders_corporate.csv"
  tags = {
    Name = "cardholder-data-${var.cgid}"
    Stack = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
resource "aws_s3_bucket_object" "goat" {
  bucket = "${aws_s3_bucket.cg-cardholder-data-bucket.id}"
  key = "goat.png"
  source = "./assets/goat.png"
  tags = {
    Name = "cardholder-data-${var.cgid}"
    Stack = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

resource "aws_s3_bucket_acl" "cardholder-data-bucket-acl" {
  bucket = aws_s3_bucket.cg-cardholder-data-bucket.id
  acl    = "private"
}
provider "aws" {
  profile = "${var.profile}"
  region = "${var.region}"
}
resource "aws_vpc" "cg-vpc" {
  cidr_block = "10.10.0.0/16"
  enable_dns_hostnames = true
  tags = {
      Name = "CloudGoat ${var.cgid} VPC"
      Stack = "${var.stack-name}"
      Scenario = "${var.scenario-name}"
  }
}
#Internet Gateway
resource "aws_internet_gateway" "cg-internet-gateway" {
  vpc_id = "${aws_vpc.cg-vpc.id}"
  tags = {
      Name = "CloudGoat ${var.cgid} Internet Gateway"
      Stack = "${var.stack-name}"
      Scenario = "${var.scenario-name}"
  }
}
#Public Subnets
resource "aws_subnet" "cg-public-subnet-1" {
  availability_zone = "${var.region}a"
  cidr_block = "10.10.10.0/24"
  vpc_id = "${aws_vpc.cg-vpc.id}"
  tags = {
      Name = "CloudGoat ${var.cgid} Public Subnet #1"
      Stack = "${var.stack-name}"
      Scenario = "${var.scenario-name}"
  }
}
resource "aws_subnet" "cg-public-subnet-2" {
  availability_zone = "${var.region}b"
  cidr_block = "10.10.20.0/24"
  vpc_id = "${aws_vpc.cg-vpc.id}"
  tags = {
      Name = "CloudGoat ${var.cgid} Public Subnet #2"
      Stack = "${var.stack-name}"
      Scenario = "${var.scenario-name}"
  }
}
#Public Subnet Routing Table
resource "aws_route_table" "cg-public-subnet-route-table" {
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.cg-internet-gateway.id}"
  }
  vpc_id = "${aws_vpc.cg-vpc.id}"
  tags = {
      Name = "CloudGoat ${var.cgid} Route Table for Public Subnet"
      Stack = "${var.stack-name}"
      Scenario = "${var.scenario-name}"
  }
}
#Public Subnets Routing Associations
resource "aws_route_table_association" "cg-public-subnet-1-route-association" {
  subnet_id = "${aws_subnet.cg-public-subnet-1.id}"
  route_table_id = "${aws_route_table.cg-public-subnet-route-table.id}"
}
resource "aws_route_table_association" "cg-public-subnet-2-route-association" {
  subnet_id = "${aws_subnet.cg-public-subnet-2.id}"
  route_table_id = "${aws_route_table.cg-public-subnet-route-table.id}"
}

#Required: Always output the AWS Account ID
output "cloudgoat_output_aws_account_id" {
  value = "${data.aws_caller_identity.aws-account-id.account_id}"
}
output "cloudgoat_output_target_ec2_server_ip" {
  value = "${aws_instance.ec2-vulnerable-proxy-server.public_ip}"
}
#Required: AWS Profile
variable "profile" {
  default ="cloudgoat"
}

#Required: AWS Region
variable "region" {
  default = "us-east-1"
}
#Required: CGID Variable for unique naming
variable "cgid" {
  default = "2"
}
#Required: User's Public IP Address(es)
variable "cg_whitelist" {
  default = ["94.255.131.115/32"]
}
#SSH Public Key
variable "ssh-public-key-for-ec2" {
  default = "cloudgoat.pub"
}
#SSH Private Key
variable "ssh-private-key-for-ec2" {
  default = "cloudgoat"
}
#Stack Name
variable "stack-name" {
  default = "CloudGoat"
}
#Scenario Name
variable "scenario-name" {
  default = "cloud-breach-s3"
}
#AWS Account Id
data "aws_caller_identity" "aws-account-id" {

}
#S3 Full Access Policy
data "aws_iam_policy" "s3-full-access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
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