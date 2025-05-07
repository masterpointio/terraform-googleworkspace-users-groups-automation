locals {
  # Locals specific to imports

  # While the terraform-googleworkspace-users-groups-autogen module nests
  # group settings in the group object, we need to access the group
  # settings to import them into the provider's tf "group_settings" resource
  group_settings = { for k, v in local._all_groups : k => merge(v.settings, { email = v.email }) if !startswith(k, "_") }

  # _user_with_groups is an intermediate object that is used to flatten
  # the group_members_objects (map of maps) into a single list of objects
  _user_with_groups = {
    for user_key, user in local.users : user_key => user
    if lookup(user, "groups", null) != null
  }

  # flatten the group_members_objects (map of maps) into a single list of objects
  group_members = {
    for obj in flatten([
      for user_key, user in local._user_with_groups : [
        for group_key, group in user.groups : merge(group, {
          user_primary_email = local.users[user_key].primary_email,
          group_email        = local.groups[group_key].email,
          key                = "${local.groups[group_key].email}/${local.users[user_key].primary_email}"
          id                 = "groups/${local.groups[group_key].email}/members/${local.users[user_key].primary_email}"
        })
      ]
    ]) : obj.key => obj
  }
}

import {
  for_each = local.users
  to       = module.googleworkspace_users_groups.googleworkspace_user.defaults[each.value.primary_email]
  id       = each.value.primary_email
}

import {
  for_each = local.groups
  to       = module.googleworkspace_users_groups.googleworkspace_group.defaults[each.key]
  id       = each.value.email
}

import {
  for_each = local.group_settings
  to       = module.googleworkspace_users_groups.googleworkspace_group_settings.defaults[each.key]
  id       = each.value.email
}

import {
  for_each = local.group_members
  to       = module.googleworkspace_users_groups.googleworkspace_group_member.user_to_groups[each.key]

  # The import id can take two formats,
  # - "groups/{group_email}/members/{user_email}"
  # - "groups/{group_id}/members/{user_id}", where group_id and user_id are
  #   large integers.
  #
  # We've chosen to use the "group_email" and "user_email" format to make the
  # code and resources easier to work with.
  id = each.value.id
}
