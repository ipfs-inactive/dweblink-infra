resource "vultr_ssh_key" "lars-desktop" {
  name       = "lars-desktop"
  public_key = "${file("lars-desktop.pub")}"
}

variable "datacenters" {
  default = ["ams","fra","cdg"]
}
variable "regions" {
  default = {
    ams = "eu",
    fra = "eu",
    cdg = "eu"
  }
}
variable "datacenter_to_vultr_region" {
  default = {
    ams = 7,
    fra = 9,
    cdg = 24
  }
}
variable "inventory" {
  default = {
    "0" = { hostname = "gw0.ams", datacenter = "ams", role = "gw", vultr_name = "ipfs-ams-gw0", vultr_plan = 203 },
    "1" = { hostname = "gw1.ams", datacenter = "ams", role = "gw", vultr_name = "ipfs-ams-gw1", vultr_plan = 203 },
    "2" = { hostname = "gw0.fra", datacenter = "fra", role = "gw", vultr_name = "ipfs-fra-gw0", vultr_plan = 203 },
    "3" = { hostname = "gw1.fra", datacenter = "fra", role = "gw", vultr_name = "ipfs-fra-gw1", vultr_plan = 203 },
    "4" = { hostname = "lb0.ams", datacenter = "ams", role = "lb", vultr_name = "ipfs-ams-lb0", vultr_plan = 203 },
    "5" = { hostname = "lb0.fra", datacenter = "fra", role = "lb", vultr_name = "ipfs-fra-lb0", vultr_plan = 203 }
  }
}

resource "vultr_server" "servers" {
  name  = "${lookup(var.inventory[count.index], "vultr_name")}"
  tag   = "protocollabs"
  count = "${length(var.inventory)}"

  region_id = "${var.datacenter_to_vultr_region[lookup(var.inventory[count.index], "datacenter")]}"
  plan_id   = "${lookup(var.inventory[count.index], "vultr_plan")}"
  os_id     = 215

  hostname           = "${lookup(var.inventory[count.index], "hostname")}.dweblink.net"
  ipv6               = true
  private_networking = true
  ssh_key_ids        = ["${vultr_ssh_key.lars-desktop.id}"]
}

resource "dnsimple_record" "hostnames_v4" {
  count  = "${length(var.inventory)}"
  domain = "dweblink.net"
  name  = "${lookup(var.inventory[count.index], "hostname")}"
  value = "${vultr_server.servers.*.ipv4_address[count.index]}"
  type  = "A"
  ttl   = "60"
}

resource "dnsimple_record" "hostnames_v6" {
  count  = "${length(var.inventory)}"
  domain = "dweblink.net"
  name  = "${lookup(var.inventory[count.index], "hostname")}"
  value = "${vultr_server.servers.*.ipv6_address[count.index]}"
  type  = "AAAA"
  ttl   = "60"
}

# variable "anycast_ip4addrs" {
#   default = ["198.51.233.233", "198.51.233.234"]
# }


# variable "anycast_ip6addrs" {
#   default = ["2620:2:6000:26::26", "2620:2:6000:26::27"]
# }

