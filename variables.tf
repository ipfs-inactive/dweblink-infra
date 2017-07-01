variable "domain_name" {
  default = "dweblink.net"
}

variable "image" {
  default = "ubuntu1604"
}

variable "hosts_tag" {
  default = "protocollabs"
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
    { hostname = "coord0.ams", dc = "ams", private_ipv4 = "10.42.1.10", role = "coordinator", size = "2cpu4gb" },
    # { hostname = "mon0.ams", dc = "ams", private_ipv4 = "10.42.1.20", role = "monitor", size = "1cpu1gb" },
    { hostname = "lb0.ams", dc = "ams", private_ipv4 = "10.42.1.100", role = "loadbalancer", size = "2cpu4gb" },
    # { hostname = "gw0.ams", dc = "ams", private_ipv4 = "10.42.1.200", role = "gateway", size = "1cpu1gb" },
    # { hostname = "gw1.ams", dc = "ams", private_ipv4 = "10.42.1.201", role = "gateway", size = "1cpu1gb" },

    { hostname = "vpn0.fra", dc = "fra", private_ipv4 = "10.42.2.1", role = "vpn", size = "1cpu1gb" },
    { hostname = "coord0.fra", dc = "fra", private_ipv4 = "10.42.2.10", role = "coordinator", size = "2cpu4gb" },
    # { hostname = "mon0.fra", dc = "fra", private_ipv4 = "10.42.2.20", role = "monitor", size = "1cpu1gb" },
    { hostname = "lb0.fra", dc = "fra", private_ipv4 = "10.42.2.100", role = "loadbalancer", size = "2cpu4gb" },
    # { hostname = "gw0.fra", dc = "fra", private_ipv4 = "10.42.2.200", role = "gateway", size = "1cpu1gb" },
    # { hostname = "gw1.fra", dc = "fra", private_ipv4 = "10.42.2.201", role = "gateway", size = "1cpu1gb" },

    { hostname = "vpn0.sea", dc = "sea", private_ipv4 = "10.42.3.1", role = "vpn", size = "1cpu1gb" },
    { hostname = "coord0.sea", dc = "sea", private_ipv4 = "10.42.3.10", role = "coordinator", size = "2cpu4gb" },
    # { hostname = "mon0.sea", dc = "sea", private_ipv4 = "10.42.3.20", role = "monitor", size = "1cpu1gb" },
    { hostname = "lb0.sea", dc = "sea", private_ipv4 = "10.42.3.100", role = "loadbalancer", size = "2cpu4gb" },
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
