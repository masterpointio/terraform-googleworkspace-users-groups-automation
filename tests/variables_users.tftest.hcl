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
        hash_function = "MD5"
      }
    }
  }
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
        hash_function = "INVALID-HASH"  # Invalid hash function
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

  expect_failures = [var.users]
}
