# Create a new app registration for the file copy

az ad sp create-for-rbac -n sp-b2capimazfunc-upload-dev-01 \
--role 'Storage Blob Data Contributor' \
--scopes '/subscriptions/ce167e67-9065-4703-ae02-b0ee721302a9/resourceGroups/rg-azlabs-b2capimazfunc-dev-001/providers/Microsoft.Storage/storageAccounts/stob2capmazfuncdev01/blobServices/default/containers/$web'

# Add CdnEndpointContributor role to the sp
az role assignment create --assignee '19b86a25-7bc3-4f45-bb04-72503ad0ad0c' \
--role '426e0c7f-0c7e-4658-b36f-ff54d6c29b45' \
--scope '/subscriptions/ce167e67-9065-4703-ae02-b0ee721302a9/resourcegroups/rg-azlabs-b2capimazfunc-dev-001/providers/Microsoft.Cdn/profiles/cdn-b2capimazfunc-dev-01/endpoints/b2capimazfunc-dev'