# Examples: Complete

## Setup

There are 2 provider authentication routes available,
1 - authenticate a service account via API keys
2 - authenticate using API keys and impersonate a real User with Super Admin privileges.

We recommend impersonating a Super Admin, which allows you to grant Admin privileges to users (service Accounts cannot do this).

Follow the provider [authentication setup instructions](https://github.com/hashicorp/terraform-provider-googleworkspace/blob/main/docs/index.md#google-workspace-provider).

Once you've finished the setup process, your provider block should look like this,

```hcl
provider "googleworkspace" {
  # use my_customer not your actual customer_id.
  # Custom Schemas on the user object will fail if the customer_id is set to your actual customer_id.
  # For more details see: https://developers.google.com/workspace/admin/directory/reference/rest/v1/schemas/get
  customer_id = "my_customer"

  credentials = "/Users/my_user/Downloads/my-google-project-credentials-1234567890.json"
  impersonated_user_email = "my_impersonated_user_email@my_domain.com"

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.user",
    "https://www.googleapis.com/auth/admin.directory.userschema",
    "https://www.googleapis.com/auth/apps.groups.settings",
    "https://www.googleapis.com/auth/iam",
  ]
}
```
