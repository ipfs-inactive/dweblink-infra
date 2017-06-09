# dweblink-infra

> Infrastructure for anycast IPFS gateway at https://dweb.link

## The Stack

- Private networking
  - 1 Wireguard server per region
  - 1 private IPv4 subnet per region
  - N wireguard clients per region
- Monitoring
  - 1 Prometheus server per region
  - 1 hot Prometheus server for private dashboard
  - 1 workspace Prometheus server for adhoc queries
  - 1 archive Prometheus server
  - N cadvisor exporters
  - N mtail exporters
- Orchestration
  - Docker on every host
  - 1 Consul server per region
  - N Consul agents
  - 1 Nomad server
  - N Nomad agents

### links and stuff

- https://raw.githubusercontent.com/hashicorp/nomad/master/demo/vagrant/Vagrantfile
- https://raw.githubusercontent.com/hashicorp/nomad/master/dist/systemd/nomad.service
- https://github.com/dwmkerr/terraform-consul-cluster/blob/master/modules/consul/files/consul-node.sh#L83
- `NOMAD_META_role = "${lookup(var.inventory[count.index], "role"}"`
- ssl certs in consul: https://operator-error.com/2017/02/24/dynamic-nginx-upstreams-from-consul-via-lua-nginx-module/
- https://github.com/Nomon/nomad-exporter
- https://github.com/hobby-kube/provisioning
