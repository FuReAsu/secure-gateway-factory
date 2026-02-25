//Generate uuid for seeding
resource "random_uuid" "seed" {}

//Get ami id
data "aws_ami" "ubuntu" {
  owners = ["099720109477"]
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
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

//Create Keypair
resource "aws_key_pair" "vpn-factory-key" {
  key_name = var.keypair_name
  public_key = file("../ssh-keys/vpn-factory-key.pub")
}

//VPC & Networking
resource "aws_vpc" "vpn-factory-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "vpn-factory-vpc"
  }
}

resource "aws_subnet" "vpn-factory-subnet" {
  vpc_id = aws_vpc.vpn-factory-vpc.id
  cidr_block = var.vpc_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "vpn-factory-subnet"
  }
}

resource "aws_internet_gateway" "vpn-factory-igw" {
  vpc_id = aws_vpc.vpn-factory-vpc.id
  tags = {
    Name = "vpn-factory-igw"
  }
}

resource "aws_route_table" "vpn-factory-rtb" {
  vpc_id = aws_vpc.vpn-factory-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpn-factory-igw.id
  }
  tags = {
    Name = "vpn-factory-rtb"
  }
}

resource "aws_route_table_association" "vpn-factory-rtb-asso" {
  subnet_id = aws_subnet.vpn-factory-subnet.id
  route_table_id = aws_route_table.vpn-factory-rtb.id
}

resource "aws_security_group" "vpn-factory-sg" {
  name = "vpn-factory-sg"
  description = "SG for VPN server"
  vpc_id = aws_vpc.vpn-factory-vpc.id
  tags = {
    Name = "vpn-factory-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-ssh-ing" {
  security_group_id = aws_security_group.vpn-factory-sg.id
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allow-all-eg" {
  security_group_id = aws_security_group.vpn-factory-sg.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

//Ingress rules for randomized ports
resource "aws_vpc_security_group_ingress_rule" "vpn_ingress" {
  count = 6

  security_group_id = aws_security_group.vpn-factory-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  
  ip_protocol = count.index % 2 == 0 ? "tcp" : "udp"

  from_port = random_shuffle.vpn_ports.result[floor(count.index / 2)]
  to_port   = random_shuffle.vpn_ports.result[floor(count.index / 2)]
}

//EC2 Instance
resource "aws_instance" "vpn-factory-server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.vpn-factory-subnet.id
  vpc_security_group_ids = [aws_security_group.vpn-factory-sg.id]
  key_name = var.keypair_name
  tags = {
    Name = "vpn-factory-server"
  }
  lifecycle {
    ignore_changes = [ami]
  }
}
