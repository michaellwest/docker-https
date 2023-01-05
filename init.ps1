[CmdletBinding()]
Param (
    [string]
    $HostName = "dev.local"
)

$ErrorActionPreference = "Stop";

Push-Location docker\certs
try {
    $certz = Join-Path -Path (Get-Location) -ChildPath "certz.exe"
    if ($null -ne (Get-Command certz.exe -ErrorAction SilentlyContinue)) {
        # certz installed in PATH
        $certz = "certz"
    } elseif (-not (Test-Path $certz)) {
        Write-Host "Downloading and installing certz certificate tool..." -ForegroundColor Green
        $url = "https://github.com/michaellwest/certz/releases/download/0.2/certz-0.2-win64.exe"
        $webClient = New-Object System.Net.WebClient
        $webClient.Downloadfile($url, $certz)
        
        $currentHash = Get-FileHash -Path $certz -Algorithm SHA256 | Select-Object -Expand Hash
        if ($currentHash -ne "D4625A4B55709DB1854DA8E1A2B93A3DF25C6F4E8FB5C0424A905029BB1FA2B6") {
            Remove-Item $certz -Force
            throw "Invalid certz.exe file"
        }
    }
    Write-Host "Generating Traefik TLS certificate..." -ForegroundColor Green
    & $certz create --f devcert.pfx --san "*.$($HostName)" --p changeit --c devcert.cer --k devcert.key --days 1825
    & $certz install --f devcert.pfx --p changeit --sl localmachine --sn root
}
catch {
    Write-Host "An error occurred while attempting to generate TLS certificate: $_" -ForegroundColor Red
}
finally {
    Pop-Location
}

Write-Host "Done!" -ForegroundColor Green