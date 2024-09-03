# Script to create a new Certificate Authority (CA)

# Ask for the CA name
$CA_NAME = Read-Host "Enter the name of your Certificate Authority (e.g., MyIntranetCA)"

# Ask for country, state, and city
$COUNTRY = Read-Host "Enter the country code (e.g., FR)"
$STATE = Read-Host "Enter the state or province"
$CITY = Read-Host "Enter the city"

# Ask if the user wants to protect the private key with a password
$PROTECT_KEY = Read-Host "Do you want to protect the private key with a password? (y/n)"

# Create a directory for the CA
New-Item -ItemType Directory -Force -Path $CA_NAME | Out-Null
Set-Location $CA_NAME

# Generate the CA private key and certificate
$cert = New-SelfSignedCertificate -DnsName "$CA_NAME Root CA" -KeyUsage CertSign,CRLSign -KeyExportPolicy Exportable -CertStoreLocation "Cert:\LocalMachine\My" -KeyLength 4096 -KeyAlgorithm RSA -HashAlgorithm SHA256 -NotAfter (Get-Date).AddYears(10) -Subject "CN=$CA_NAME Root CA,OU=IT,O=$CA_NAME,L=$CITY,S=$STATE,C=$COUNTRY"

# Export the certificate
Export-Certificate -Cert $cert -FilePath "${CA_NAME}_rootCA.cer" -Type CERT
Export-Certificate -Cert $cert -FilePath "${CA_NAME}_rootCA.crt" -Type CERT

# Export the private key
if ($PROTECT_KEY -eq 'y') {
    $password = Read-Host "Enter a password for the private key" -AsSecureString
    Export-PfxCertificate -Cert $cert -FilePath "${CA_NAME}_rootCA.pfx" -Password $password
} else {
    $password = ConvertTo-SecureString -String "temp" -Force -AsPlainText
    Export-PfxCertificate -Cert $cert -FilePath "${CA_NAME}_rootCA.pfx" -Password $password
}

Write-Host "CA Certificate created successfully."
Write-Host "Generated files:"
Write-Host "- CA Certificate (CER): ${CA_NAME}_rootCA.cer"
Write-Host "- CA Certificate (CRT): ${CA_NAME}_rootCA.crt"
Write-Host "- CA Private Key (PFX): ${CA_NAME}_rootCA.pfx"

Write-Host "`nImport instructions:"
Write-Host "Double-click on ${CA_NAME}_rootCA.cer and install it in 'Trusted Root Certification Authorities'"
