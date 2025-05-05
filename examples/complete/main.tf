locals {
  default_group_settings = {
    allow_external_members                         = false
    allow_web_posting                              = true
    archive_only                                   = false
    custom_roles_enabled_for_settings_to_be_merged = false
    enable_collaborative_inbox                     = false
    is_archived                                    = false
    primary_language                               = "en_US"
    who_can_join                                   = "ALL_IN_DOMAIN_CAN_JOIN"
    who_can_assist_content                         = "OWNERS_AND_MANAGERS"
    who_can_view_group                             = "ALL_IN_DOMAIN_CAN_VIEW"
    who_can_view_membership                        = "ALL_IN_DOMAIN_CAN_VIEW"
  }
}


module "googleworkspace" {
  source = "../../"

  users = {
    "first.last@example.com" = {
      primary_email = "first.last@example.com"
      family_name   = "Last"
      given_name    = "First"
      password      = "insecure-password-for-example" # trunk-ignore(checkov/CKV_SECRET_6)
      groups = {
        "platform" = {
          role = "MEMBER"
        }
      }
    }
  }

  groups = {
    "support" = {
      name  = "Support"
      email = "support@example.com"
      settings = merge(local.default_group_settings, {
        enable_collaborative_inbox = true,
      })
    },
    "platform" = {
      name     = "Platform"
      email    = "platform@example.com"
      settings = merge(local.default_group_settings, {})
    },
    "engineers" = {
      name  = "Engineering"
      email = "engineering@example.com"
      settings = merge(local.default_group_settings, {
        who_can_join            = "INVITED_CAN_JOIN",
        who_can_view_group      = "ALL_MEMBERS_CAN_VIEW",
        who_can_view_membership = "ALL_MEMBERS_CAN_VIEW",
      })
    }
  }
}
