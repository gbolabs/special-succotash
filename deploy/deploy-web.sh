# az login with service principal
az logout
az login --service-principal -u 2e415952-150f-4726-93bd-ebfe1a99311a -p $AZSP_PASSWORD -t 1d4783f4-883d-4508-8466-75c99fdf6d1c

# update version
date +%Y-%m-%d_%H-%M-%S > ../src/web/version.txt

# clear destination
 az storage blob delete-batch --source \$web --account-name stob2capmazfuncdev01 --auth-mode login

 # upload local
 az storage blob upload-batch --destination \$web --source ../src/web --account-name stob2capmazfuncdev01 --auth-mode login


 az cdn endpoint purge --resource-group rg-azlabs-b2capimazfunc-dev-001 --profile-name cdn-b2capimazfunc-dev-01 --name b2capimazfunc-dev --content-paths '/'


az logout