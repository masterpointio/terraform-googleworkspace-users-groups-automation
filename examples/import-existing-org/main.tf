locals {
  _all_groups = yamldecode(file("groups.yaml"))
  _all_users  = yamldecode(file("users.yaml"))

  # skip objects that start with "_", which we use as default or prototype objects
  groups = { for k, v in local._all_groups : k => v if !startswith(k, "_") }
  users  = { for k, v in local._all_users : k => v if !startswith(k, "_") }
}

module "googleworkspace_users_groups" {
  source = "../../"

  users  = local.users
  groups = local.groups
}

