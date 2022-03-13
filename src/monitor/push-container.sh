imageName="acrisagocmd001.azurecr.io/pwshmonitoring:1.0"
az acr login -n $imageName
docker push $imageName