variable "default_tags" {
  description = "Default resource tags to apply to AWS resources"
  type        = map(string)

  default = {
    project        = ""
    maintainer     = ""
    documentation  = ""
    cost_center    = ""
    IaC_Management = "Terraform"
  }
}

variable "vpc_id" {
  description = "VPC ID in which resources are launched"
  type        = string

  validation {
    condition     = startswith(var.vpc_id, "vpc-")
    error_message = "VPC ID must start with `vpc-`"
  }
}

variable "efs_mount_subnets" {
  description = "Subnets in which EFS mount targets are created"
  type        = list(string)

  default = []
}

variable "efs_transitions" {
  default = {
    to_infrequent_access = "AFTER_30_DAYS"
    to_archive           = "AFTER_90_DAYS"
  }
}

variable "efs_throughput_mode" {
  type        = string
  default     = "bursting"
  description = "Allowed values: bursting, provisioned, elastic"
}

variable "access_meta" {
  type = map(string)

  default = {
    posix_uid          = "55555"
    posix_gid          = "55555"
    unix_permissions   = "0755"
    expose_as_root_dir = "/"
  }
}

variable "backups_enabled" {
  type = string

  default = "ENABLED"
}
