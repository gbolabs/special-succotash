# clear destination
 az storage blob delete-batch --source \$web --account-name stob2capmazfuncdev01 --auth-mode login

 # upload local
 az storage blob upload-batch --destination \$web --source ../src/web --account-name stob2capmazfuncdev01 --auth-mode login