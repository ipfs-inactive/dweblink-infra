variable "count" {
  type = "string"
}

variable "connections" {
  type = "list"
}

variable "name" {
  type = "string"
}

variable "addresses" {
  type = "list"
}

resource "null_resource" "configure" {
  count = "${var.count}"

  triggers {
    count = "${var.count}"
    conf  = "${sha256(data.template_file.service.rendered)}"
  }

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
  }

  provisioner "file" {
    content     = "${data.template_file.service.rendered}"
    destination = "/etc/systemd/system/anycast-${var.name}.service"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl is-enabled anycast-${var.name} || systemctl enable anycast-${var.name}",
      "systemctl is-active anycast-${var.name} || systemctl start anycast-${var.name}",
    ]
  }
}

data "template_file" "service" {
  template = "${file("${path.module}/templates/anycast.service.tpl")}"

  vars {
    name      = "${var.name}"
    addresses = "ExecStart=/sbin/ip addr add ${join(" dev dummy-${var.name}\nExecStart=/sbin/ip addr add ", var.addresses)} dev dummy-${var.name}"
  }
}
