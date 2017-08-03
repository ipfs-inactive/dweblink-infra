variable "count" {
  type = "string"
}

variable "connections" {
  type = "list"
}

variable "ipv6_networks" {
  type = "list"
}

resource "null_resource" "install" {
  count = "${var.count}"

  triggers {
    count = "${var.count}"
  }

  connection {
    host = "${element(var.connections, count.index)}"
    user = "root"
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -",
      "echo 'deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial edge' > /etc/apt/sources.list.d/docker.list",
      "apt-get update -q",
      # TODO is -o still needed now that /etc/default/docker is gone?
      "DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::=\"--force-confold\" install -yq docker-ce libltdl7 aufs-tools",
      "systemctl daemon-reload",
      "systemctl is-enabled docker.service || systemctl enable docker.service",
      "systemctl start docker.service",
    ]
  }
}

resource "null_resource" "config" {
  count = "${var.count}"
  depends_on = ["null_resource.install"]

  triggers {
    conf = "${sha256(join("\n", data.template_file.config.*.rendered))}"
  }

  connection {
    host = "${element(var.connections, count.index)}"
    user = "root"
    agent = true
  }

  provisioner "file" {
    content = "${element(data.template_file.config.*.rendered, count.index)}"
    destination = "/etc/systemd/system/docker.service.d/docker.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl restart docker.service",
    ]
  }
}

data "template_file" "config" {
  count = "${var.count}"
  template = "${file("${path.module}/templates/docker.conf")}"

  vars {
    ipv6_network = "${element(var.ipv6_networks, count.index)}"
  }
}

output "dependency" {
  value = "${sha256(var.count)}"
}
