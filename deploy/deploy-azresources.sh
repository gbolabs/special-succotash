result=$(az deployment group create --resource-group rg-azlabs-b2capimazfunc-dev-001 --template-file main.bicep --query properties.outputs.cdnEndpoint.value -o tsv)
echo $result