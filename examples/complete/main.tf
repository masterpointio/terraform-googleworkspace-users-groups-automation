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
    "platform" = {
      name        = "Platform"
      email       = "platform@example.com"
      description = "Platform team description"
    }
  }
}
