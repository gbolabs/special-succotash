# az login --use-device-code
az account set --subscription ce167e67-9065-4703-ae02-b0ee721302a9
az group create --name rg-azlabs-b2capimazfunc-dev-001 --location switzerlandnorth

az deployment group create \
--resource-group rg-azlabs-b2capimazfunc-dev-001 \
--template-file main.bicep \
--mode complete \
--query properties.outputs
#--query "[].[{cdnEndpointHostname:properties.outputs.cdnEndpointHostname.value, cdnEdnpointId:properties.outputs.cdnEdnpointId.value, webBlobId:properties.outputs.webBlobId.value, staticWebsiteUrl:properties.outputs.staticWebsiteUrl.value}]"

