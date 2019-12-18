Write-Host "Running startup.ps1"
Import-Module WebAdministration

$securePassword = (Get-Content -Path C:\startup\cert.password.txt) | ConvertTo-SecureString -AsPlainText -Force
$cert = Import-PfxCertificate -Password $securePassword -CertStoreLocation Cert:\LocalMachine\My -FilePath C:\startup\cert.pfx   
$siteName = "Default Web Site"
$thumbprint = $cert.Thumbprint

$binding = New-WebBinding -Name $siteName -Protocol https -IPAddress * -Port 443;
$binding = Get-WebBinding -Name $siteName -Protocol https;
$binding.AddSslCertificate($thumbprint, "my");

& "C:\tools\entrypoints\iis\Development.ps1"