variable "project" {
  description = "Project ID"
}

variable "region" {
  description = "Region to deploy the resources in"
  default = "us-central1"
}

variable "instance_type" {
  description = "instance type of the cloud-vpn-server"
  default = "e2-micro"
}

variable "gl_user" {
  type = string
  description = "gitlab user for backend"
}

variable "gl_pat" {
  type = string
  description = "gitlab pat for backend"
}
