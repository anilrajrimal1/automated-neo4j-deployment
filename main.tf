# EC2 Instances
resource "aws_instance" "neo4j" {
  count         = length(var.instances)
  ami           = var.ami_id
  instance_type = var.instances[count.index].instance_type
  subnet_id     = var.subnet_id
  user_data     = data.cloudinit_config.neo4j-cloudinit.rendered

  root_block_device {
    volume_size = var.instances[count.index].root_volume.size
    volume_type = var.instances[count.index].root_volume.type
    encrypted   = true
  }

  vpc_security_group_ids = [aws_security_group.neo4j_sg.id]
  key_name               = var.create_ssh_key ? aws_key_pair.ssh_key[0].key_name : var.key_name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(local.common_tags, {
    Name = var.instances[count.index].name
  })
}

# EBS Volumes
resource "aws_ebs_volume" "neo4j_ebs" {
  count             = length(local.instance_volumes)
  availability_zone = aws_instance.neo4j[local.instance_volumes[count.index].instance_index].availability_zone
  size              = local.instance_volumes[count.index].size
  type              = local.instance_volumes[count.index].type
  encrypted         = true

  tags = merge(local.common_tags, {
    Name = "${local.instance_volumes[count.index].instance_name}-${local.instance_volumes[count.index].vol_name}"
  })
}

# Volume Attachments
resource "aws_volume_attachment" "neo4j_ebs_attachment" {
  count       = length(local.instance_volumes)
  device_name = "/dev/sd${element(["f", "g", "h", "i", "j", "k"], count.index)}"
  volume_id   = aws_ebs_volume.neo4j_ebs[count.index].id
  instance_id = aws_instance.neo4j[local.instance_volumes[count.index].instance_index].id
}
resource "aws_key_pair" "ssh_key" {
  count      = var.create_ssh_key ? 1 : 0
  key_name   = "${local.name}-key"
  public_key = tls_private_key.ssh[0].public_key_openssh
  tags       = local.common_tags
}

resource "tls_private_key" "ssh" {
  count     = var.create_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  count    = var.create_ssh_key ? 1 : 0
  content  = tls_private_key.ssh[0].private_key_pem
  filename = "${path.module}/keys/${local.name}-key.pem"

  provisioner "local-exec" {
    command = "chmod 400 ${self.filename}"
  }
}