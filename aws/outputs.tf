output "instance_ip" {
  value = aws_instance.vpn-factory-server.public_ip
}

output "ssh_keypair_name" {
  value = var.keypair_name
}

output "randomized_ports" {
  value = [
    random_shuffle.vpn_ports.result[0],
    random_shuffle.vpn_ports.result[1],
    random_shuffle.vpn_ports.result[2]
  ]
}
