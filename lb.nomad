job "lb" {
  datacenters = ["fra"]

  type = "service"

  constaint {
    attribute = "${nomad.unique.name}"
    value = "lb0.fra.dweblink.net"
  }

  group "lb" {
    count = 1

    constraint {
      distinct_hosts = true
    }

    # constraint {
    #   attribute = "$${node.class}"
    #   value = "gw"
    # }

    task "caddy" {
      plugin "caddy-tlsconsul"
      plugin "caddy-prometheus"
    }
    task "consul-template" {}
  }
}
