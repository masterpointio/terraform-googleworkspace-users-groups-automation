#
# Masterpoint Debugging Script for Google Workspace Imports
#
# This script helps debug import issues with existing users and roles in the Terraform module.
# Use it to confirm the data and formatting of existing users' custom schema keys, values,
# and JSON-encoded strings.
#
# Note: This script is intended for ad-hoc debugging and has not been thoroughly reviewed or tested.
# Use with caution.
#
# Prerequisites:
# - Python 3.x
# - google-auth and google-api-python-client libraries
# - A Google Workspace service account key (JSON)
#
# Example usage:
#   python debugging-script.py
#

from google.oauth2 import service_account
from googleapiclient.discovery import build

# Path to your service account JSON key
SERVICE_ACCOUNT_FILE = 'my-google-admin-api-key.json'

# Replace with your impersonated Google Workspace admin email
DELEGATED_ADMIN = 'first.last@your-company.io'

SCOPES = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.user",
    "https://www.googleapis.com/auth/admin.directory.userschema",
    "https://www.googleapis.com/auth/apps.groups.settings",
    "https://www.googleapis.com/auth/iam",
]

# Load credentials and delegate to admin
credentials = service_account.Credentials.from_service_account_file(
    SERVICE_ACCOUNT_FILE,
    scopes=SCOPES
).with_subject(DELEGATED_ADMIN)


# Build the service
service = build('admin', 'directory_v1', credentials=credentials)


# Call the Directory API to list all user schemas
def list_user_schemas(customer_id='my_customer'):
    try:
        schemas = service.schemas().list(customerId=customer_id).execute()
        for schema in schemas.get('schemas', []):
            print(f"Schema ID: {schema['schemaId']}")
            print(f"Schema Name: {schema['schemaName']}")
            print(f"Fields:")
            for field in schema.get('fields', []):
                print(field)
                # print(f"  - '{field['fieldName']}' ({field['fieldType']})")
                print(f"  - '{field['fieldName']}': '{field['fieldValues']}'")
    except Exception as e:
        print(f"Failed to retrieve schemas: {e}")


def get_user_custom_schemas(user_email):
    try:
        # Use projection='full' to include custom schemas in the response
        user = service.users().get(userKey=user_email, projection='full').execute()
        print(user)
        custom_schemas = user.get('customSchemas', {})

        print(f"Custom schemas for {user_email}:")
        for schema_name, schema_data in custom_schemas.items():
            print(f"  Schema: {schema_name}")
            for field_name, field_value in schema_data.items():
                print(f"    {field_name}: {field_value}")

        return custom_schemas
    except Exception as e:
        print(f"Failed to retrieve user custom schemas: {e}")
        return None


def list_group_members(group_email):
    results = service.members().list(groupKey=group_email).execute()
    members = results.get('members', [])
    for member in members:
        # print(member['email'])
        print(member)


if __name__ == '__main__':
    # list_group_members('team@your-company.io')
    # list_user_schemas()
    get_user_custom_schemas('first.last@your-company.io')
