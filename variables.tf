variable "users" {
  # Optional values are set by provider defaults (except with array values)
  # https://registry.terraform.io/providers/hashicorp/googleworkspace/latest/docs/resources/user

  description = "List of users"
  type = map(object({
    # addresses
    aliases : optional(list(string), []),
    archived : optional(bool, false),
    change_password_at_next_login : optional(bool),
    # custom_schemas
    # emails
    # external_ids
    family_name : string,
    given_name : string,
    groups : optional(list(object({
      group_id : string, # The value can be the group's email address, group alias, or the unique group ID.
      delivery_settings : optional(string, "ALL_MAIL"),
      role : optional(string, "MEMBER"),
      type : optional(string, "USER"),
    }))),
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
  validation {
    condition = alltrue(flatten([
      for user in var.users : [can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", user.primary_email))]
    ]))
    error_message = "Invalid primary email address"
  }

  validation {
    condition = alltrue(flatten([
      for user in var.users : [
        user.password == null ? true : length(user.password) >= 8 && length(user.password) <= 100
      ]
    ]))
    error_message = "Password must be between 8 and 100 characters when provided"
  }

  validation {
    condition = alltrue([
      for user in var.users :
      user.password == null || (user.hash_function == "SHA-1" || user.hash_function == "MD5" || user.hash_function == "crypt")
    ])
    error_message = "hash_function must be either 'SHA-1', 'MD5', or 'crypt' when password is provided"
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
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for group in var.groups : [can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", group.email))]
    ]))
    error_message = "Invalid group email address"
  }
}
