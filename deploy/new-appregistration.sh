# Create a new app registration for the file copy

az ad sp create-for-rbac -n sp-b2capimazfunc-upload-dev-01 --role 'Storage Blob Data Contributor' --scopes '/subscriptions/ce167e67-9065-4703-ae02-b0ee721302a9/resourceGroups/rg-azlabs-b2capimazfunc-dev-001/providers/Microsoft.Storage/storageAccounts/stob2capmazfuncdev01/blobServices/default/containers/$web'
