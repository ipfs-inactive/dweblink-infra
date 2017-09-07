job "gw" {
  datacenters = ["dc1"]

  type = "service"

  group "ipfs" {
    count = 1

    constraint {
      distinct_hosts = true
    }

    # constraint {
    #   attribute = "$${node.class}"
    #   value = "gw"
    # }

    task "daemon" {
      driver = "docker"

      config {
        image = "ipfs/go-ipfs:v0.4.10"
        volumes = ["/home/user/protocol/ipfs/dweblink-infra/ipfspath:/data/ipfs"]
        # network_mode = "host"
      }

      resources {
        network {
          port "swarm_tcp" {
            static = "4001"
          }
          port "gateway" {
            static = "8080"
          }
          port "api" {
            static = "5001"
          }
        }
      }
    }
  }
}
