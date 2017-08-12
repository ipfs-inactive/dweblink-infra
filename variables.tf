variable "domain_name" {
  default = "dweblink.net"
}

variable "image" {
  default = "ubuntu1604"
}

variable "hosts_tag" {
  default = "protocollabs"
}

variable "use_public_ipv4s" {
  default = false
}

variable "private_network" {
  default = "10.42.0.0/15"
}

variable "vpn_routes" {
  default = "10.42.0.0/16"
}

variable "vpn_network" {
  default = "10.43.0.0/16"
}

variable "vpn_data_dir" {
  default = "/opt/openvpn-data/vpn.dweblink.net"
}

variable "vpn_data_src" {
  default = "./secrets/openvpn-data"
}

data "external" "vpn_data_changed" {
  program = ["sh", "-c", "jq -n --arg changed \"$(tar -c ./secrets/openvpn-data | sha256sum)\" '{\"changed\":$changed}'"]
}

variable "anycast_addresses" {
  default = {
    lb = ["198.51.233.233/32", "198.51.233.234/32",
          "2620:2:6000:26::26/64", "2620:2:6000:26::27/64"],
    vpn = ["198.51.233.222/32"],
  }
}

variable "anycast_local_as" {
  default = "395409"
}

variable "anycast_neighbor_as" {
  default = "64515"
}

variable "anycast_neighbor_ipv4" {
  default = "169.254.169.254"
}

variable "anycast_neighbor_ipv6" {
  default = "2001:19f0:ffff::1"
}

variable "cluster_leader_role" {
  default = "co"
}

data "template_file" "cluster_leaders" {
  count = "${length(matchkeys(module.inventory.private_ipv4s, module.inventory.roles, list(var.cluster_leader_role)))}"
  template = "$${address}"

  vars {
    address = "${element(matchkeys(module.inventory.private_ipv4s, module.inventory.roles, list(var.cluster_leader_role)), count.index)}"
  }
}

variable "hosts" {
  default = [
    { hostname = "vpn0.ams", dc = "ams", private_ipv4 = "10.42.1.1", role = "vpn", size = "1cpu2gb" },
    { hostname = "vpn0.fra", dc = "fra", private_ipv4 = "10.42.2.1", role = "vpn", size = "1cpu2gb" },
    { hostname = "vpn0.nrt", dc = "nrt", private_ipv4 = "10.42.3.1", role = "vpn", size = "1cpu2gb" },
    { hostname = "vpn0.sgp", dc = "sgp", private_ipv4 = "10.42.4.1", role = "vpn", size = "1cpu2gb" },
    { hostname = "vpn0.sea", dc = "sea", private_ipv4 = "10.42.5.1", role = "vpn", size = "1cpu2gb" },
    { hostname = "vpn0.sjc", dc = "sjc", private_ipv4 = "10.42.6.1", role = "vpn", size = "1cpu2gb" },
    { hostname = "vpn0.lax", dc = "lax", private_ipv4 = "10.42.7.1", role = "vpn", size = "1cpu2gb" },
    { hostname = "vpn0.mia", dc = "mia", private_ipv4 = "10.42.8.1", role = "vpn", size = "1cpu2gb" },
    { hostname = "vpn0.dfw", dc = "dfw", private_ipv4 = "10.42.9.1", role = "vpn", size = "1cpu2gb" },
    { hostname = "vpn0.ord", dc = "ord", private_ipv4 = "10.42.10.1", role = "vpn", size = "1cpu2gb" },
    { hostname = "vpn0.ewr", dc = "ewr", private_ipv4 = "10.42.11.1", role = "vpn", size = "1cpu2gb" },
    { hostname = "co0.ams", dc = "ams", private_ipv4 = "10.42.1.5", role = "co", size = "2cpu4gb" },
    { hostname = "co0.fra", dc = "fra", private_ipv4 = "10.42.2.5", role = "co", size = "2cpu4gb" },
    { hostname = "co0.nrt", dc = "nrt", private_ipv4 = "10.42.3.5", role = "co", size = "2cpu4gb" },
    { hostname = "co0.sgp", dc = "sgp", private_ipv4 = "10.42.4.5", role = "co", size = "2cpu4gb" },
    { hostname = "co0.sea", dc = "sea", private_ipv4 = "10.42.5.5", role = "co", size = "2cpu4gb" },
    { hostname = "co0.sjc", dc = "sjc", private_ipv4 = "10.42.6.5", role = "co", size = "2cpu4gb" },
    { hostname = "co0.lax", dc = "lax", private_ipv4 = "10.42.7.5", role = "co", size = "2cpu4gb" },
    { hostname = "co0.mia", dc = "mia", private_ipv4 = "10.42.8.5", role = "co", size = "2cpu4gb" },
    { hostname = "co0.dfw", dc = "dfw", private_ipv4 = "10.42.9.5", role = "co", size = "2cpu4gb" },
    { hostname = "co0.ord", dc = "ord", private_ipv4 = "10.42.10.5", role = "co", size = "2cpu4gb" },
    { hostname = "co0.ewr", dc = "ewr", private_ipv4 = "10.42.11.5", role = "co", size = "2cpu4gb" },
    { hostname = "mon0.ams", dc = "ams", private_ipv4 = "10.42.1.10", role = "mon", size = "2cpu4gb" },
    { hostname = "mon0.fra", dc = "fra", private_ipv4 = "10.42.2.10", role = "mon", size = "2cpu4gb" },
    { hostname = "mon0.nrt", dc = "nrt", private_ipv4 = "10.42.3.10", role = "mon", size = "2cpu4gb" },
    { hostname = "mon0.sgp", dc = "sgp", private_ipv4 = "10.42.4.10", role = "mon", size = "2cpu4gb" },
    { hostname = "mon0.sea", dc = "sea", private_ipv4 = "10.42.5.10", role = "mon", size = "2cpu4gb" },
    { hostname = "mon0.sjc", dc = "sjc", private_ipv4 = "10.42.6.10", role = "mon", size = "2cpu4gb" },
    { hostname = "mon0.lax", dc = "lax", private_ipv4 = "10.42.7.10", role = "mon", size = "2cpu4gb" },
    { hostname = "mon0.mia", dc = "mia", private_ipv4 = "10.42.8.10", role = "mon", size = "2cpu4gb" },
    { hostname = "mon0.dfw", dc = "dfw", private_ipv4 = "10.42.9.10", role = "mon", size = "2cpu4gb" },
    { hostname = "mon0.ord", dc = "ord", private_ipv4 = "10.42.10.10", role = "mon", size = "2cpu4gb" },
    { hostname = "mon0.ewr", dc = "ewr", private_ipv4 = "10.42.11.10", role = "mon", size = "2cpu4gb" },
  ]
}

variable "ssh_keys" {
  default = [
    "57d1b92cd1edd",
    "5956dc8a4967d",
    "5956dcad57069",
  ]
}
