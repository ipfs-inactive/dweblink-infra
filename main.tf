module "inventory" {
  source = "./base/inventory"

  hosts = "${var.hosts}"
  ssh_keys = "${var.ssh_keys}"
  domain_name = "${var.domain_name}"
  image = "${var.image}"
  tag = "${var.hosts_tag}"
}

module "wireguard" {
  source = "./base/wireguard"

  count = "${length(var.hosts)}"
  connections = "${module.inventory.public_ipv4s}"
  listen_addrs = "${module.inventory.public_ipv4s}"
  listen_port = 51820
  interface = "wg0"
  private_ipv4s = "${module.inventory.private_ipv4s}"
}

module "docker" {
  source = "./base/docker"

  count = "${length(var.hosts)}"
  connections = "${module.inventory.public_ipv4s}"
}

module "consul" {
  source = "./base/consul"
  depends_on = "${module.docker.dependency}"

  count = "${length(var.hosts)}"
  connections = "${module.inventory.public_ipv4s}"
  private_ipv4s = "${module.wireguard.private_ipv4s}"
  docker_image = "consul:0.8.4"
  servers = "${var.coordinators}"
  datacenters = "${module.inventory.datacenters}"
}

module "nomad" {
  source = "./base/nomad"

  count = "${length(var.hosts)}"
  connections = "${module.inventory.public_ipv4s}"
  private_ipv4s = "${module.wireguard.private_ipv4s}"
  nomad_version = "0.5.6"
  servers = "${var.coordinators}"
  datacenters = "${module.inventory.datacenters}"
  roles = "${module.inventory.roles}"
}

module "bird" {
  source = "./base/bird"

  count = "${length(var.hosts)}"
  connections = "${module.inventory.public_ipv4s}"
  public_ipv4s = "${module.inventory.public_ipv4s}"
  public_ipv6s = "${module.inventory.public_ipv6s}"
  local_as = "${var.anycast_local_as}"
  neighbor_as = "${var.anycast_neighbor_as}"
  neighbor_ipv4 = "${var.anycast_neighbor_ipv4}"
  neighbor_ipv6 = "${var.anycast_neighbor_ipv6}"
  password = "${var.anycast_password}"
}

module "anycast_vpn" {
  source = "../../ipfs/dweblink-infra/base/anycast"

  count = "${length(matchkeys(module.inventory.public_ipv4s, module.inventory.roles, list("vpn")))}"
  connections = "${matchkeys(module.inventory.public_ipv4s, module.inventory.roles, list("vpn"))}"
  name = "vpn"
  addresses = "${var.anycast_addresses["vpn"]}"
}

module "anycast_lb" {
  source = "../../ipfs/dweblink-infra/base/anycast"

  count = "${length(matchkeys(module.inventory.public_ipv4s, module.inventory.roles, list("lb")))}"
  connections = "${matchkeys(module.inventory.public_ipv4s, module.inventory.roles, list("lb"))}"
  name = "lb"
  addresses = "${var.anycast_addresses["lb"]}"
}
