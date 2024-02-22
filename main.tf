resource "aws_efs_file_system" "fs" {
  encrypted       = true
  throughput_mode = var.efs_throughput_mode

  /**
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  lifecycle_policy {
    transition_to_ia = lookup(var.efs_transitions, "to_infrequent_access")
  }

  lifecycle_policy {
    transition_to_archive = var.efs_throughput_mode == "elastic" ? lookup(var.efs_transitions, "to_archive") : null
  }
**/

  tags = {
    Name = lookup(var.default_tags, "project")
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

  tags = {
    Name = lookup(var.default_tags, "project")
  }
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.fs.id

  backup_policy {
    status = var.backups_enabled
  }
}

resource "aws_security_group" "efs" {
  description = "Attach to app services for EFS access"

  name_prefix = "efs-self-access-"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow from self"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Access EFS"
  }
}

resource "aws_efs_mount_target" "mt" {
  for_each = toset(var.efs_mount_subnets)

  file_system_id  = aws_efs_file_system.fs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
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
