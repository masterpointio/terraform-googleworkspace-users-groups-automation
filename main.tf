locals {
  group_settings = {
    for k, v in var.groups : k => merge(v.settings, { email = v.email })
  }

  _user_with_groups = {
    for user_key, user in var.users : user_key => user
    if lookup(user, "groups", null) != null
  }

  # flatten the group_members_objects (map of maps) into a single list of objects
  group_members = {
    for obj in flatten([
      for user_key, user in local._user_with_groups : [
        for group_key, group in user.groups : merge(group, {
          user_primary_email = user.primary_email,
          group_email        = googleworkspace_group.defaults[group_key].email
        })
      ]
    ]) : "${obj.group_email}/${obj.user_primary_email}" => obj
  }
}

resource "googleworkspace_user" "defaults" {
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
      languages,
      password,
      recovery_email,
      recovery_phone,
      suspended,
    ]
  }

  depends_on = [googleworkspace_group.defaults]
}

resource "googleworkspace_group" "defaults" {
  for_each = var.groups

  email       = each.value.email
  description = each.value.description
  name        = each.value.name

  timeouts {
    create = each.value.timeouts.create
    update = each.value.timeouts.update
  }
}

resource "googleworkspace_group_settings" "defaults" {
  # https://registry.terraform.io/providers/hashicorp/googleworkspace/latest/docs/resources/group_settings
  for_each = local.group_settings

  allow_external_members                 = each.value.allow_external_members
  allow_web_posting                      = each.value.allow_web_posting
  archive_only                           = each.value.archive_only
  custom_footer_text                     = each.value.custom_footer_text
  custom_reply_to                        = each.value.custom_reply_to
  default_message_deny_notification_text = each.value.default_message_deny_notification_text
  email                                  = each.value.email
  enable_collaborative_inbox             = each.value.enable_collaborative_inbox
  include_custom_footer                  = each.value.include_custom_footer
  include_in_global_address_list         = each.value.include_in_global_address_list
  is_archived                            = each.value.is_archived
  members_can_post_as_the_group          = each.value.members_can_post_as_the_group
  message_moderation_level               = each.value.message_moderation_level
  primary_language                       = each.value.primary_language
  reply_to                               = each.value.reply_to
  send_message_deny_notification         = each.value.send_message_deny_notification
  spam_moderation_level                  = each.value.spam_moderation_level
  who_can_assist_content                 = each.value.who_can_assist_content
  who_can_contact_owner                  = each.value.who_can_contact_owner
  who_can_discover_group                 = each.value.who_can_discover_group
  who_can_join                           = each.value.who_can_join
  who_can_leave_group                    = each.value.who_can_leave_group
  who_can_moderate_content               = each.value.who_can_moderate_content
  who_can_moderate_members               = each.value.who_can_moderate_members
  who_can_post_message                   = each.value.who_can_post_message
  who_can_view_group                     = each.value.who_can_view_group
  who_can_view_membership                = each.value.who_can_view_membership

  depends_on = [googleworkspace_group.defaults]
}

resource "googleworkspace_group_member" "user_to_groups" {
  # https://registry.terraform.io/providers/hashicorp/googleworkspace/latest/docs/resources/group_member
  for_each = local.group_members

  group_id = each.value.group_email
  email    = each.value.user_primary_email
  role     = upper(each.value.role)
  type     = upper(each.value.type)

  lifecycle {
    ignore_changes = [
      delivery_settings, # ignore user changes to delivery settings
    ]
  }

  depends_on = [googleworkspace_group.defaults, googleworkspace_user.defaults]
}
