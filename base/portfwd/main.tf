variable "count" {
  type = "string"
}

variable "connections" {
  type = "list"
}

variable "port" {
  type = "string"
}

variable "from" {
  type = "list"
}

variable "to" {
  type = "list"
}

variable "public_ipv4s" {
  type = "list"
}

resource "null_resource" "install" {
  count = "${var.count}"

  triggers {
    rules = "${sha256(element(data.template_file.rules.*.rendered, count.index))}"
    count = "${var.count}"
  }

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
  }

  provisioner "file" {
    content     = "${element(data.template_file.rules.*.rendered, count.index)}"
    destination = "/etc/ufw/before.rules.portfwd"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /etc/ufw ; if ! cat before.rules.portfwd-orig >/dev/null; then cp before.rules before.rules.portfwd-orig; fi",
      "cd /etc/ufw ; cat before.rules.portfwd before.rules.portfwd-orig > before.rules",
      "ufw reload",
    ]
  }
}

data "template_file" "rules" {
  count = "${var.count}"

  template = <<EOF
*nat
:PREROUTING ACCEPT [0:0]
${join("\n", formatlist("-A PREROUTING -p udp -d %s --dport $${port} -j DNAT --to-destination $${to}:$${port}", var.from))}
COMMIT
EOF

  vars {
    to          = "${element(var.to, count.index)}"
    port        = "${var.port}"
    public_ipv4 = "${element(var.public_ipv4s, count.index)}"
  }
}
