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
    groups = {
      "team1@example.com" = {
        email = "team1@example.com"
        name = "Team 1"
      }
    }
  }
}

run "email_invalid_missing_domain" {
  command = plan

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    groups = {
      "invalid.email@example." = {
        email = "invalid.email@example."
        name  = "Team 1"
      },
    }
  }

  expect_failures = [var.groups]
}

# -----------------------------------------------------------------------------
# --- validate group settings
# -----------------------------------------------------------------------------

run "group_settings_specific_values" {
  command = plan

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    groups = {
      "settings-test-group@example.com" = {
        email = "settings-test-group@example.com"
        name  = "Settings Test Group"
        settings = {
          allow_external_members = false
          who_can_join           = "INVITED_CAN_JOIN"
          enable_collaborative_inbox = true
        }
      }
    }
  }
  # We expect this plan to succeed as the structure is valid.
}

run "group_settings_no_settings_block" {
  command = plan

  providers = {
    googleworkspace = googleworkspace.mock
  }

  variables {
    groups = {
      "no-settings-test-group@example.com" = {
        email = "no-settings-test-group@example.com"
        name  = "No Settings Test Group"
        # Settings block is completely omitted, should use default {} and provider defaults
      }
    }
  }
  # We expect this plan to succeed.
}
