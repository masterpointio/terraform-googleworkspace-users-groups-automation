provider "googleworkspace" {
  # use the 'my_customer' string, which is an alias that Google's API recognizes to reference your account's customerId.
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
