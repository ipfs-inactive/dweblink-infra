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

variable "coordinators" {
  default = [
    "10.42.1.10",
    "10.42.2.10",
    "10.42.3.10",
  ]
}

variable "hosts" {
  default = [
    { hostname = "vpn0.ams", dc = "ams", private_ipv4 = "10.42.1.1", role = "vpn", size = "1cpu1gb" },
    { hostname = "coord0.ams", dc = "ams", private_ipv4 = "10.42.1.10", role = "coord", size = "2cpu4gb" },
    # { hostname = "mon0.ams", dc = "ams", private_ipv4 = "10.42.1.20", role = "monitor", size = "1cpu1gb" },
    { hostname = "lb0.ams", dc = "ams", private_ipv4 = "10.42.1.100", role = "lb", size = "2cpu4gb" },
    # { hostname = "gw0.ams", dc = "ams", private_ipv4 = "10.42.1.200", role = "gateway", size = "1cpu1gb" },
    # { hostname = "gw1.ams", dc = "ams", private_ipv4 = "10.42.1.201", role = "gateway", size = "1cpu1gb" },

    { hostname = "vpn0.fra", dc = "fra", private_ipv4 = "10.42.2.1", role = "vpn", size = "1cpu1gb" },
    { hostname = "coord0.fra", dc = "fra", private_ipv4 = "10.42.2.10", role = "coord", size = "2cpu4gb" },
    # { hostname = "mon0.fra", dc = "fra", private_ipv4 = "10.42.2.20", role = "monitor", size = "1cpu1gb" },
    { hostname = "lb0.fra", dc = "fra", private_ipv4 = "10.42.2.100", role = "lb", size = "2cpu4gb" },
    # { hostname = "gw0.fra", dc = "fra", private_ipv4 = "10.42.2.200", role = "gateway", size = "1cpu1gb" },
    # { hostname = "gw1.fra", dc = "fra", private_ipv4 = "10.42.2.201", role = "gateway", size = "1cpu1gb" },

    { hostname = "vpn0.sea", dc = "sea", private_ipv4 = "10.42.3.1", role = "vpn", size = "1cpu1gb" },
    { hostname = "coord0.sea", dc = "sea", private_ipv4 = "10.42.3.10", role = "coord", size = "2cpu4gb" },
    # { hostname = "mon0.sea", dc = "sea", private_ipv4 = "10.42.3.20", role = "monitor", size = "1cpu1gb" },
    { hostname = "lb0.sea", dc = "sea", private_ipv4 = "10.42.3.100", role = "lb", size = "2cpu4gb" },
    # { hostname = "gw0.sea", dc = "sea", private_ipv4 = "10.42.3.200", role = "gateway", size = "1cpu1gb" },
    # { hostname = "gw1.sea", dc = "sea", private_ipv4 = "10.42.3.201", role = "gateway", size = "1cpu1gb" },
  ]
}

variable "ssh_keys" {
  default = [
    "57d1b92cd1edd",
    "5956dc8a4967d",
    "5956dcad57069",
  ]
}
