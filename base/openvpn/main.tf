# the vpn shit -- need to allow from 172.17.0.0/24 or so

variable "count" {
  type = "string"
}

variable "connections" {
  type = "list"
}

variable "data_dir" {
  default = "/opt/openvpn-data"
}

variable "data" {
  type = "string"
}

variable "data_changed" {
  type = "string"
}

variable "domain_name" {
  type = "string"
}

variable "network" {
  type = "string"
}

variable "routes" {
  default = []
}

variable "port" {
  default = "1194"
}

variable "public_ipv6" {
  type = "string"
}

variable "exporter_port" {
  default = "9176"
}

variable "status_dir" {
  default = "/opt/openvpn-status"
}

variable "gateway_enabled" {
  default = false
}

variable "datacenters" {
  default = []
}

resource "null_resource" "data" {
  count = "${var.count}"

  triggers {
    data  = "${var.data_changed}"
  }

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
    timeout = "30s"
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf ${var.data_dir}",
      "mkdir -p ${var.data_dir}",
    ]
  }

  provisioner "file" {
    source      = "${var.data}/"
    destination = "${var.data_dir}"
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rvf ${var.data_dir}/ccd",
      "chown -R root:root ${var.data_dir}",
    ]
  }
}

resource "null_resource" "config" {
  count      = "${var.count}"
  depends_on = ["null_resource.data"]

  triggers {
    data  = "${var.data_changed}"
    conf  = "${sha256(element(data.template_file.config.*.rendered, count.index))}"
    env   = "${sha256(element(data.template_file.env.*.rendered, count.index))}"
  }

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
    timeout = "30s"
  }

  provisioner "file" {
    content     = "${element(data.template_file.config.*.rendered, count.index)}"
    destination = "${var.data_dir}/openvpn.conf"
  }

  provisioner "file" {
    content     = "${element(data.template_file.env.*.rendered, count.index)}"
    destination = "${var.data_dir}/ovpn_env.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "ufw allow from any to any port ${var.port} proto udp",
    ]
  }
}

resource "null_resource" "job" {
  depends_on = ["null_resource.data", "null_resource.config"]

  triggers {
    data = "${var.data_changed}"
    conf = "${sha256(element(data.template_file.config.*.rendered, count.index))}"
    env  = "${sha256(element(data.template_file.env.*.rendered, count.index))}"
    job  = "${sha256(data.template_file.job.rendered)}"
  }

  connection {
    host  = "${element(var.connections, 0)}"
    user  = "root"
    agent = true
    timeout = "30s"
  }

  provisioner "file" {
    content     = "${data.template_file.job.rendered}"
    destination = "/opt/vpn.nomad"
  }

  provisioner "remote-exec" {
    inline = [
      "if nomad status vpn >/dev/null; then nomad stop vpn; fi",
      "nomad run /opt/vpn.nomad",
    ]
  }
}

data "template_file" "config" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/openvpn.conf")}"

  vars {
    network     = "${cidrhost(cidrsubnet(var.network, 8, count.index+1), 0)}"
    netmask     = "${cidrnetmask(cidrsubnet(var.network, 8, count.index+1))}"
    push_routes = "${join("\n", data.template_file.routes.*.rendered)}"
    domain_name = "${var.domain_name}"
  }
}

data "template_file" "env" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/ovpn_env.sh")}"

  vars {
    domain_name     = "${var.domain_name}"
    gateway_enabled = "${var.gateway_enabled == "1" ? "1" : "0"}"
    network         = "${cidrsubnet(var.network, 8, count.index + 1)}"
  }
}

data "template_file" "firewall" {
  template = "push \"route $${addr} $${mask}\""

  vars {
    addr = "${cidrhost(element(var.routes, count.index), 0)}"
    mask = "${cidrnetmask(element(var.routes, count.index))}"
  }
}

data "template_file" "job" {
  template = "${file("${path.module}/templates/vpn.nomad")}"

  vars {
    datacenters   = "${jsonencode(var.datacenters)}"
    count         = "${var.count}"
    data_dir      = "${var.data_dir}"
    status_dir    = "${var.status_dir}"
    port          = "${var.port}"
    exporter_port = "${var.exporter_port}"
    public_ipv6   = "${var.public_ipv6}"
  }
}

data "template_file" "routes" {
  count    = "${length(var.routes)}"
  template = "push \"route $${addr} $${mask}\""

  vars {
    addr = "${cidrhost(element(var.routes, count.index+1), 0)}"
    mask = "${cidrnetmask(element(var.routes, count.index))}"
  }
}
