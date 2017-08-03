job "vpn" {
  datacenters = ${datacenters}
  type = "service"

  group "vpn" {
    count = ${count}
    restart {
      mode = "delay"
      delay = "15s"
    }

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
        volumes = [
          "${data_dir}:/etc/openvpn",
          "${status_dir}:/tmp/openvpn"
        ]
        # No capabilities support in nomad yet.
        privileged = true
        # I'm not sure the image can deal with host networking.
        # The iptables rules seem to get lost.
        #network_mode = "host"
        mac_address = "${mac_address}"
      }

      resources {
        network {
          port "openvpn" {
            static = "${port}"
          }
        }
      }
    }

    task "ndppd" {
      driver = "docker"

      config {
        image = "ajacques/ndppd"
        privileged = true
        network_mode = "host"
        command = "/usr/local/sbin/ndppd"
        args = [
          "-c", "/ndppd/ndppd.conf",
        ]
        volumes = [
          "/opt/ndppd:/ndppd:ro"
        ]
      }

      env {
        INTERFACE = "ens3"
        SUBNET_ADDR = "${ipv6_network}"
      }
    }

    task "openvpn_exporter" {
      driver = "docker"

      config {
        image = "lgierth/openvpn_exporter:v0.2-5-g5c1e6df"
        args = [
          "-web.listen-address", ":${exporter_port}",
          "-openvpn.status_paths", "/tmp/openvpn/status.log",
        ]
        volumes = [
          "${status_dir}:/tmp/openvpn:ro"
        ]
      }

      resources {
        network {
          port "openvpn_exporter" {
            static = "${exporter_port}"
          }
        }
      }
    }
  }
}
