resource "vultr_ssh_key" "lars-desktop" {
  name       = "lars-desktop"
  public_key = "${file("lars-desktop.pub")}"
}

variable "gw_count" {
  default = 1
}

variable "lb_count" {
  default = 1
}

variable "regions" {
  default = [7, 9]
}

variable "region_names" {
  default = ["ams", "fra", "cdg"]
}

resource "vultr_server" "gw_hosts" {
  # ipfs-ams-gw0
  name  = "ipfs-${var.region_names[count.index % length(var.regions)]}-gw${(count.index + length(var.regions)) / length(var.regions) - 1}"
  tag   = "protocollabs"
  count = "${var.gw_count * length(var.regions)}"

  region_id = "${var.regions[count.index % length(var.regions)]}"
  plan_id   = 203
  os_id     = 215

  # gw0.ams.dweblink.net
  hostname           = "gw${(count.index + length(var.regions)) / length(var.regions) - 1}.${var.region_names[count.index % length(var.regions)]}.dweblink.net"
  ipv6               = true
  private_networking = true
  ssh_key_ids        = ["${vultr_ssh_key.lars-desktop.id}"]
}

resource "vultr_server" "lb_hosts" {
  # ipfs-ams-lb0
  name  = "ipfs-${var.region_names[count.index % length(var.regions)]}-lb${(count.index + length(var.regions)) / length(var.regions) - 1}"
  tag   = "protocollabs"
  count = "${var.lb_count * length(var.regions)}"

  region_id = "${var.regions[count.index % length(var.regions)]}"
  plan_id   = 203
  os_id     = 215

  # lb0.ams.dweblink.net
  hostname           = "lb${(count.index + length(var.regions)) / length(var.regions) - 1}.${var.region_names[count.index % length(var.regions)]}.dweblink.net"
  ipv6               = true
  private_networking = true
  ssh_key_ids        = ["${vultr_ssh_key.lars-desktop.id}"]
}

resource "dnsimple_record" "gw_v4hostnames" {
  count  = "${var.gw_count * length(var.regions)}"
  domain = "dweblink.net"

  # gw0.ams
  name  = "gw${(count.index + length(var.regions)) / length(var.regions) - 1}.${var.region_names[count.index % length(var.regions)]}"
  value = "${vultr_server.gw_hosts.*.ipv4_address[count.index]}"
  type  = "A"
  ttl   = "60"
}

resource "dnsimple_record" "gw_v6hostnames" {
  count  = "${var.gw_count * length(var.regions)}"
  domain = "dweblink.net"

  # gw0.ams
  name  = "gw${(count.index + length(var.regions)) / length(var.regions) - 1}.${var.region_names[count.index % length(var.regions)]}"
  value = "${vultr_server.gw_hosts.*.ipv6_address[count.index]}"
  type  = "AAAA"
  ttl   = "60"
}

resource "dnsimple_record" "lb_v4hostnames" {
  count  = "${var.lb_count * length(var.regions)}"
  domain = "dweblink.net"

  # lb0.ams
  name  = "lb${(count.index + length(var.regions)) / length(var.regions) - 1}.${var.region_names[count.index % length(var.regions)]}"
  value = "${vultr_server.lb_hosts.*.ipv4_address[count.index]}"
  type  = "A"
  ttl   = "60"
}

resource "dnsimple_record" "lb_v6hostnames" {
  count  = "${var.lb_count * length(var.regions)}"
  domain = "dweblink.net"

  # lb0.ams
  name  = "lb${(count.index + length(var.regions)) / length(var.regions) - 1}.${var.region_names[count.index % length(var.regions)]}"
  value = "${vultr_server.lb_hosts.*.ipv6_address[count.index]}"
  type  = "AAAA"
  ttl   = "60"
}

# resource "random_id" "trigger" {
#   byte_length = 8
# }


# resource "null_resource" "bootstrap" {
#   triggers {
#     trigger = "${random_id.trigger.hex}"
#   }
#
#   provisioner "local-exec" {
#     command = "echo ${join(", ", vultr_server.gw_hosts.*.ipv4_address)}"
#   }
# }


# variable "anycast_ip4addrs" {
#   default = ["198.51.233.233", "198.51.233.234"]
# }


# variable "anycast_ip6addrs" {
#   default = ["2620:2:6000:26::26", "2620:2:6000:26::27"]
# }

