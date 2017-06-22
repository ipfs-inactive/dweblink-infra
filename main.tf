module "inventory" {
  source = "./base/inventory"

  hosts = "${var.hosts}"
  ssh_keys = "${var.ssh_keys}"
  domain_name = "${var.domain_name}"
  tag = "${var.hosts_tag}"
}

module "wireguard" {
  source = "./base/wireguard"

  connections = "${module.inventory.public_ipv4s}"
  listen_addrs = "${module.inventory.public_ipv4s}"
  listen_port = 51820
  interface = "wg0"
  private_ipv4s = "${module.inventory.private_ipv4s}"
}

module "docker" {
  source = "./base/docker"

  connections = "${module.inventory.public_ipv4s}"
}

module "consul" {
  source = "./base/consul"
  depends_on = ["${module.docker.dependency}"]

  connections = "${module.inventory.public_ipv4s}"
  private_ipv4s = "${module.inventory.private_ipv4s}"
  docker_image = "consul:0.8.4"
  servers = "${var.coordinators}"
  datacenters = "${module.inventory.datacenters}"
}
