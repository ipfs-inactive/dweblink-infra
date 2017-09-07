resource "nomad_job" "job" {
  jobspec = "${data.template_file.jobspec.rendered}"
}

data "template_file" "jobspec" {
  template = "${file("${path.module}/templates/caddy.nomad.tpl")}"

  vars {}
}
