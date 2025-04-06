# Define variables
$rootCertName = "<ROOT_CERT_NAME>" # Replace with your Root CA name
$childCertName = "<CHILD_CERT_NAME>"
$certPassword = "<YOUR_PASSWORD>" # Replace with your desired password for the PFX file

# Generate Root CA Certificate
$rootCert = New-SelfSignedCertificate `
    -Type Custom `
    -KeyUsageProperty Sign `
    -KeyUsage CertSign, CRLSign `
    -Subject "CN=$rootCertName" `
    -KeyAlgorithm RSA `
    -KeyLength 4096 `
    -HashAlgorithm SHA256 `
    -CertStoreLocation "Cert:\LocalMachine\My" `
    -NotAfter (Get-Date).AddYears(10) `
    -TextExtension @("2.5.29.19={text}CA=true")

# Export Root CA Public Certificate
$rootCertPath = "C:\Certs\RootCA.cer"
Export-Certificate -Cert $rootCert -FilePath $rootCertPath
Write-Output "Root CA certificate exported to: $rootCertPath"

# Generate Child Certificate (VPN Server)
$vpnCert = New-SelfSignedCertificate `
    -Type Custom `
    -Subject "CN=$childCertName" `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -HashAlgorithm SHA256 `
    -CertStoreLocation "Cert:\LocalMachine\My" `
    -Signer $rootCert `
    -NotAfter (Get-Date).AddYears(5) `
    -TextExtension @("2.5.29.19={text}CA=false")

# Export Child Certificate (Public)
$vpnCertPath = "C:\Certs\VPNServer.cer"
Export-Certificate -Cert $vpnCert -FilePath $vpnCertPath
Write-Output "VPN Server certificate exported to: $vpnCertPath"

# Export Child Certificate with Private Key (PFX)
$vpnPfxPath = "C:\Certs\VPNServer.pfx"
$securePassword = ConvertTo-SecureString -String $certPassword -Force -AsPlainText
Export-PfxCertificate -Cert $vpnCert -FilePath $vpnPfxPath -Password $securePassword
Write-Output "VPN Server PFX exported to: $vpnPfxPath"

Write-Output "Certificates have been successfully generated!"