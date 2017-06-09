module "inventory" {
  source = "./base/inventory"

  hosts = "${var.hosts}"
  ssh_keys = "${var.ssh_keys}"
  domain_name = "${var.domain_name}"
  tag = "${var.hosts_tag}"
}
