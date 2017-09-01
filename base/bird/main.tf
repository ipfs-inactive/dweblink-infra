variable "count" {
  type = "string"
}

variable "connections" {
  type = "list"
}

variable "bird_version" {
  default = "v1.6.3"
}

variable "bird_run_dir" {
  default = "/var/run/bird"
}

variable "bird_run_user" {
  default = "bird"
}

variable "public_ipv4s" {
  type = "list"
}

variable "public_ipv6s" {
  type = "list"
}

variable "local_as" {
  type = "string"
}

variable "neighbor_as" {
  default = "64515"
}

variable "neighbor_ipv4" {
  default = "169.254.169.254"
}

variable "neighbor_ipv6" {
  default = "2001:19f0:ffff::1"
}

variable "neighbor_password" {
  type = "string"
}

resource "null_resource" "install" {
  count = "${var.count}"

  triggers {
    version = "${var.bird_version}"
  }

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
    timeout = "30s"
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /tmp/bird-git",
      "git clone -q https://gitlab.labs.nic.cz/labs/bird /tmp/bird-git",
      "cd /tmp/bird-git",
      "git checkout ${var.bird_version}",
      "autoconf",
      "./configure --sysconfdir /etc --localstatedir /var --enable-ipv6=no && make && make install",
      "./configure --sysconfdir /etc --localstatedir /var --enable-ipv6=yes && make && make install",
      "getent passwd ${var.bird_run_user} || adduser --quiet --system --group --no-create-home --home ${var.bird_run_dir} ${var.bird_run_user}",
      "mkdir -p ${var.bird_run_dir}",
      "chown ${var.bird_run_user}:${var.bird_run_user} ${var.bird_run_dir}",
      "chmod 755 ${var.bird_run_dir}",
    ]
  }
}

resource "null_resource" "configure" {
  count      = "${var.count}"
  depends_on = ["null_resource.install"]

  triggers {
    svc   = "${sha256(file("${path.module}/templates/bird.service"))}"
    svc6  = "${sha256(file("${path.module}/templates/bird6.service"))}"
    conf  = "${sha256(join("\n", data.template_file.bird_conf.*.rendered))}"
    conf6 = "${sha256(join("\n", data.template_file.bird6_conf.*.rendered))}"
  }

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
    timeout = "30s"
  }

  provisioner "file" {
    source      = "${path.module}/templates/bird.service"
    destination = "/etc/systemd/system/bird.service"
  }

  provisioner "file" {
    source      = "${path.module}/templates/bird6.service"
    destination = "/etc/systemd/system/bird6.service"
  }

  provisioner "file" {
    content     = "${element(data.template_file.bird_conf.*.rendered, count.index)}"
    destination = "/etc/bird.conf"
  }

  provisioner "file" {
    content     = "${element(data.template_file.bird6_conf.*.rendered, count.index)}"
    destination = "/etc/bird6.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "ufw allow from ${var.neighbor_ipv4} to ${element(var.public_ipv4s, count.index)} port 179 proto tcp",
      "ufw allow from ${var.neighbor_ipv6} to ${element(var.public_ipv6s, count.index)} port 179 proto tcp",
      "systemctl daemon-reload",
      "systemctl is-enabled bird.service || systemctl enable bird.service",
      "systemctl is-active bird.service || systemctl start bird.service",
      "systemctl is-enabled bird6.service || systemctl enable bird6.service",
      "systemctl is-active bird6.service || systemctl start bird6.service",
      "systemctl reload bird.service",
      "systemctl reload bird6.service",
    ]
  }
}

data "template_file" "bird_conf" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/bird.conf.tpl")}"

  vars {
    router_id         = "${element(var.public_ipv4s, count.index)}"
    local_as          = "${var.local_as}"
    source_address    = "${element(var.public_ipv4s, count.index)}"
    neighbor_address  = "${var.neighbor_ipv4}"
    neighbor_as       = "${var.neighbor_as}"
    neighbor_password = "${var.neighbor_password}"
    interface         = "dummy*"
  }
}

data "template_file" "bird6_conf" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/bird.conf.tpl")}"

  vars {
    router_id         = "${element(var.public_ipv4s, count.index)}"
    local_as          = "${var.local_as}"
    source_address    = "${element(var.public_ipv6s, count.index)}"
    neighbor_address  = "${var.neighbor_ipv6}"
    neighbor_as       = "${var.neighbor_as}"
    neighbor_password = "${var.neighbor_password}"
    interface         = "dummy*"
  }
}
