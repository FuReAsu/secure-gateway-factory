//Generate uuid for seeding
resource "random_uuid" "seed" {}

//For resource names
resource "random_id" "suffix" {
  byte_length = 4
}

//Get available zones
data "google_compute_zones" "available" {
  status = "UP"
}

//Get Ubuntu image
data "google_compute_image" "ubuntu-2404" {
  family = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

//VPC with random ID
resource "google_compute_network" "vpn-factory-vpc" {
  name = "vpn-factory-vpc-${random_id.suffix.hex}"
  auto_create_subnetworks = true
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

//Get username from ssh public key
locals {
  public_key_content = trimspace(file("../ssh-keys/vpn-factory-key.pub"))
  key_parts = split(" ", local.public_key_content)
  detected_user_string = element(local.key_parts, length(local.key_parts) - 1)
  detected_user = split("@", local.detected_user_string)[0]
}

//Compute instance
resource "google_compute_instance" "vpn-factory-server" {
  name = "vpn-factory-server-${random_id.suffix.hex}"
  machine_type = var.instance_type
  zone = data.google_compute_zones.available.names[0]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu-2404.self_link
      type = "pd-standard"
      size = 20
    }
  }

  resource_policies = []

  network_interface {
    network = google_compute_network.vpn-factory-vpc.id
    access_config {
    }
  }
  can_ip_forward = true
  tags = [
    "vpn-factory-server-${random_id.suffix.hex}"
  ]
  allow_stopping_for_update = false

  metadata = {
    enable-oslogin = "FALSE"
    block-project-ssh-keys = "TRUE"
    ssh-keys = "${local.detected_user}:${local.public_key_content}"
  }

  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image]
  }
}

//SSH Access
resource "google_compute_firewall" "vpn-factory-firewall" {
  name = "vpn-factory-firewall-${random_id.suffix.hex}"
  network = google_compute_network.vpn-factory-vpc.id
  description = "Allow vpn-factory ssh"
  direction = "INGRESS"
  priority = 100

  source_ranges = ["0.0.0.0/0"]

  target_tags = [
    "vpn-factory-server-${random_id.suffix.hex}"
  ]
  
  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  allow {
    protocol = "tcp"
    ports = slice(random_shuffle.vpn_ports.result, 0, 3)
  }

  allow {
    protocol = "udp"
    ports = slice(random_shuffle.vpn_ports.result, 0, 3)
  }
}
