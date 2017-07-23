job "mon" {
  datacenters = ["dc1"]
  type = "service"

  group "agent" {
    task "node_exporter"
    task "netdata"
    task "logstash-agent"
  }

  group "monitor" {
    task "prometheus"
    task "grafana"
  }

  group "logger" {
    task "logstash"
  }
}
