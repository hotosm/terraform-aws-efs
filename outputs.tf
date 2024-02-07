output "efs_id" {
  value = aws_efs_file_system.fs.id

  description = "EFS ID"
}

output "access_point_id" {
  value = aws_efs_access_point.ap.id

  description = "Access Point ID"
}

output "mount_target_id" {
  value = aws_efs_mount_target.mt.id

  description = "Mount Target ID"
}

output "root_dir" {
  value = aws_efs_access_point.ap.root_directory[*].path[0]

  description = "Root directory to mount via access point"
}

