resource "digitalocean_ssh_key" "vpn-factory-key" {
  name = "vpn-factory-key"
  public_key = file("../ssh-keys/vpn-factory-key.pub")
}

resource "digitalocean_droplet" "vpn-factory-key" {
  image = "ubuntu-24-04-x64"
  name = "cloud-vpn-server"
  region = var.region
  size = var.instance_type
  ssh_keys = [digitalocean_ssh_key.vpn-factory-key.fingerprint]
}
