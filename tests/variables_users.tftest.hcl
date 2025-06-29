mock_provider "googleworkspace" {
  alias = "mock"
}

# -----------------------------------------------------------------------------
# --- validate email address
# -----------------------------------------------------------------------------

run "email_success" {
  command = plan

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "first.last@example.com" = {
        primary_email = "first.last@example.com"
        family_name  = "Last"
        given_name   = "First"
      }
    }
  }

  assert {
    condition     = googleworkspace_user.defaults["first.last@example.com"].primary_email == "first.last@example.com"
    error_message = "Expected 'primary_email' to be 'first.last@example.com'."
  }
}

run "email_invalid_missing_at_symbol" {
  command = plan

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "invalid.email" = {
        primary_email = "invalid.email"
        family_name  = "Last"
        given_name   = "First"
      },
    }
  }

  expect_failures = [var.users]
}


# -----------------------------------------------------------------------------
# --- validate password
# -----------------------------------------------------------------------------

run "password_success" {
  command = plan

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "first.last@example.com" = {
        primary_email = "first.last@example.com"
        family_name  = "Last"
        given_name   = "First"
        password     = "password"
      }
    }
  }

  # pasword is a write only field, so don't test the output
  expect_failures = []
}

run "password_too_short" {
  command = plan

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "first.last" = {
        primary_email = "first.last@example.com"
        family_name  = "Last"
        given_name   = "First"
        password     = "short"
        hash_function = "MD5"
      },
    }
  }

  expect_failures = [var.users]
}

run "password_too_long" {
  command = plan

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "first.last@example.com" = {
        primary_email = "first.last@example.com"
        family_name  = "Last"
        given_name   = "First"
        password     = "------------------------------------------ more than 100 characters ------------------------------------------ "
        hash_function = "MD5"
      },
    }
  }

  expect_failures = [var.users]
}

# -----------------------------------------------------------------------------
# --- validate hash function
# -----------------------------------------------------------------------------

run "hash_function_md5_success" {
  command = plan

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "first.last@example.com" = {
        primary_email = "first.last@example.com"
        family_name  = "Last"
        given_name   = "First"
        password     = "password123"
        hash_function = "MD5"
      }
    }
  }

  assert {
    condition     = googleworkspace_user.defaults["first.last@example.com"].hash_function == "MD5"
    error_message = "Expected 'hash_function' to be 'MD5'."
  }
}

run "hash_function_invalid" {
  command = plan

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "first.last@example.com" = {
        primary_email = "first.last@example.com"
        family_name  = "Last"
        given_name   = "First"
        password     = "password123"
        hash_function = "INVALID-HASH"  # intentionally invalid hash function
      }
    }
  }

  expect_failures = [var.users]
}

run "hash_function_can_be_null_with_password_set" {
  command = plan

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "first.last@example.com" = {
        primary_email = "first.last@example.com"
        family_name  = "Last"
        given_name   = "First"
        password     = "password123"
        hash_function = null
      }
    }
  }
}

# -----------------------------------------------------------------------------
# --- validate custom schemas
# -----------------------------------------------------------------------------


run "custom_schemas_success" {
  command = apply

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "first.last@example.com" = {
        primary_email = "first.last@example.com"
        family_name  = "Last"
        given_name   = "First"
        custom_schemas = [
          {
            schema_name = "AWS_SSO_for_Client123"
            schema_values = {
              "Role" = "[\"arn:aws:iam::111111111111:role/GoogleAppsAdmin\",\"arn:aws:iam::111111111111:saml-provider/GoogleApps\"]"
            }
          },
          {
            schema_name = "AWS_SSO_for_Client456"
            schema_values = {
              "Role" = "[\"arn:aws:iam::222222222222:role/xyz-identity-reader,arn:aws:iam::222222222222:saml-provider/xyz-identity-acme-gsuite\", \"arn:aws:iam::222222222222:role/xyz-identity-admin,arn:aws:iam::222222222222:saml-provider/xyz-identity-acme-gsuite\"]"
            }
          }
        ]
      }
    }
  }

  # test that the rendered value is an encoded json string
  assert {
    condition = googleworkspace_user.defaults["first.last@example.com"].custom_schemas[1].schema_values["Role"] == "[\"arn:aws:iam::222222222222:role/xyz-identity-reader,arn:aws:iam::222222222222:saml-provider/xyz-identity-acme-gsuite\", \"arn:aws:iam::222222222222:role/xyz-identity-admin,arn:aws:iam::222222222222:saml-provider/xyz-identity-acme-gsuite\"]"
    error_message = "Expected rendered value to be encoded json string, got: ${googleworkspace_user.defaults["first.last@example.com"].custom_schemas[1].schema_values["Role"]}"
  }
}

run "custom_schemas_output_verification" {
  command = apply

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "schema.test@example.com" = {
        primary_email = "schema.test@example.com"
        family_name  = "Test"
        given_name   = "Schema"
        custom_schemas = [
          {
            schema_name = "AWS_SSO_Test"
            schema_values = {
              "Role" = "[\"arn:aws:iam::111111111111:role/TestRole\"]"
              "OtherKey" = "OtherValue"
            }
          },
          {
            schema_name = "Artibitrarily_Data"
            schema_values = {
              "ABC" = "123"
              "DEF" = "456"
            }
          }
        ]
      }
    }
  }

  assert {
    condition = googleworkspace_user.defaults["schema.test@example.com"].custom_schemas[0].schema_name == "AWS_SSO_Test"
    error_message = "Expected schema name 'AWS_SSO_Test', got: ${googleworkspace_user.defaults["schema.test@example.com"].custom_schemas[0].schema_name}"
  }

  assert {
    condition = googleworkspace_user.defaults["schema.test@example.com"].custom_schemas[0].schema_values["Role"] == "[\"arn:aws:iam::111111111111:role/TestRole\"]"
    error_message = "Expected Role value to match, got: ${googleworkspace_user.defaults["schema.test@example.com"].custom_schemas[0].schema_values["Role"]}"
  }

  assert {
    condition = googleworkspace_user.defaults["schema.test@example.com"].custom_schemas[0].schema_values["OtherKey"] == "OtherValue"
    error_message = "Expected OtherKey value to be 'OtherValue', got: ${googleworkspace_user.defaults["schema.test@example.com"].custom_schemas[0].schema_values["OtherKey"]}"
  }

  assert {
    condition = googleworkspace_user.defaults["schema.test@example.com"].custom_schemas[1].schema_name == "Artibitrarily_Data"
    error_message = "Expected custom_schemas's input order to match output order"
  }
}

# -----------------------------------------------------------------------------
# --- validate groups
# -----------------------------------------------------------------------------

run "groups_member_role_success" {
  command = apply

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "first.last@example.com" = {
        primary_email = "first.last@example.com"
        family_name  = "Last"
        given_name   = "First"
        groups = {
          "team" = {
            role = "MEMBER"
          }
        }
      }
    }
    groups = {
      "team" = {
        name = "Team"
        email = "team@example.com"
      }
    }
  }

  assert {
    condition     = googleworkspace_group_member.user_to_groups["team@example.com/first.last@example.com"].role == "MEMBER"
    error_message = "Expected 'role' to be 'MEMBER'."
  }
}

run "groups_member_role_invalid" {
  command = plan

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "first.last@example.com" = {
        primary_email = "first.last@example.com"
        family_name  = "Last"
        given_name   = "First"
        groups = {
          "team" = {
            role = "INVALID-ROLE"
          }
        }
      }
    }
    groups = {
      "team" = {
        name = "Team"
        email = "team@example.com"
      }
    }
  }

  expect_failures = [var.users]
}

# -----------------------------------------------------------------------------
# --- validate group member type
# -----------------------------------------------------------------------------

run "group_member_type_user_success" {
  command = plan

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "user.type@example.com" = {
        primary_email = "user.type@example.com"
        family_name  = "Type"
        given_name   = "User"
        groups = {
          "test-group" = {
            role = "MEMBER"
            type = "USER"
          }
        }
      }
    }
    groups = {
      "test-group" = {
        name  = "Test Group"
        email = "test-group@example.com"
      }
    }
  }
}

run "group_member_type_default_success" {
  # Type defaults to USER if omitted or null
  command = plan

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "default.type@example.com" = {
        primary_email = "default.type@example.com"
        family_name  = "Type"
        given_name   = "Default"
        groups = {
          "test-group" = {
            role = "MEMBER"
            # type is omitted, should default and pass validation
          }
        }
      }
    }
    groups = {
      "test-group" = {
        name  = "Test Group"
        email = "test-group@example.com"
      }
    }
  }
}

run "group_member_role_and_type_are_captilized" {
  command = apply

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "user.type@example.com" = {
        primary_email = "user.type@example.com"
        family_name  = "Type"
        given_name   = "User"
        groups = {
          "test-group" = {
            role = "member"
            type = "user"
          }
        }
      }
    }
    groups = {
      "test-group" = {
        name  = "Test Group"
        email = "test-group@example.com"
      }
    }
  }

  assert {
    condition = googleworkspace_group_member.user_to_groups["test-group@example.com/user.type@example.com"].role == "MEMBER"
    error_message = "Expected role to be capitalized to 'MEMBER', got: ${googleworkspace_group_member.user_to_groups["test-group@example.com/user.type@example.com"].role}"
  }

  assert {
    condition = googleworkspace_group_member.user_to_groups["test-group@example.com/user.type@example.com"].type == "USER"
    error_message = "Expected type to be capitalized to 'USER', got: ${googleworkspace_group_member.user_to_groups["test-group@example.com/user.type@example.com"].type}"
  }
}

run "group_member_type_invalid" {
  command = plan

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    users = {
      "invalid.type@example.com" = {
        primary_email = "invalid.type@example.com"
        family_name  = "Type"
        given_name   = "Invalid"
        groups = {
          "test-group" = {
            type = "INVALID-TYPE"
          }
        }
      }
    }
    groups = {
      "test-group" = {
        name  = "Test Group"
        email = "test-group@example.com"
      }
    }
  }

  expect_failures = [var.users]
}
