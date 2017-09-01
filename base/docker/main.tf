variable "count" {
  type = "string"
}

variable "connections" {
  type = "list"
}

resource "null_resource" "install" {
  count = "${var.count}"

  triggers {
    conf  = "${sha256(file("${path.module}/templates/docker.default"))}"
    count = "${var.count}"
  }

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
    timeout = "30s"
  }

  provisioner "file" {
    source      = "${path.module}/templates/docker.default"
    destination = "/etc/default/docker"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -",
      "echo 'deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial edge' > /etc/apt/sources.list.d/docker.list",
      "apt-get update -q",
      "DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::=\"--force-confold\" install -yq docker-ce libltdl7 aufs-tools",
      "systemctl daemon-reload",
      "systemctl is-enabled docker.service || systemctl enable docker.service",
      "systemctl start docker.service",
    ]
  }
}

output "dependency" {
  value = "${sha256(var.count)}"
}
