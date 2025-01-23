variable "aws_region" {
  type        = string
  description = "AWS Region for deployment"
  default     = "ap-south-1"
}

variable "aws_profile" {
  type        = string
  description = "AWS Profile to use"
}

variable "project_name" {
  type        = string
  description = "Project name"
  default     = "neo4j"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "prod"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where resources will be created"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where EC2 instances will be launched"
}

variable "instances" {
  type = list(object({
    name          = string
    instance_type = string
    root_volume = object({
      size = number
      type = string
    })
    ebs_volumes = list(object({
      size     = number
      type     = string
      vol_name = string
    }))
  }))
  description = "List of Neo4j instances to create"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instances"
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
}

variable "create_ssh_key" {
  type        = bool
  description = "Whether to create a new SSH key pair"
  default     = false
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "List of CIDRs to allow in security group"
  default     = ["0.0.0.0/0"]
}