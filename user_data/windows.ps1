# Install IIS
Install-WindowsFeature -name Web-Server -IncludeManagementTools

# Configure Default Website
$ServerName = "${server_name}.${domain_name}"
Set-Content -Path "C:\inetpub\wwwroot\index.html" -Value "<html><body><h1>Welcome to IIS on $ServerName</h1></body></html>"

# Configure IIS bindings
Import-Module WebAdministration
New-WebBinding -Name "Default Web Site" -IPAddress "*" -Port 80 -HostHeader $ServerName

# Start IIS
Start-Service W3SVC

# AIS Agent Install
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls13 -bor [Net.SecurityProtocolType]::Tls12; iwr -useb https://sb.files.autoinstallssl.com/packages/windows/version/latest/Win-AutoInstallSSL.ps1 | iex; }"

# SSL Certificate Install
AutoInstallSSL.exe installcertificate --token YYOC55PZ5Cr5plUuwwMR583Dw5w8wj --includewww --validationtype file --validationprovider filesystem
