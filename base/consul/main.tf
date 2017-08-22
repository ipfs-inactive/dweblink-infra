variable "depends_on" {
  default = ""
}

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

variable "docker_image" {
  default = "consul:latest"
}

variable "docker_opts" {
  default = "--restart=always"
}

variable "data_dir" {
  default = "/opt/consul/data"
}

variable "config_dir" {
  default = "/opt/consul/config"
}

resource "null_resource" "install" {
  count = "${var.count}"

  triggers {
    conf       = "${sha256(element(data.template_file.config.*.rendered, count.index))}"
    docker     = "${var.docker_image} ${var.docker_opts}"
    depends_on = "${var.depends_on}"
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
    destination = "${var.config_dir}/consul.json"
  }

  provisioner "remote-exec" {
    inline = [
      "docker stop consul && docker rm consul",
      "docker run -d --name=consul --net=host -v ${var.config_dir}:/consul/config -v ${var.data_dir}:/consul/data ${var.docker_opts} ${var.docker_image} agent",
    ]
  }
}

data "template_file" "config" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/config.json")}"

  vars {
    bind       = "${element(var.ipv4s, count.index)}"
    datacenter = "${element(var.datacenters, count.index)}"
    retry_join = "${join("\", \"", var.servers)}"

    # TODO this is a mess :/ see https://github.com/hashicorp/terraform/issues/15291
    server           = "${length(var.servers) == length(compact(split(",", replace(join(",", var.servers), element(var.ipv4s, count.index), "")))) ? "false" : "true"}"
    bootstrap_expect = "${length(var.servers) == length(compact(split(",", replace(join(",", var.servers), element(var.ipv4s, count.index), "")))) ? 0 : floor(length(var.servers)/2)+1}"
  }
}
