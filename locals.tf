locals {
  name = "${var.project_name}-${var.environment}"

  # Common tags for all resources
  common_tags = {
    Name        = local.name
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }

  # Flatten instance and volume configurations
  instance_volumes = flatten([
    for idx, instance in var.instances : [
      for volume in instance.ebs_volumes : {
        instance_index = idx
        instance_name  = instance.name
        size           = volume.size
        type           = volume.type
        vol_name       = volume.vol_name
      }
    ]
  ])
}