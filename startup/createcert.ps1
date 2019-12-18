param (
    [ValidateNotNullOrEmpty()][string]$certificatename = "cert",
    [ValidateNotNullOrEmpty()][SecureString]$certificatepassword = ("b" | ConvertTo-SecureString -Force -AsPlainText)
 )

# setup certificate properties including the commonName (DNSName) property for Chrome 58+
$certificate = New-SelfSignedCertificate `
    -Subject localhost `
    -DnsName localhost `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -NotBefore (Get-Date) `
    -NotAfter (Get-Date).AddYears(10) `
    -CertStoreLocation "cert:CurrentUser\My" `
    -FriendlyName "Localhost Certificate for .NET Core" `
    -HashAlgorithm SHA256 `
    -KeyUsage DigitalSignature, KeyEncipherment, DataEncipherment `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1") 
$certificatePath = 'Cert:\CurrentUser\My\' + ($certificate.ThumbPrint)
# create temporary certificate path
$tmpPath = $PSScriptRoot
if([string]::IsNullOrEmpty($tmpPath)) {
    $tmpPath = $PWD
}
if(!(test-path $tmpPath)) {
    New-Item -ItemType Directory -Force -Path $tmpPath
}
# set certificate password here
$pfxPassword = $certificatepassword
$pfxFilePath = $tmpPath + "\" + $certificatename + ".pfx"
$cerFilePath = $tmpPath + "\" + $certificatename + ".cer"
$cerPasswordFilePath = $tmpPath + "\" + $certificatename + ".password.txt"
# create pfx certificate
Export-PfxCertificate -Cert $certificatePath -FilePath $pfxFilePath -Password $pfxPassword
Export-Certificate -Cert $certificatePath -FilePath $cerFilePath
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($certificatepassword)
$unsecuredPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
$unsecuredPassword | Out-File -FilePath $cerPasswordFilePath
# import the pfx certificate
Import-PfxCertificate -FilePath $pfxFilePath Cert:\LocalMachine\My -Password $pfxPassword -Exportable
# trust the certificate by importing the pfx certificate into your trusted root
Import-Certificate -FilePath $cerFilePath -CertStoreLocation Cert:\LocalMachine\Root
# optionally delete the physical certificates (don’t delete the pfx file as you need to copy this to your app directory)
# Remove-Item $pfxFilePath
Remove-Item $cerFilePath