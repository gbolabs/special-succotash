FROM mcr.microsoft.com/powershell:lts-centos-7

RUN mkdir -p /opt/pshmonitor/
COPY Monitor-Uri.ps1 /opt/pshmonitor/Monitor-Uri.ps1

CMD pwsh /opt/pshmonitor/Monitor-Uri.ps1 -Verbose
