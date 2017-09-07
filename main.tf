variable "bootstrap" {
  default = false
}

data "template_file" "connections" {
  count    = "${length(var.hosts)}"
  template = "$${address}"

  vars {
    address = "${var.bootstrap == true ? element(module.inventory.public_ipv4s, count.index) : element(module.inventory.ipv4s, count.index)}"
  }
}

module "inventory" {
  source = "./base/inventory"

  hosts       = "${var.hosts}"
  ssh_keys    = "${var.ssh_keys}"
  domain_name = "${var.domain_name}"
}

module "wireguard" {
  source = "./base/wireguard"

  count        = "${length(var.hosts)}"
  connections  = "${data.template_file.connections.*.rendered}"
  listen_addrs = "${module.inventory.public_ipv4s}"
  listen_port  = 51820
  interface    = "wg0"
  ipv4s        = "${module.inventory.ipv4s}"
  network      = "${var.network}"
}

module "openvpn" {
  source = "./base/openvpn"

  count           = "${length(matchkeys(module.inventory.ipv4s, module.inventory.roles, list("vpn")))}"
  connections     = "${matchkeys(data.template_file.connections.*.rendered, module.inventory.roles, list("vpn"))}"
  domain_name     = "vpn.${var.domain_name}"
  network         = "${cidrsubnet(var.network, 1, 1)}"
  routes          = ["${cidrsubnet(var.network, 1, 0)}"]
  data            = "${path.module}/${var.vpn_data}"
  data_changed    = "${data.external.vpn_data_changed.result.changed}"
  gateway_enabled = false
  datacenters     = "${distinct(module.inventory.datacenters)}"
}

module "docker" {
  source = "./base/docker"

  count       = "${length(var.hosts)}"
  connections = "${data.template_file.connections.*.rendered}"
}

module "consul" {
  source     = "./base/consul"
  depends_on = "${module.docker.dependency}"

  count        = "${length(var.hosts)}"
  connections  = "${data.template_file.connections.*.rendered}"
  ipv4s        = "${module.wireguard.ipv4s}"
  docker_image = "consul:0.9.2"
  servers      = "${data.template_file.cluster_leaders.*.rendered}"
  datacenters  = "${module.inventory.datacenters}"
}

module "nomad" {
  source = "./base/nomad"

  count           = "${length(var.hosts)}"
  connections     = "${data.template_file.connections.*.rendered}"
  ipv4s           = "${module.wireguard.ipv4s}"
  nomad_version   = "0.5.6"
  servers         = "${data.template_file.cluster_leaders.*.rendered}"
  datacenters     = "${module.inventory.datacenters}"
  roles           = "${module.inventory.roles}"
  bind_interfaces = ["wg0"]
}

module "bird" {
  source = "./base/bird"

  count             = "${length(var.hosts)}"
  connections       = "${data.template_file.connections.*.rendered}"
  public_ipv4s      = "${module.inventory.public_ipv4s}"
  public_ipv6s      = "${module.inventory.public_ipv6s}"
  local_as          = "${var.anycast_local_as}"
  neighbor_password = "${var.anycast_password}"
}

module "anycast_vpn" {
  source = "./base/anycast"

  count       = "${length(matchkeys(module.inventory.public_ipv4s, module.inventory.roles, list("vpn")))}"
  connections = "${matchkeys(data.template_file.connections.*.rendered, module.inventory.roles, list("vpn"))}"
  name        = "vpn"
  addresses   = "${var.anycast_addresses["vpn"]}"
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

module "anycast_lb" {
  source = "./base/anycast"

  count       = "${length(matchkeys(module.inventory.public_ipv4s, module.inventory.roles, list("lb")))}"
  connections = "${matchkeys(data.template_file.connections.*.rendered, module.inventory.roles, list("lb"))}"
  name        = "lb"
  addresses   = "${var.anycast_addresses["lb"]}"
}

# TODO Revisit this once Nomad supports binding container ports to specific IPs.
#      See https://github.com/hashicorp/nomad/issues/646#issuecomment-315416587
module "portfwd_vpn" {
  source = "./base/portfwd"

  count       = "${length(matchkeys(module.inventory.public_ipv4s, module.inventory.roles, list("vpn")))}"
  connections = "${matchkeys(data.template_file.connections.*.rendered, module.inventory.roles, list("vpn"))}"

  port         = 1194
  from         = "${concat(var.anycast_addresses["vpn"], list("$${public_ipv4}/32"))}"
  to           = "${matchkeys(module.inventory.ipv4s, module.inventory.roles, list("vpn"))}"
  public_ipv4s = "${matchkeys(module.inventory.public_ipv4s, module.inventory.roles, list("vpn"))}"
}

module "ipfs" {
  source = "./gateway/ipfs"

  count = "${length(matchkeys(module.inventory.public_ipv4s, module.inventory.roles, list("lb")))}"
  connections = "${matchkeys(data.template_file.connections.*.rendered, module.inventory.roles, list("lb"))}"
  datacenters = "${distinct(module.inventory.datacenters)}"

  image = "ipfs/go-ipfs"
  version = "v0.4.10"
  repo_dir = "/opt/ipfs"
  swarm_tcp_port = "4001"
  swarm_ws_port = "4002"
  api_port = "5001"
  gateway_port = "8080"
}
