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

variable "size2plan" {
  default = {
    "1cpu1gb" = 201,
    "1cpu2gb" = 202,
    "2cpu4gb" = 203,
    "4cpu8gb" = 204,
  }
}

variable "image2os" {
  default = {
    ubuntu1604 = 215,
    windows2016 = 240,
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

variable "image" {
  type = "string"
}

variable "tag" {
  type = "string"
}

resource "vultr_server" "hosts" {
  count = "${length(var.hosts)}"
  name  = "${lookup(var.hosts[count.index], "hostname")}.${var.domain_name}"
  tag   = "${var.tag}"

  region_id = "${var.dc2region[lookup(var.hosts[count.index], "dc")]}"
  plan_id   = "${var.size2plan[lookup(var.hosts[count.index], "size")]}"
  os_id     = "${var.image2os[var.image]}"

  hostname           = "${lookup(var.hosts[count.index], "hostname")}.${var.domain_name}"
  ipv6               = true
  private_networking = false
  ssh_key_ids        = ["${var.ssh_keys}"]
}

resource "null_resource" "tools" {
  count = "${length(var.hosts)}"

  connection {
    host = "${element(vultr_server.hosts.*.ipv4_address, count.index)}"
    user = "root"
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update -q",
      "DEBIAN_FRONTEND=noninteractive apt-get install -yq vim screen gdb tree htop iotop iftop bmon sysstat bridge-utils unzip jq mtr traceroute dnsutils psmisc build-essential bison flex autoconf ncurses-dev libreadline-dev",
    ]
  }
}

resource "null_resource" "firewall" {
  count = "${length(var.hosts)}"

  connection {
    host = "${element(vultr_server.hosts.*.ipv4_address, count.index)}"
    user = "root"
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "echo y | ufw reset && echo y | ufw enable",
      "ufw default deny incoming && ufw default allow outgoing",
      "ufw allow from any to ${element(vultr_server.hosts.*.ipv4_address, count.index)} port 22 proto tcp",
      "ufw logging on",
    ]
  }
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

data "template_file" "roles" {
  count = "${length(var.hosts)}"
  template = "$${role}"

  vars {
    role = "${lookup(var.hosts[count.index], "role")}"
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

output "roles" {
  value = ["${data.template_file.roles.*.rendered}"]
}
