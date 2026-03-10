output "instance_ip" {
  value = google_compute_instance.vpn-factory-server.network_interface[0].access_config[0].nat_ip
}

output "randomized_ports" {
  value = [
    random_shuffle.vpn_ports.result[0],
    random_shuffle.vpn_ports.result[1],
    random_shuffle.vpn_ports.result[2]
  ]
}
