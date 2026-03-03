variable "instance_type" {
  default = "t2.micro"
  type = string
}

variable "region" {
  default = "ap-southeast-1"
  type = string
}

variable "gl_user" {
  type = string
  description = "gitlab user for backend"
}

variable "gl_pat" {
  type = string
  description = "gitlab pat for backend"
}

variable "access_key" {
  type = string
  description = "aws access key"
}

variable "secret_key" {
  type = string
  description = "aws secret key"
}

variable "vpc_cidr" {
  default = "10.255.255.0/24"
  type = string
  description = "VPC cidr /24"
}
