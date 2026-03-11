//Generate uuid for seeding
resource "random_uuid" "seed" {}

//For resource names
resource "random_id" "suffix" {
  byte_length = 4
}

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
  name = "vpn-factory-key-${random_id.suffix.hex}"
  public_key = file("../ssh-keys/vpn-factory-key.pub")
}

resource "digitalocean_droplet" "vpn-factory-server" {
  image = "ubuntu-24-04-x64"
  name = "vpn-factory-server-${random_id.suffix.hex}"
  region = var.region
  size = var.instance_type
  ssh_keys = [digitalocean_ssh_key.vpn-factory-key.fingerprint]
}

resource "digitalocean_firewall" "vpn-factory-firewall" {
  name = "vpn-factory-firewall-${random_id.suffix.hex}"
  droplet_ids = [digitalocean_droplet.vpn-factory-server.id]

  // SSH
  inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  // VPN ports
  dynamic "inbound_rule" {
    for_each = setproduct(slice(random_shuffle.vpn_ports.result, 0, 3), ["tcp", "udp"])
    content {
      port_range = inbound_rule.value[0]
      protocol = inbound_rule.value[1]
      source_addresses = ["0.0.0.0/0", "::/0"]
    }
  }
  
  // All outbound allow
  dynamic "outbound_rule" {
    for_each = ["tcp", "udp", "icmp"]
    content {
      port_range = outbound_rule.value == "icmp" ? null : "1-65535"
      protocol = outbound_rule.value
      destination_addresses = ["0.0.0.0/0", "::/0"]
    }
  }
}

