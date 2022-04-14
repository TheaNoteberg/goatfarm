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
  default = [""]
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