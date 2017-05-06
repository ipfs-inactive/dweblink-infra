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
  default = {"7" = "ams", "9" = "fra"}
}

resource "vultr_server" "gw_hosts" {
  name = "ipfs-${var.region_names[var.regions[count.index / var.gw_count]]}-gw${count.index % var.gw_count}"
  tag = "protocollabs"
  count = "${var.gw_count * length(var.regions)}"

  region_id = "${var.regions[count.index / var.gw_count]}"
  plan_id = 203
  os_id = 215

  hostname = "gw${count.index % var.gw_count}.${var.region_names[var.regions[count.index / var.gw_count]]}.dweblink.net"
  ipv6 = true
  private_networking = true
  ssh_key_ids = ["${vultr_ssh_key.lars-desktop.id}"]
}

resource "vultr_server" "lb_hosts" {
  name = "ipfs-${var.region_names[var.regions[count.index / var.lb_count]]}-lb${count.index % var.lb_count}"
  tag = "protocollabs"
  count = "${var.lb_count * length(var.regions)}"

  region_id = "${var.regions[count.index / var.lb_count]}"
  plan_id = 203
  os_id = 215

  hostname = "lb${count.index % var.lb_count}.${var.region_names[var.regions[count.index / var.lb_count]]}.dweblink.net"
  ipv6 = true
  private_networking = true
  ssh_key_ids = ["${vultr_ssh_key.lars-desktop.id}"]
}

resource "dnsimple_record" "gw_v4hostnames" {
  count = "${var.gw_count * length(var.regions)}"
  domain = "dweblink.net"
  name = "gw${count.index % var.lb_count}.${var.region_names[var.regions[count.index / var.gw_count]]}"
  value = "${vultr_server.gw_hosts.*.ipv4_address[count.index]}"
  type = "A"
  ttl = "60"
}

resource "dnsimple_record" "gw_v6hostnames" {
  count = "${var.gw_count * length(var.regions)}"
  domain = "dweblink.net"
  name = "gw${count.index % var.lb_count}.${var.region_names[var.regions[count.index / var.gw_count]]}"
  value = "${vultr_server.gw_hosts.*.ipv6_address[count.index]}"
  type = "AAAA"
  ttl = "60"
}

resource "dnsimple_record" "lb_v4hostnames" {
  count = "${var.lb_count * length(var.regions)}"
  domain = "dweblink.net"
  name = "lb${count.index % var.lb_count}.${var.region_names[var.regions[count.index / var.lb_count]]}"
  value = "${vultr_server.lb_hosts.*.ipv4_address[count.index]}"
  type = "A"
  ttl = "60"
}

resource "dnsimple_record" "lb_v6hostnames" {
  count = "${var.lb_count * length(var.regions)}"
  domain = "dweblink.net"
  name = "lb${count.index % var.lb_count}.${var.region_names[var.regions[count.index / var.lb_count]]}"
  value = "${vultr_server.lb_hosts.*.ipv6_address[count.index]}"
  type = "AAAA"
  ttl = "60"
}

# resource "random_id" "trigger" {
#   byte_length = 8
# }

# resource "null_resource" "bootstrap" {
#   triggers {
#     trigger = "${random_id.trigger.hex}"
#   }

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
