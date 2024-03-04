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

variable "lifecycle_policies" {
  description = "File transition to other storage classes; NOT YET IMPLEMENTED"
  default = {
    transition_to_primary_storage_class = ""
    transition_to_ia                    = "AFTER_30_DAYS"
    transition_to_archive               = "AFTER_90_DAYS"
  }

  validation {
    condition = contains([
      "AFTER_1_DAY", "AFTER_7_DAYS", "AFTER_14_DAYS",
      "AFTER_30_DAYS", "AFTER_60_DAYS", "AFTER_90_DAYS",
      "AFTER_180_DAYS", "AFTER_270_DAYS", "AFTER_365_DAYS"
    ], lookup(var.lifecycle_policies, "transition_to_ia"))
    error_message = "Invalid value for infrequent_access transition value"
  }

  validation {
    condition = contains([
      "AFTER_1_DAY", "AFTER_7_DAYS", "AFTER_14_DAYS",
      "AFTER_30_DAYS", "AFTER_60_DAYS", "AFTER_90_DAYS",
      "AFTER_180_DAYS", "AFTER_270_DAYS", "AFTER_365_DAYS"
    ], lookup(var.lifecycle_policies, "transition_to_archive"))
    error_message = "Invalid value for infrequent_access transition value"
  }
}

variable "efs_throughput_mode" {
  description = "Allowed values: bursting, provisioned, elastic"
  type        = string

  default = "bursting"

  validation {
    condition     = contains(["bursting", "provisioned", "elastic"], var.efs_throughput_mode)
    error_message = "Invalid EFS throughput mode"
  }
}

variable "access_meta" {
  description = "EFS file path, ownership, and permission settings"

  type = object({
    posix_uid          = string
    posix_gid          = string
    unix_permissions   = string
    expose_as_root_dir = string
  })

  default = {
    posix_uid          = "55555"
    posix_gid          = "55555"
    unix_permissions   = "0755"
    expose_as_root_dir = "/"
  }
}

variable "backups_enabled" {
  description = "Switch to enable or disable EFS backups"
  type        = string

  default = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.backups_enabled)
    error_message = "Invalid value; Must be either ENABLED or DISABLED"
  }
}
