Write-Host "Running startup.ps1"

$ErrorActionPreference = "STOP"

Import-Module WebAdministration
$website = "Default Web Site"
Write-Host "Checking if $($website) has any existing HTTPS bindings"
$hostHeaders = "${env:HOST_HEADER}".Split(";", [System.StringSplitOptions]::RemoveEmptyEntries)

$certsDirectory = "C:\certs"
$certificateFilePath = Join-Path -Path $certsDirectory -ChildPath "devcert.pfx"
if(-not (Test-Path -Path $certificateFilePath)) {
    Write-Host "No certificate available."
    exit
}
$certificatePasswordFilePath = Join-Path -Path $certsDirectory -ChildPath "devcert.password.txt"
$securePassword = (Get-Content -Path $certificatePasswordFilePath) | ConvertTo-SecureString -AsPlainText -Force
$cert = Import-PfxCertificate -Password $securePassword -CertStoreLocation Cert:\LocalMachine\root -FilePath $certificateFilePath   

function Set-HttpBinding {
    param(
        [string]$SiteName,
        [string]$HostHeader,
        $Certificate
    )
    if ($null -eq (Get-WebBinding -Name $siteName | Where-Object { $_.BindingInformation -eq "*:80:$($hostHeader)" })) {
        Write-Host "Adding a new HTTP binding for $($siteName)"
        $binding = New-WebBinding -Name $siteName -Protocol http -IPAddress * -Port 80 -HostHeader $hostHeader
    } else {
        Write-Host "HTTP binding for $($siteName) already exists"
    }
    if ($null -eq (Get-WebBinding -Name $siteName | Where-Object { $_.BindingInformation -eq "*:443:$($hostHeader)" })) {
        Write-Host "Adding a new HTTPS binding for $($siteName)"
        $binding = New-WebBinding -Name $siteName -Protocol https -IPAddress * -Port 443 -HostHeader $hostHeader
        $binding = Get-WebBinding -Name $siteName -Protocol https
        $binding.AddSslCertificate($Certificate.Thumbprint, "root")
    } else {
        Write-Host "HTTPS binding for $($siteName) already exists"
    }
}
foreach($hostheader in $hostHeaders) {
    Set-HttpBinding -SiteName $website -HostHeader $hostheader -Certificate $cert
}

Write-Host "Starting ServiceMonitor.exe" -ForegroundColor Green
& "C:\ServiceMonitor.exe" "w3svc"