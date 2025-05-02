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
