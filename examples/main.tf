module "vpc" {
  source = "git::https://gitlab.com/eternaltyro/terraform-aws-vpc.git"

  project_meta = var.project_meta

  deployment_environment = var.deployment_environment
  default_tags           = var.default_tags
}

module "efs" {
  source = "git::https://gitlab.com/eternaltyro/terraform-aws-efs.git"
  //source = "./.."

  mount_target_security_groups = [ module.vpc.default_security_group_id ]
  efs_mount_subnet             = module.vpc.private_subnets[1]

  default_tags = var.default_tags
}
