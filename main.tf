data "template_file" "connections" {
  count = "${length(var.hosts)}"
  template = "$${address}"

  vars {
    address = "${var.use_public_ipv4s == true ? element(module.inventory.public_ipv4s, count.index) : element(module.inventory.private_ipv4s, count.index)}"
  }
}

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
  connections = "${data.template_file.connections.*.rendered}"
  listen_addrs = "${module.inventory.public_ipv4s}"
  listen_port = 51820
  interface = "wg0"
  private_ipv4s = "${module.inventory.private_ipv4s}"
  private_network = "${var.private_network}"
}

module "openvpn" {
  source = "./base/openvpn"

  count = "${length(matchkeys(module.inventory.public_ipv4s, module.inventory.roles, list("vpn")))}"
  connections = "${matchkeys(data.template_file.connections.*.rendered, module.inventory.roles, list("vpn"))}"
  domain_name = "vpn.${var.domain_name}"
  network = "${var.vpn_network}"
  ipv6_networks = "${matchkeys(data.template_file.vpn_ipv6_networks.*.rendered, module.inventory.roles, list("vpn"))}"
  ndp_networks = "${matchkeys(module.inventory.public_ipv6_networks, module.inventory.roles, list("vpn"))}"
  routes = ["${var.vpn_routes}"]
  data_dir = "${var.vpn_data_dir}"
  data_src = "${path.module}/${var.vpn_data_src}"
  data_changed = "${data.external.vpn_data_changed.result.changed}"
  gateway_enabled = false
  datacenters = "${distinct(module.inventory.datacenters)}"
}

module "docker" {
  source = "./base/docker"

  count = "${length(var.hosts)}"
  connections = "${data.template_file.connections.*.rendered}"
}

module "consul" {
  source = "./base/consul"
  depends_on = "${module.docker.dependency}"

  count = "${length(var.hosts)}"
  connections = "${data.template_file.connections.*.rendered}"
  private_ipv4s = "${module.wireguard.private_ipv4s}"
  docker_image = "consul:0.8.4"
  servers = "${var.coordinators}"
  datacenters = "${module.inventory.datacenters}"
}

module "nomad" {
  source = "./base/nomad"

  count = "${length(var.hosts)}"
  connections = "${data.template_file.connections.*.rendered}"
  private_ipv4s = "${module.wireguard.private_ipv4s}"
  nomad_version = "0.5.6"
  servers = "${var.coordinators}"
  datacenters = "${module.inventory.datacenters}"
  roles = "${module.inventory.roles}"
  bind_interfaces = ["wg0"]
}

module "bird" {
  source = "./base/bird"

  count = "${length(var.hosts)}"
  connections = "${data.template_file.connections.*.rendered}"
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
  connections = "${matchkeys(data.template_file.connections.*.rendered, module.inventory.roles, list("vpn"))}"
  name = "vpn"
  addresses = "${var.anycast_addresses["vpn"]}"
}

module "anycast_lb" {
  source = "../../ipfs/dweblink-infra/base/anycast"

  count = "${length(matchkeys(module.inventory.public_ipv4s, module.inventory.roles, list("lb")))}"
  connections = "${matchkeys(data.template_file.connections.*.rendered, module.inventory.roles, list("lb"))}"
  name = "lb"
  addresses = "${var.anycast_addresses["lb"]}"
}

# TODO Revisit this once Nomad supports binding container ports to specific IPs.
#      See https://github.com/hashicorp/nomad/issues/646#issuecomment-315416587
module "portfwd_vpn" {
  source = "./base/portfwd"

  count = "${length(matchkeys(module.inventory.public_ipv4s, module.inventory.roles, list("vpn")))}"
  connections = "${matchkeys(data.template_file.connections.*.rendered, module.inventory.roles, list("vpn"))}"

  port = 1194
  from = "${concat(var.anycast_addresses["vpn"], list("$${public_ipv4}/32"))}"
  to = "${matchkeys(module.inventory.private_ipv4s, module.inventory.roles, list("vpn"))}"
  public_ipv4s = "${matchkeys(module.inventory.public_ipv4s, module.inventory.roles, list("vpn"))}"
}
