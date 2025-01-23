data "cloudinit_config" "neo4j-cloudinit" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "00-init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("scripts/init.cfg", { REGION = var.aws_region })
  }

  part {
    filename     = "01-volumes.sh"
    content_type = "text/x-shellscript"
    content      = file("scripts/volumes.sh")
  }

  part {
    filename     = "02-docker.sh"
    content_type = "text/x-shellscript"
    content      = file("scripts/docker_setup.sh")
  }

  part {
    filename     = "03-swap.sh"
    content_type = "text/x-shellscript"
    content      = file("scripts/swap_dockerdata.sh")
  }

  part {
    filename     = "04-neo4j.sh"
    content_type = "text/x-shellscript"
    content      = file("scripts/setup_neo4j.sh")
  }

  part {
    filename     = "05-nginx.sh"
    content_type = "text/x-shellscript"
    content      = file("scripts/setup_nginx.sh")
  }
}