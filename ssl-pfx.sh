#!/bin/bash

# Check if the CA name has been provided
if [ $# -eq 0 ]; then
    echo "Please provide the name of the Certificate Authority."
    echo "Usage: $0 <CA_name>"
    exit 1
fi

CA_NAME=$1

# Check if the CA directory exists
if [ ! -d "$CA_NAME" ]; then
    echo "CA directory not found. Make sure you have first run the CA creation script."
    exit 1
fi

# Ask for the domain name
read -p "Enter the domain name for which you want to create a PFX file: " DOMAIN

# Create necessary directories
mkdir -p "${CA_NAME}/domains/${DOMAIN}"

# Generate private key for the domain
openssl genrsa -out "${CA_NAME}/domains/${DOMAIN}/${DOMAIN}.key" 2048

# Generate a Certificate Signing Request (CSR)
openssl req -new -key "${CA_NAME}/domains/${DOMAIN}/${DOMAIN}.key" -out "${CA_NAME}/domains/${DOMAIN}/${DOMAIN}.csr" -subj "/CN=${DOMAIN}"

# Sign the CSR with the CA to generate the domain certificate
openssl x509 -req -in "${CA_NAME}/domains/${DOMAIN}/${DOMAIN}.csr" \
    -CA "${CA_NAME}/${CA_NAME}_rootCA.crt" \
    -CAkey "${CA_NAME}/${CA_NAME}_rootCA.key" \
    -CAcreateserial \
    -out "${CA_NAME}/domains/${DOMAIN}/${DOMAIN}.crt" \
    -days 365 -sha256

# Ask for the PFX password
read -s -p "Enter the password for the PFX file: " PFX_PASSWORD
echo

# Create the PFX file
openssl pkcs12 -export \
    -out "${CA_NAME}/domains/${DOMAIN}/${DOMAIN}.pfx" \
    -inkey "${CA_NAME}/domains/${DOMAIN}/${DOMAIN}.key" \
    -in "${CA_NAME}/domains/${DOMAIN}/${DOMAIN}.crt" \
    -certfile "${CA_NAME}/${CA_NAME}_rootCA.crt" \
    -password pass:$PFX_PASSWORD

# Check if the PFX file was created successfully
if [ $? -eq 0 ]; then
    echo "PFX file created successfully: ${CA_NAME}/domains/${DOMAIN}/${DOMAIN}.pfx"
    echo "You can now import this PFX file into systems that require it."
    echo "Remember to keep the PFX password safe, as you'll need it when importing the certificate."
    
    echo ""
    echo "Instructions for importing the PFX file:"
    # ... (rest of the instructions remain the same)
else
    echo "Failed to create PFX file. Please check the error messages above."
fi
