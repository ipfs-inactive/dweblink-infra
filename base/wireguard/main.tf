variable "count" {
  type = "string"
}

variable "connections" {
  type = "list"
}

variable "listen_addrs" {
  type = "list"
}

variable "listen_port" {
  default = 51820
}

variable "interface" {
  default = "wg0"
}

variable "private_ipv4s" {
  type = "list"
}

resource "null_resource" "wireguard" {
  count = "${var.count}"

  triggers {
    # TODO this generates new keys everytime :/
    # interface_conf = "${join("\n\n", data.template_file.interface.*.rendered)}"
    count = "${var.count}"
  }

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/install-kernel-headers.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "DEBIAN_FRONTEND=noninteractive apt-get install -yq software-properties-common python-software-properties build-essential",
      "add-apt-repository -y ppa:wireguard/wireguard",
      "apt-get update -q",
      "DEBIAN_FRONTEND=noninteractive apt-get install -yq wireguard-dkms wireguard-tools",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/templates/wireguard@.service"
    destination = "/etc/systemd/system/wireguard@.service"
  }

  provisioner "file" {
    content     = "${element(data.template_file.interface.*.rendered, count.index)}"
    destination = "/etc/wireguard/${var.interface}.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /etc/wireguard/${var.interface}.conf",
      "systemctl daemon-reload",
      "systemctl is-enabled wireguard@${var.interface}.service || systemctl enable wireguard@${var.interface}.service",
      "systemctl restart wireguard@${var.interface}.service",
      "ufw allow from any to ${element(var.connections, count.index)} port ${var.listen_port} proto udp",
      "ufw allow from 10.42.0.0/16",
    ]
  }
}

data "template_file" "interface" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/interface.conf")}"

  vars {
    address     = "${element(var.private_ipv4s, count.index)}"
    port        = "${var.listen_port}"
    private_key = "${element(data.external.keys.*.result.private_key, count.index)}"
    peers       = "${replace(join("\n", data.template_file.peers.*.rendered), element(data.template_file.peers.*.rendered, count.index), "")}"
  }
}

data "template_file" "peers" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/peer.conf")}"

  vars {
    endpoint    = "${format("%s:%s", element(var.listen_addrs, count.index), var.listen_port)}"
    public_key  = "${element(data.external.keys.*.result.public_key, count.index)}"
    allowed_ips = "${format("%s/32", element(var.private_ipv4s, count.index))}"
  }
}

data "external" "keys" {
  count = "${var.count}"

  program = ["sh", "${path.module}/scripts/gen_keys.sh"]
}

output "private_ipv4s" {
  value = ["${var.private_ipv4s}"]
}

output "vpn_unit" {
  depends_on = ["null_resource.wireguard"]
  value      = "wireguard@${var.interface}.service"
}

output "vpn_interface" {
  value = "${var.interface}"
}

output "vpn_port" {
  value = "${var.listen_port}"
}
