job "gw" {
  datacenters = ${datacenters}
  type = "service"

  group "ipfs" {
    count = ${count}

    constraint {
      distinct_hosts = true
    }

    constraint {
      attribute = "$${node.class}"
      value = "gw"
    }

    task "daemon" {
      driver = "docker"

      config {
        image = "${image}:${version}"
        volumes = ["${repo_dir}:/data/ipfs"]
        network_mode = "host"
      }

      # resources {
      #   network {
      #     port "swarm_tcp" {
      #       static = "${swarm_tcp_port}"
      #     }
      #     port "swarm_ws" {
      #       static = "${swarm_ws_port}"
      #     }
      #     port "gateway" {
      #       static = "${gateway_port}"
      #     }
      #     port "api" {
      #       static = "${api_port}"
      #     }
      #   }
      # }
    }
  }
}
