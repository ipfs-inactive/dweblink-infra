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
  private_ipv4s = "${module.inventory.private_ipv4s}"
  vpn_interface = "wg0"
  vpn_port = "45769"
}
