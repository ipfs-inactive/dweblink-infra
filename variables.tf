# inventory

variable "domain_name" {
  default = "dweblink.net"
}

variable "network" {
  default = "10.42.0.0/15"
}

variable "ssh_keys" {
  default = [
    "57d1b92cd1edd",
    "5956dc8a4967d",
    "5956dcad57069",
  ]
}

variable "hosts" {
  default = [
    {
      name = "vpn0.ams"
      ipv4 = "10.42.1.1"
      dc   = "ams"
      size = "1cpu2gb"
      role = "vpn"
    },
    {
      name = "vpn0.fra"
      ipv4 = "10.42.2.1"
      dc   = "fra"
      size = "1cpu2gb"
      role = "vpn"
    },
    {
      name = "vpn0.nrt"
      ipv4 = "10.42.3.1"
      dc   = "nrt"
      size = "1cpu2gb"
      role = "vpn"
    },
    {
      name = "vpn0.sgp"
      ipv4 = "10.42.4.1"
      dc   = "sgp"
      size = "1cpu2gb"
      role = "vpn"
    },
    {
      name = "vpn0.sea"
      ipv4 = "10.42.5.1"
      dc   = "sea"
      size = "1cpu2gb"
      role = "vpn"
    },
    {
      name = "vpn0.sjc"
      ipv4 = "10.42.6.1"
      dc   = "sjc"
      size = "1cpu2gb"
      role = "vpn"
    },
    {
      name = "vpn0.lax"
      ipv4 = "10.42.7.1"
      dc   = "lax"
      size = "1cpu2gb"
      role = "vpn"
    },
    {
      name = "vpn0.mia"
      ipv4 = "10.42.8.1"
      dc   = "mia"
      size = "1cpu2gb"
      role = "vpn"
    },
    {
      name = "vpn0.dfw"
      ipv4 = "10.42.9.1"
      dc   = "dfw"
      size = "1cpu2gb"
      role = "vpn"
    },
    {
      name = "vpn0.ord"
      ipv4 = "10.42.10.1"
      dc   = "ord"
      size = "1cpu2gb"
      role = "vpn"
    },
    {
      name = "vpn0.ewr"
      ipv4 = "10.42.11.1"
      dc   = "ewr"
      size = "1cpu2gb"
      role = "vpn"
    },
    {
      name = "co0.ams"
      ipv4 = "10.42.1.5"
      dc   = "ams"
      size = "2cpu4gb"
      role = "co"
    },
    {
      name = "co0.fra"
      ipv4 = "10.42.2.5"
      dc   = "fra"
      size = "2cpu4gb"
      role = "co"
    },
    {
      name = "co0.nrt"
      ipv4 = "10.42.3.5"
      dc   = "nrt"
      size = "2cpu4gb"
      role = "co"
    },
    {
      name = "co0.sgp"
      ipv4 = "10.42.4.5"
      dc   = "sgp"
      size = "2cpu4gb"
      role = "co"
    },
    {
      name = "co0.sea"
      ipv4 = "10.42.5.5"
      dc   = "sea"
      size = "2cpu4gb"
      role = "co"
    },
    {
      name = "co0.sjc"
      ipv4 = "10.42.6.5"
      dc   = "sjc"
      size = "2cpu4gb"
      role = "co"
    },
    {
      name = "co0.lax"
      ipv4 = "10.42.7.5"
      dc   = "lax"
      size = "2cpu4gb"
      role = "co"
    },
    {
      name = "co0.mia"
      ipv4 = "10.42.8.5"
      dc   = "mia"
      size = "2cpu4gb"
      role = "co"
    },
    {
      name = "co0.dfw"
      ipv4 = "10.42.9.5"
      dc   = "dfw"
      size = "2cpu4gb"
      role = "co"
    },
    {
      name = "co0.ord"
      ipv4 = "10.42.10.5"
      dc   = "ord"
      size = "2cpu4gb"
      role = "co"
    },
    {
      name = "co0.ewr"
      ipv4 = "10.42.11.5"
      dc   = "ewr"
      size = "2cpu4gb"
      role = "co"
    },
    {
      name = "gw0.fra"
      ipv4 = "10.42.2.10"
      dc   = "fra"
      size = "2cpu4gb"
      role = "gw"
    },
  ]
}

# bgp anycast

variable "anycast_local_as" {
  default = "395409"
}

variable "anycast_addresses" {
  default = {
    lb = [
      "198.51.233.233/32",
      "198.51.233.234/32",
      "2620:2:6000:26::26/64",
      "2620:2:6000:26::27/64",
    ]

    vpn = [
      "198.51.233.222/32",
    ]
  }
}

# cluster

data "template_file" "cluster_leaders" {
  count    = "${length(matchkeys(module.inventory.ipv4s, module.inventory.roles, list("co")))}"
  template = "$${address}"

  vars {
    address = "${element(matchkeys(module.inventory.ipv4s, module.inventory.roles, list("co")), count.index)}"
  }
}

# vpn

variable "vpn_data" {
  default = "./secrets/openvpn-data"
}

data "external" "vpn_data_changed" {
  program = ["sh", "-c", "jq -n --arg changed \"$(tar -c ${var.vpn_data} | sha256sum)\" '{\"changed\":$changed}'"]
}
