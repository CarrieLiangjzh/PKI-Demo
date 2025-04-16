#!/bin/bash
# Sign Device CSR with Intermediate CA
# Usage: ./sign_device_cert.sh <csr_file> [output_cert_file]

# Configuration
INTERMEDIATE_CA_DIR="./intermediate_ca"
OPENSSL_CONF="./intermediate_openssl.cnf"
#DEFAULT_VALIDITY_DAYS=1 # 2 years

# Check arguments
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <csr_file> [output_cert_file]"
    echo "Example: $0 device.csr"
    echo "Example: $0 device.csr device.crt"
    exit 1
fi

CSR_FILE=$1
DEFAULT_VALIDITY_DAYS=$2
OUTPUT_CERT=${CSR_FILE%.*}.crt}

echo "=== Signing Device Certificate ==="
echo "CSR File: ${CSR_FILE}"
echo "Output Certificate: ${OUTPUT_CERT}"
echo "The validity days:${DEFAULT_VALIDITY_DAYS}"

# Verify intermediate CA exists
if [ ! -f "${INTERMEDIATE_CA_DIR}/private/intermediate.key.pem" ]; then
    echo "Error: Intermediate CA not found. Run generate_intermediate_ca.sh first."
    exit 1
fi

# Determine certificate type
COMMON_NAME=$(openssl req -noout -subject -in $CSR_FILE | sed -n '/^subject/s/^.*CN=//p')
if [[ $COMMON_NAME == *"server"* ]]; then
    CERT_TYPE="server_cert"
    echo "Certificate Type: Server (CN: ${COMMON_NAME})"
elif [[ $COMMON_NAME == *"client"* ]]; then
    CERT_TYPE="client_cert" 
    echo "Certificate Type: Client (CN: ${COMMON_NAME})"
else
    CERT_TYPE="usr_cert"
    echo "Certificate Type: Generic (CN: ${COMMON_NAME})"
fi

# Sign the CSR
echo -e "\n[1/2] Signing CSR..."
openssl ca -config ${OPENSSL_CONF} -extensions ${CERT_TYPE} \
    -days ${DEFAULT_VALIDITY_DAYS} -notext -md sha256 \
    -in ${CSR_FILE} -out ${OUTPUT_CERT}

# Verify certificate
echo -e "\n[2/2] Verifying signed certificate..."
openssl verify -CAfile ${INTERMEDIATE_CA_DIR}/certs/ca-chain.cert.pem ${OUTPUT_CERT}

echo -e "\n=== Device Certificate Signed ==="
echo "Output Certificate: ${OUTPUT_CERT}"
echo "Certificate Chain: ${INTERMEDIATE_CA_DIR}/certs/ca-chain.cert.pem"
