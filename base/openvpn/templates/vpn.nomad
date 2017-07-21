job "vpn" {
  datacenters = ${datacenters}
  type = "service"

  group "server" {
    count = ${count}

    constraint {
      distinct_hosts = true
    }

    constraint {
      attribute = "$${node.class}"
      value = "vpn"
    }

    task "openvpn" {
      driver = "docker"

      config {
        image = "kylemanna/openvpn:2.4"
        volumes = ["${data_dir}:/etc/openvpn"]
        # No capabilities support in nomad yet.
        privileged = true
        # I'm not sure the image can deal with host networking.
        # The iptables rules seem to get lost.
        #network_mode = "host"
      }

      resources {
        network {
          port "ovpn" {
            static = "${port}"
          }
        }
      }
    }
  }
}
