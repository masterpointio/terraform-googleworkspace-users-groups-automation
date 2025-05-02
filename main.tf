resource "googleworkspace_user" "users" {
  # https://registry.terraform.io/providers/hashicorp/googleworkspace/latest/docs/resources/user
  for_each = var.users

  aliases                        = each.value.aliases
  change_password_at_next_login  = each.value.change_password_at_next_login
  hash_function                  = each.value.hash_function
  include_in_global_address_list = each.value.include_in_global_address_list
  ip_allowlist                   = each.value.ip_allowlist
  is_admin                       = each.value.is_admin
  name {
    family_name = each.value.family_name
    given_name  = each.value.given_name
  }
  org_unit_path  = each.value.org_unit_path
  password       = each.value.password == null ? null : each.value.password
  primary_email  = each.value.primary_email
  recovery_email = each.value.recovery_email
  recovery_phone = each.value.recovery_phone
  suspended      = each.value.suspended

  lifecycle {
    ignore_changes = [
      password,
      recovery_email,
      recovery_phone,
      suspended,
    ]
  }
}

resource "googleworkspace_group" "groups" {
  for_each = var.groups

  email       = each.value.email
  description = each.value.description
  name        = each.value.name

  timeouts {
    create = each.value.timeouts.create
    update = each.value.timeouts.update
  }
}
