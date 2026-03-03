variable "region" {
  description = "Region to deploy the vpn server in"
  default = "sgp1"
}

variable "instance_type" {
  description = "VPN server instance type"
  default = "s-1vcpu-1gb"
}

variable "do_token" {
  description = "Digital Ocean Personal Access Token"
}
