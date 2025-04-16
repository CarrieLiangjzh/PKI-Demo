#!/bin/bash
# Generate Intermediate CA Certificate
# Usage: ./generate_intermediate_ca.sh

# Configuration
ROOT_CA_DIR="./root_ca"
INTERMEDIATE_CA_DIR="./intermediate_ca"
OPENSSL_ROOT_CNF="./root_openssl.cnf"
OPENSSL_CONF="./intermediate_openssl.cnf"
KEY_ALGORITHM="rsa"
KEY_SIZE=2048
VALIDITY_DAYS=3650

echo "=== Generating Intermediate CA Certificate ==="
echo "Config:"
echo "- Algorithm: ${KEY_ALGORITHM} ${KEY_SIZE}"
echo "- Validity: ${VALIDITY_DAYS} days"
echo "- Config: ${OPENSSL_CONF}"

# Verify root CA exists
if [ ! -f "${ROOT_CA_DIR}/private/ca.key.pem" ]; then
    echo "Error: Root CA not found. Run generate_root_ca.sh first."
    exit 1
fi

# Initialize directory structure
mkdir -p ${INTERMEDIATE_CA_DIR}/{certs,crl,csr,newcerts,private}
chmod 700 ${INTERMEDIATE_CA_DIR}/private
touch ${INTERMEDIATE_CA_DIR}/index.txt
echo 1000 > ${INTERMEDIATE_CA_DIR}/serial
echo 1000 > ${INTERMEDIATE_CA_DIR}/crlnumber

# Generate intermediate CA private key
echo -e "\n[1/5] Generating Intermediate CA private key..."
openssl genrsa -aes256 -out ${INTERMEDIATE_CA_DIR}/private/intermediate.key.pem ${KEY_SIZE}
chmod 400 ${INTERMEDIATE_CA_DIR}/private/intermediate.key.pem

# Generate CSR
echo -e "\n[2/5] Creating Intermediate CA CSR..."
openssl req -config ${OPENSSL_CONF} -new -sha256 \
    -key ${INTERMEDIATE_CA_DIR}/private/intermediate.key.pem \
    -out ${INTERMEDIATE_CA_DIR}/csr/intermediate.csr.pem

# Sign with root CA
echo -e "\n[3/5] Signing Intermediate CSR with Root CA..."
openssl ca -config ${OPENSSL_ROOT_CNF} -extensions v3_intermediate_ca \
    -days ${VALIDITY_DAYS} -notext -md sha256 \
    -in ${INTERMEDIATE_CA_DIR}/csr/intermediate.csr.pem \
    -out ${INTERMEDIATE_CA_DIR}/certs/intermediate.cert.pem

# Verify certificate
echo -e "\n[4/5] Verifying Intermediate CA certificate..."
openssl verify -CAfile ${ROOT_CA_DIR}/certs/ca.cert.pem \
    ${INTERMEDIATE_CA_DIR}/certs/intermediate.cert.pem

# Create certificate chain
echo -e "\n[5/5] Creating certificate chain..."
cat ${INTERMEDIATE_CA_DIR}/certs/intermediate.cert.pem \
    ${ROOT_CA_DIR}/certs/ca.cert.pem > ${INTERMEDIATE_CA_DIR}/certs/ca-chain.cert.pem
chmod 444 ${INTERMEDIATE_CA_DIR}/certs/ca-chain.cert.pem

echo -e "\n=== Intermediate CA Generation Complete ==="
echo "Intermediate CA Certificate: ${INTERMEDIATE_CA_DIR}/certs/intermediate.cert.pem"
echo "Certificate Chain: ${INTERMEDIATE_CA_DIR}/certs/ca-chain.cert.pem"
