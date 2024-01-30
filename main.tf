resource "aws_efs_file_system" "fs" {
  throughput_mode = var.efs_throughput_mode

  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  lifecycle_policy {
    transition_to_ia = lookup(var.efs_transitions, "to_infrequent_access")
  }

  lifecycle_policy {
    transition_to_archive = var.efs_throughput_mode == "elastic" ? lookup(var.efs_transitions, "to_archive") : null

  }
}

resource "aws_efs_access_point" "ap" {
  file_system_id = aws_efs_file_system.fs.id

  posix_user {
    uid = lookup(var.access_meta, "posix_uid")
    gid = lookup(var.access_meta, "posix_gid")
  }

  root_directory {
    path = lookup(var.access_meta, "expose_as_root_dir")
    creation_info {
      owner_uid   = lookup(var.access_meta, "posix_uid")
      owner_gid   = lookup(var.access_meta, "posix_gid")
      permissions = lookup(var.access_meta, "unix_permissions")
    }
  }
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.fs.id

  backup_policy {
    status = var.backups_enabled
  }
}

resource "aws_efs_mount_target" "mt" {
  file_system_id  = aws_efs_file_system.fs.id
  subnet_id       = var.efs_mount_subnet
  security_groups = var.mount_target_security_groups
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "Statement01"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
    ]

    resources = [aws_efs_file_system.fs.arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_efs_file_system_policy" "secure" {
  file_system_id = aws_efs_file_system.fs.id
  policy         = data.aws_iam_policy_document.policy.json
}
