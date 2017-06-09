variable "domain_name" {
  default = "dweblink.net"
}

variable "hosts_tag" {
  default = "protocollabs"
}

variable "hosts" {
  default = [
    { hostname = "vpn0.ams", dc = "ams", private_ipv4 = "10.42.1.1", role = "vpn", vultr_name = "ipfs-ams-vpn0", vultr_plan = 201 },
    { hostname = "coord0.ams", dc = "ams", private_ipv4 = "10.42.1.10", role = "coordinator", vultr_name = "ipfs-ams-coord0", vultr_plan = 201 },
    # { hostname = "mon0.ams", dc = "ams", private_ipv4 = "10.42.1.20", role = "monitor", vultr_name = "ipfs-ams-mon0", vultr_plan = 201 },
    # { hostname = "lb0.ams", dc = "ams", private_ipv4 = "10.42.1.100", role = "loadbalancer", vultr_name = "ipfs-ams-lb0", vultr_plan = 201 },
    # { hostname = "gw0.ams", dc = "ams", private_ipv4 = "10.42.1.200", role = "gateway", vultr_name = "ipfs-ams-gw0", vultr_plan = 201 },
    # { hostname = "gw1.ams", dc = "ams", private_ipv4 = "10.42.1.201", role = "gateway", vultr_name = "ipfs-ams-gw1", vultr_plan = 201 },

    { hostname = "vpn0.fra", dc = "fra", private_ipv4 = "10.42.2.1", role = "vpn", vultr_name = "ipfs-fra-vpn0", vultr_plan = 201 },
    { hostname = "coord0.fra", dc = "fra", private_ipv4 = "10.42.2.10", role = "coordinator", vultr_name = "ipfs-fra-coord0", vultr_plan = 201 },
    # { hostname = "mon0.fra", dc = "fra", private_ipv4 = "10.42.2.20", role = "monitor", vultr_name = "ipfs-fra-mon0", vultr_plan = 201 },
    # { hostname = "lb0.fra", dc = "fra", private_ipv4 = "10.42.2.100", role = "loadbalancer", vultr_name = "ipfs-fra-lb0", vultr_plan = 201 },
    # { hostname = "gw0.fra", dc = "fra", private_ipv4 = "10.42.2.200", role = "gateway", vultr_name = "ipfs-fra-gw0", vultr_plan = 201 },
    # { hostname = "gw1.fra", dc = "fra", private_ipv4 = "10.42.2.201", role = "gateway", vultr_name = "ipfs-fra-gw1", vultr_plan = 201 },

    { hostname = "vpn0.cdg", dc = "cdg", private_ipv4 = "10.42.3.1", role = "vpn", vultr_name = "ipfs-cdg-vpn0", vultr_plan = 201 },
    { hostname = "coord0.cdg", dc = "cdg", private_ipv4 = "10.42.3.10", role = "coordinator", vultr_name = "ipfs-cdg-coord0", vultr_plan = 201 },
    # { hostname = "mon0.cdg", dc = "cdg", private_ipv4 = "10.42.3.20", role = "monitor", vultr_name = "ipfs-cdg-mon0", vultr_plan = 201 },
    # { hostname = "lb0.cdg", dc = "cdg", private_ipv4 = "10.42.3.100", role = "loadbalancer", vultr_name = "ipfs-cdg-lb0", vultr_plan = 201 },
    # { hostname = "gw0.cdg", dc = "cdg", private_ipv4 = "10.42.3.200", role = "gateway", vultr_name = "ipfs-cdg-gw0", vultr_plan = 201 },
    # { hostname = "gw1.cdg", dc = "cdg", private_ipv4 = "10.42.3.201", role = "gateway", vultr_name = "ipfs-cdg-gw1", vultr_plan = 201 },
  ]
}

variable "ssh_keys" {
  default = [
    {
      name = "lars-desktop"
      public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjmBIHEnVszhvtgdD0RbiSK9+h+n1zCHQFVKrN5EVD6"
    }
  ]
}
