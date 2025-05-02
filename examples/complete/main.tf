terraform {
  required_providers {
    googleworkspace = {
      source  = "hashicorp/googleworkspace"
      version = "0.7.0"
    }
  }
}

provider "googleworkspace" {
  # use my_customer not your actual customer_id.
  # Custom Schemas on the user object will fail if the customer_id is set to your actual customer_id.
  # For more details see: https://developers.google.com/workspace/admin/directory/reference/rest/v1/schemas/get
  customer_id = "my_customer"

  credentials             = "/Users/my_user/Downloads/my-google-project-credentials-1234567890.json"
  impersonated_user_email = "my_impersonated_user_email@my_domain.com"

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.user",
    "https://www.googleapis.com/auth/admin.directory.userschema",
    "https://www.googleapis.com/auth/apps.groups.settings",
    "https://www.googleapis.com/auth/iam",
  ]
}

module "googleworkspace" {
  source = "../../"
  # source = "git::https://github.com/weston-masterpoint/terraform-googleworkspace-users-groups.git"

  users = {
    "first.last@example.com" = {
      primary_email = "first.last@example.com"
      family_name   = "Last"
      given_name    = "First"
      # echo -n "insecure-password-for-example" | md5
      password      = "76d28d4cca70533479b7b4fdc25abf41" #  trunk-ignore(checkov/CKV_SECRET_6)
      hash_function = "MD5"
    }
  }
}
