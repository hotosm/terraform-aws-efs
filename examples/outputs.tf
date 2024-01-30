output "EFS" {
  value = module.efs.efs_id
}

output "efs_access_point_id" {
  value = module.efs.access_point_id
}

output "efs_mount_target_id" {
  value = module.efs.mount_target_id
}
