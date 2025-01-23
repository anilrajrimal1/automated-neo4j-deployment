resource "aws_security_group" "neo4j_sg" {
  name_prefix = "${local.name}-sg"
  description = "Security group for Neo4j instances"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = [
      { port = 22, desc = "SSH" },
      { port = 80, desc = "HTTP" },
      { port = 443, desc = "HTTPS" },
      { port = 7474, desc = "Neo4j HTTP" },
      { port = 7687, desc = "Neo4j Bolt" }
    ]
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidrs
      description = ingress.value.desc
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}