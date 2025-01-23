output "instance_ids" {
  description = "IDs of created instances"
  value       = aws_instance.neo4j[*].id
}

output "instance_public_ips" {
  description = "Public IPs of created instances"
  value       = aws_instance.neo4j[*].public_ip
}

output "instance_private_ips" {
  description = "Private IPs of created instances"
  value       = aws_instance.neo4j[*].private_ip
}

output "security_group_id" {
  description = "ID of created security group"
  value       = aws_security_group.neo4j_sg.id
}

output "ebs_volume_ids" {
  description = "IDs of created EBS volumes"
  value       = aws_ebs_volume.neo4j_ebs[*].id
}

output "ssh_key_name" {
  description = "Name of SSH key pair"
  value       = var.create_ssh_key ? aws_key_pair.ssh_key[0].key_name : var.key_name
}