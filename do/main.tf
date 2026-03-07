//Generate uuid for seeding
resource "random_uuid" "seed" {}

//Get random port numbers for outline and ovpn
locals {
  start_port = 49152
  end_port   = 65536
  block_size = 1024

  block_starts = [for s in range(local.start_port, local.end_port, local.block_size) : s]

  port_pool = flatten([
    for s in local.block_starts :
    range(s, min(s + local.block_size, local.end_port))
  ])

  port_strings = [for p in local.port_pool : tostring(p)]
}

//Shuffle the list and get 3 results
resource "random_shuffle" "vpn_ports" {
  input        = sensitive(local.port_strings)
  result_count = 3

  keepers = {
    seed = random_uuid.seed.result
  }
}

resource "digitalocean_ssh_key" "vpn-factory-key" {
  name = "vpn-factory-key"
  public_key = file("../ssh-keys/vpn-factory-key.pub")
}

resource "digitalocean_droplet" "vpn-factory-server" {
  image = "ubuntu-24-04-x64"
  name = "cloud-vpn-server"
  region = var.region
  size = var.instance_type
  ssh_keys = [digitalocean_ssh_key.vpn-factory-key.fingerprint]
}

resource "digitalocean_firewall" "vpn-factory-firewall" {
  name = "vpn-factory-ports"

  droplet_ids = [digitalocean_droplet.vpn-factory-server.id]

  // SSH
  inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_addresses = [ "0.0.0.0/0", "::/0" ]
  }

  // VPN ports
  inbound_rule {
    protocol = "tcp"
    port_range = random_shuffle.vpn_ports.result[0]
    source_addresses = [ "0.0.0.0/0", "::/0" ]
  }

  inbound_rule {
    protocol = "udp"
    port_range = random_shuffle.vpn_ports.result[0]
    source_addresses = [ "0.0.0.0/0", "::/0" ]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = random_shuffle.vpn_ports.result[1]
    source_addresses = [ "0.0.0.0/0", "::/0" ]
  }

  inbound_rule {
    protocol = "udp"
    port_range = random_shuffle.vpn_ports.result[1]
    source_addresses = [ "0.0.0.0/0", "::/0" ]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = random_shuffle.vpn_ports.result[2]
    source_addresses = [ "0.0.0.0/0", "::/0" ]
  }

  inbound_rule {
    protocol = "udp"
    port_range = random_shuffle.vpn_ports.result[2]
    source_addresses = [ "0.0.0.0/0", "::/0" ]
  }
  
  // All outbound allow
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

