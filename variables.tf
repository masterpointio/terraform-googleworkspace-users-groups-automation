variable "users" {
  # Optional values are set by provider defaults (except with array values)
  # https://registry.terraform.io/providers/hashicorp/googleworkspace/latest/docs/resources/user

  description = "List of users"
  type = map(object({
    # addresses
    aliases : optional(list(string), []),
    archived : optional(bool, false),
    change_password_at_next_login : optional(bool),
    custom_schemas : optional(list(object({
      schema_name : string,
      schema_values : optional(map(string), {}),
    })), []),
    # emails
    # external_ids
    family_name : string,
    given_name : string,
    groups : optional(map(object({
      role : optional(string, "MEMBER"),
      delivery_settings : optional(string, "ALL_MAIL"),
      type : optional(string, "USER"),
    })), {}),
    # ims
    include_in_global_address_list : optional(bool),
    ip_allowlist : optional(bool),
    is_admin : optional(bool),
    # keywords
    # languages
    # locations
    org_unit_path : optional(string),
    # organizations
    # phones
    # posix_accounts
    primary_email : string,
    recovery_email : optional(string),
    recovery_phone : optional(string),
    # relations
    # ssh_public_keys
    suspended : optional(bool),
    # timeouts
    # websites

    # User attributes with unique constraints

    # password and hash_function
    # If a hashFunction is specified, the password must be a valid hash key.
    # If it's not specified, the password should be in clear text and between
    # 8–100 ASCII characters.
    # https://developers.google.com/workspace/admin/directory/v1/guides/manage-users
    hash_function : optional(string),
    password : optional(string),
  }))
  default = {}

  # validate primary email address
  validation {
    condition = alltrue(flatten([
      for user in var.users : [can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", user.primary_email))]
    ]))
    error_message = "Invalid primary email address"
  }

  # validate password length
  validation {
    condition = alltrue(flatten([
      for user in var.users : [
        user.password == null ? true : length(user.password) >= 8 && length(user.password) <= 100
      ]
    ]))
    error_message = "Password must be between 8 and 100 characters when provided"
  }

  # validate hash function
  validation {
    condition = alltrue([
      for user in var.users :
      user.password == null || (
        user.password != null && (
          user.hash_function == "SHA-1" ||
          user.hash_function == "MD5" ||
          user.hash_function == "crypt" ||
          user.hash_function == null
        )
      )
    ])
    error_message = "hash_function must be either 'SHA-1', 'MD5', 'crypt', or null when password is provided"
  }

  # validate users.groups.[group_key].role
  validation {
    condition = alltrue(flatten([
      for user in var.users : [
        for group in values(try(user.groups, {})) : (
          group.role == null || contains(["MEMBER", "OWNER", "MANAGER"], upper(group.role))
        )
      ]
    ]))
    error_message = "group role must be either 'member', 'owner', or 'manager'"
  }

  # validate users.groups.[group_key].type
  validation {
    condition = alltrue(flatten([
      for user in var.users : [
        for group in values(try(user.groups, {})) : (
          group.type == null || contains(["USER", "GROUP", "CUSTOMER"], upper(group.type))
        )
      ]
    ]))
    error_message = "group type must be either 'USER', 'GROUP', or 'CUSTOMER'"
  }

  # validate that schema_values's values can be JSON encoded (required by Google Workspace provider)
  validation {
    condition = alltrue(flatten([
      for user in var.users : [
        for schema in user.custom_schemas : [
          for key, value in schema.schema_values : can(jsonencode(value))
        ]
      ]
    ]))
    error_message = "All values in custom schema values must be JSON encodable strings"
  }
}

variable "groups" {
  # https://registry.terraform.io/providers/hashicorp/googleworkspace/latest/docs/resources/group
  description = "List of groups"
  type = map(object({
    name : string,
    description : optional(string),
    email : string,
    timeouts : optional(object({
      create : optional(string),
      update : optional(string),
      }), {
      create = null
      update = null
    }),
    # https://registry.terraform.io/providers/hashicorp/googleworkspace/latest/docs/resources/group_settings
    settings : optional(object({
      allow_external_members : optional(bool),
      allow_web_posting : optional(bool),
      archive_only : optional(bool),
      custom_footer_text : optional(string),
      custom_reply_to : optional(string),
      default_message_deny_notification_text : optional(string),
      enable_collaborative_inbox : optional(bool),
      include_custom_footer : optional(bool),
      include_in_global_address_list : optional(bool),
      is_archived : optional(bool),
      members_can_post_as_the_group : optional(bool),
      message_moderation_level : optional(string),
      primary_language : optional(string),
      reply_to : optional(string),
      send_message_deny_notification : optional(bool),
      spam_moderation_level : optional(string),
      who_can_assist_content : optional(string),
      who_can_contact_owner : optional(string),
      who_can_discover_group : optional(string),
      who_can_join : optional(string),
      who_can_leave_group : optional(string),
      who_can_moderate_content : optional(string),
      who_can_moderate_members : optional(string),
      who_can_post_message : optional(string),
      who_can_view_group : optional(string),
      who_can_view_membership : optional(string),
    }), {}),
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for group in var.groups : [can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", group.email))]
    ]))
    error_message = "Invalid group email address"
  }
}
