variable "dc2region" {
  default = {
    ewr = 1,
    ord = 2,
    dfw = 3,
    sea = 4,
    lax = 5,
    atl = 6,
    ams = 7,
    lhr = 8,
    fra = 9,
    sjc = 12,
    syd = 19,
    cdg = 24,
    nrt = 25,
    sgp = 40,
    mia = 39,
  }
}

variable "hosts" {
  type = "list"
}

variable "ssh_keys" {
  type = "list"
}

variable "domain_name" {
  type = "string"
}

variable "tag" {
  type = "string"
}

resource "vultr_ssh_key" "hosts" {
  count = "${length(var.ssh_keys)}"
  name       = "${lookup(var.ssh_keys[count.index], "name")}"
  public_key = "${lookup(var.ssh_keys[count.index], "public_key")}"
}

resource "vultr_server" "hosts" {
  count = "${length(var.hosts)}"
  name  = "${lookup(var.hosts[count.index], "vultr_name")}"
  tag   = "${var.tag}"

  region_id = "${var.dc2region[lookup(var.hosts[count.index], "dc")]}"
  plan_id   = "${lookup(var.hosts[count.index], "vultr_plan")}"
  os_id     = 215

  hostname           = "${lookup(var.hosts[count.index], "hostname")}.${var.domain_name}"
  ipv6               = true
  private_networking = false
  ssh_key_ids        = ["${vultr_ssh_key.hosts.*.id}"]
}

resource "dnsimple_record" "hostnames" {
  count  = "${length(var.hosts)}"
  domain = "${var.domain_name}"
  name  = "${lookup(var.hosts[count.index], "hostname")}"
  value = "${lookup(var.hosts[count.index], "private_ipv4")}"
  type  = "A"
  ttl   = "60"
}

data "template_file" "datacenters" {
  count = "${length(var.hosts)}"
  template = "$${dc}"

  vars {
    dc = "${lookup(var.hosts[count.index], "dc")}"
  }
}

output "hostnames" {
  value = ["${vultr_server.hosts.*.name}"]
}

output "private_ipv4s" {
  value = ["${dnsimple_record.hostnames.*.value}"]
}

output "public_ipv4s" {
  value = ["${vultr_server.hosts.*.ipv4_address}"]
}

output "public_ipv6s" {
  value = ["${vultr_server.hosts.*.ipv6_address}"]
}

output "datacenters" {
  value = ["${data.template_file.datacenters.*.rendered}"]
}
