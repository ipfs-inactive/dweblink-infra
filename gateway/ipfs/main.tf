variable "count" {
  type = "string"
}

variable "connections" {
  type = "list"
}

variable "datacenters" {
  default = []
}

variable "image" {
  type = "string"
}

variable "version" {
  type = "string"
}

variable "repo_dir" {
  type = "string"
}

variable "swarm_tcp_port" {
  type = "string"
}

variable "swarm_ws_port" {
  type = "string"
}

variable "api_port" {
  type = "string"
}

variable "gateway_port" {
  type = "string"
}

resource "null_resource" "config" {
  count = "${var.count}"

  triggers {
    conf = "${sha256(element(data.template_file.config.*.rendered, count.index))}"
    count = "${var.count}"
  }

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
  }

  provisioner "file" {
    content = "${element(data.template_file.config.*.rendered, count.index)}"
    destination = "${var.repo_dir}/"
  }

  provisioner "remote-exec" {
    inline = [
      "ufw allow from any to any port ${var.swarm_tcp_port} proto tcp",
    ]
  }
}

resource "null_resource" "job" {
  depends_on = ["null_resource.config"]

  triggers {
    conf = "${sha256(element(data.template_file.config.*.rendered, count.index))}"
    job = "${sha256(data.template_file.job.rendered)}"
  }

  connection {
    host  = "${element(var.connections, 0)}"
    user  = "root"
    agent = true
  }

  provisioner "file" {
    content = "${data.template_file.job.rendered}"
    destination = "/opt/gw.nomad"
  }

  provisioner "remote-exec" {
    inline = [
      "if nomad status gw >/dev/null; then nomad stop gw; fi",
      "nomad run /opt/gw.nomad",
    ]
  }
}

data "template_file" "config" {
  count = "${var.count}"
  template = "${file("${path.module}/templates/config.tpl")}"

  vars {
    swarm_tcp_port = "${var.swarm_tcp_port}"
    swarm_ws_port = "${var.swarm_ws_port}"
    api_port = "${var.api_port}"
    gateway_port = "${var.gateway_port}"

    peerid = "${element(data.external.identities.*.result.PeerID, count.index)}"
    private_key = "${element(data.external.identities.*.result.PrivKey, count.index)}"

    gc_period = "1h"
    gc_capacity = "45G"
    gc_watermark = "90"
    bloom_size = "524288"
  }
}

data "template_file" "job" {
  template = "${file("${path.module}/templates/gw.nomad.tpl")}"

  vars {
    datacenters = "${jsonencode(var.datacenters)}"
    count = "${var.count}"
    image = "${var.image}"
    version = "${var.version}"
    repo_dir = "${var.repo_dir}"
    swarm_tcp_port = "${var.swarm_tcp_port}"
    swarm_ws_port = "${var.swarm_ws_port}"
    api_port = "${var.api_port}"
    gateway_port = "${var.gateway_port}"
  }
}

data "external" "identities" {
  count = "${var.count}"

  program = ["sh", "${path.module}/scripts/gen_identity.sh"]
}
