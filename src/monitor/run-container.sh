imageName="acrisagocmd001.azurecr.io/pwshmonitoring:1.0"

docker run -it -e APP_MONITORURI=https://b2capimazfunc-dev.azureedge.net/version.txt -e APP_MONITORDURATION=10 $imageName
