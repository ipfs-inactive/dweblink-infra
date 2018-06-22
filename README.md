[DEPRECATED]

# dweblink-infra

> Infrastructure for the dweb.link IPFS gateway


## Modules

- base
  - [x] inventory
  - anycast
    - [x] addresses
    - [x] bird
    - [ ] bird_exporter
  - vpn
    - [x] wireguard
    - [ ] topology
    - [x] openvpn
    - [ ] wireguard_exporter
    - [x] openvpn_exporter
- cluster
  - [x] docker
  - [x] consul
  - [x] nomad
  - [ ] consul_exporter
  - [ ] nomad_exporter
- telemetry
  - [ ] prometheus
  - [ ] grafana
  - [ ] logstash
  - [ ] node_exporter
  - [ ] logstash_exporter
- gateway
  - [ ] go-ipfs
  - [ ] consul-template
  - [ ] caddy (tls termination) + caddy-tlsconsul
  - [ ] caddy_exporter
- storage
  - [ ] ipfs-cluster
  - [ ] pinbot


## FAQ

Q: the change i made isn't triggering anything
A: look into the code for the module and resource, and add a respective trigger
A2: terraform taint command

Q: dns records of the private network don't work
A: use 8.8.8.8, or configure dnsmasq with `domain-rebind-ok=/dweblink.net/` (/etc/NetworkManager/dnsmasq.d/rebind.conf)


## Notes

- TF_VAR_use_public_ipv4s=true terraform apply -target=module.inventory
- TF_VAR_use_public_ipv4s=true terraform apply -target=module.wireguard
- TF_VAR_use_public_ipv4s=true terraform apply -target=module.openvpn
- terraform apply -parallelism=1
- for s in $(terraform state list | grep vultr_server); do terraform state show "$s" | grep -P 'ipv4_address|hostname'; echo ---; done

---

- use terraform 0.10.2 for now
- https://github.com/gruntwork-io/terragrunt
- https://news.ycombinator.com/item?id=14539814
- https://blog.gruntwork.io/how-to-use-terraform-as-a-team-251bc1104973

---

networking issues
- remote state is over vpn, so it's tricky to do changes that interrupt vpn connectivity (e.g. openvpn module)
  - make it so bootstrap mode fixes that, e.g. when bootstrap then use local state only
- each consul agent (:8500) is exposed to the whole vpn
- containers can access vpn through host
- ssh (:22) is publicly exposed
- each module does its own firewall setup (ufw) so the inventory module can overwrite others
  - could have firewall module which grabs rules from each module and applies them


## OpenVPN notes

- ipv6
  - https://community.openvpn.net/openvpn/wiki/IPv6
- client isolation
  - http://backreference.org/2010/05/02/controlling-client-to-client-connections-in-openvpn/
- dns
  - https://wiki.archlinux.org/index.php/OpenVPN#DNS
- security
  - https://blog.g3rt.nl/openvpn-security-tips.html

- generate config:
  - `docker run -it -v $(pwd)/secrets/openvpn-data:/etc/openvpn kylemanna/openvpn:2.4 ovpn_genconfig -u udp://vpn.dweblink.net`
- generate pki:
  - `docker run -it -v $(pwd)/secrets/openvpn-data:/etc/openvpn -e EASYRSA_KEY_SIZE=4096 kylemanna/openvpn:2.4 ovpn_initpki`
- generate client:
  - `docker run -it -v $(pwd)/secrets/openvpn-data:/etc/openvpn -e EASYRSA_KEY_SIZE=4096 kylemanna/openvpn:2.4 easyrsa build-client-full $CLIENTNAME nopass`
- get client config:
  - `docker run -it -v $(pwd)/secrets/openvpn-data:/etc/openvpn kylemanna/openvpn:2.4 ovpn_getclient $CLIENTNAME`
- sudo chown -R user:user secrets/openvpn-data/
