variable "count" {
  type = "string"
}

variable "connections" {
  type = "list"
}

variable "ipv4s" {
  type = "list"
}

variable "servers" {
  type = "list"
}

variable "datacenters" {
  type = "list"
}

variable "roles" {
  type = "list"
}

variable "bind_interfaces" {
  default = ["lo", "lo0"]
}

variable "nomad_version" {
  type = "string"
}

variable "data_dir" {
  default = "/opt/nomad/data"
}

variable "config_dir" {
  default = "/opt/nomad/config"
}

resource "null_resource" "install" {
  count = "${var.count}"

  triggers {
    conf    = "${sha256(element(data.template_file.config.*.rendered, count.index))}"
    service = "${sha256(element(data.template_file.service.*.rendered, count.index))}"
    version = "${var.nomad_version}"
  }

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -pv ${var.config_dir} ${var.data_dir}",
    ]
  }

  provisioner "file" {
    content     = "${element(data.template_file.config.*.rendered, count.index)}"
    destination = "${var.config_dir}/nomad.json"
  }

  provisioner "file" {
    content     = "${element(data.template_file.service.*.rendered, count.index)}"
    destination = "/etc/systemd/system/nomad.service"
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /tmp/nomad*",
      "cd /tmp && wget https://releases.hashicorp.com/nomad/${var.nomad_version}/nomad_${var.nomad_version}_linux_amd64.zip && unzip nomad_${var.nomad_version}_linux_amd64.zip",
      "mv /tmp/nomad /usr/local/bin/",
      "systemctl daemon-reload",
      "systemctl is-enabled nomad.service || systemctl enable nomad.service",
      "systemctl restart nomad",
    ]
  }
}

data "template_file" "config" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/config.json")}"

  vars {
    data_dir     = "${var.data_dir}"
    http_address = "127.0.0.1"
    rpc_address  = "${element(var.ipv4s, count.index)}"
    serf_address = "${element(var.ipv4s, count.index)}"
    datacenter   = "${element(var.datacenters, count.index)}"
    client       = "true"
    drivers      = "docker"
    privileged   = "${element(var.roles, count.index) == "vpn" ? "true" : "false"}"
    interface    = "${join(" | ", var.bind_interfaces)}"
    node_class   = "${element(var.roles, count.index)}"

    # TODO this is a mess :/ see https://github.com/hashicorp/terraform/issues/15291
    server           = "${length(var.servers) == length(compact(split(",", replace(join(",", var.servers), element(var.ipv4s, count.index), "")))) ? "false" : "true"}"
    bootstrap_expect = "${length(var.servers) == length(compact(split(",", replace(join(",", var.servers), element(var.ipv4s, count.index), "")))) ? 0 : floor(length(var.servers)/2)+1}"
    retry_join       = "${join("\", \"", var.servers)}"
  }
}

data "template_file" "service" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/nomad.service")}"

  vars {
    command = "/usr/local/bin/nomad agent -config=${var.config_dir}"
  }
}
