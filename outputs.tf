output "efs_id" {
  value = aws_efs_file_system.fs.id

  description = "EFS ID"
}

output "access_point_id" {
  value = aws_efs_access_point.ap.id

  description = "Access Point IDs for VPCs"
}

output "mount_target_id" {
  value = [for t in aws_efs_mount_target.mt : t.id]

  description = "List of Mount Target IDs"
}

output "access_security_group" {
  value = aws_security_group.efs.id

  description = "The security group attached to resources to give access to EFS"
}
