Write-Host "Running startup.ps1"
Import-Module WebAdministration

$siteName = "Default Web Site"
Write-Host "Checking if $($siteName) has any existing HTTPS bindings"
#$binding = New-WebBinding -Name $siteName -Protocol https -IPAddress * -Port 443

if($null -eq (Get-WebBinding -Name $siteName | Where-Object { $_.BindingInformation -eq "*:80:scms.dev.sxp.local" })) {
    Write-Host "Adding a new HTTP binding for $($siteName)"
    $binding = New-WebBinding -Name $siteName -Protocol http -IPAddress * -Port 80 -HostHeader scms.dev.sxp.local
} else {
    Write-Host "HTTP binding for $($siteName) already exists"
}

if($null -eq (Get-WebBinding -Name $siteName | Where-Object { $_.BindingInformation -eq "*:443:scms.dev.sxp.local" })) {
    Write-Host "Adding a new HTTPS binding for $($siteName)"
    $securePassword = (Get-Content -Path C:\startup\cert.password.txt) | ConvertTo-SecureString -AsPlainText -Force
    $cert = Import-PfxCertificate -Password $securePassword -CertStoreLocation Cert:\LocalMachine\My -FilePath C:\startup\cert.pfx   
    $thumbprint = $cert.Thumbprint
    $binding = New-WebBinding -Name $siteName -Protocol https -IPAddress * -Port 443 -HostHeader scms.dev.sxp.local
    $binding = Get-WebBinding -Name $siteName -Protocol https
    $binding.AddSslCertificate($thumbprint, "my");
} else {
    Write-Host "HTTPS binding for $($siteName) already exists"
}

& "C:\tools\entrypoints\iis\Development.ps1"