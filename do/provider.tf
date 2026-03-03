terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.73"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}
