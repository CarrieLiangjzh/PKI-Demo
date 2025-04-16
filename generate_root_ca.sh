#!/bin/bash
# Generate Self-Signed Root CA Certificate
# Usage: ./generate_root_ca.sh

# Configuration
ROOT_CA_DIR="./root_ca"
OPENSSL_CONF="./root_openssl.cnf"
KEY_ALGORITHM="rsa"
KEY_SIZE=2048
VALIDITY_DAYS=7300 # 20 years

echo "=== Generating Root CA Certificate ==="
echo "Config:"
echo "- Algorithm: ${KEY_ALGORITHM} ${KEY_SIZE}"
echo "- Validity: ${VALIDITY_DAYS} days"
echo "- Config: ${OPENSSL_CONF}"

# Initialize directory structure
mkdir -p ${ROOT_CA_DIR}/{certs,crl,newcerts,private,csr}
chmod 700 ${ROOT_CA_DIR}/private
touch ${ROOT_CA_DIR}/index.txt
echo 1000 > ${ROOT_CA_DIR}/serial
echo 1000 > ${ROOT_CA_DIR}/crlnumber

# Generate root CA private key
echo -e "\n[1/3] Generating Root CA private key..."
openssl genrsa -aes256 -out ${ROOT_CA_DIR}/private/ca.key.pem ${KEY_SIZE}
chmod 400 ${ROOT_CA_DIR}/private/ca.key.pem

# Generate self-signed root certificate
echo -e "\n[2/3] Creating self-signed Root CA certificate..."
openssl req -config ${OPENSSL_CONF} -x509 -new -sha256 \
    -key ${ROOT_CA_DIR}/private/ca.key.pem \
    -days ${VALIDITY_DAYS} -out ${ROOT_CA_DIR}/certs/ca.cert.pem

# Verify certificate
echo -e "\n[3/3] Verifying Root CA certificate..."
openssl x509 -noout -text -in ${ROOT_CA_DIR}/certs/ca.cert.pem

echo -e "\n=== Root CA Generation Complete ==="
echo "Root CA Certificate: ${ROOT_CA_DIR}/certs/ca.cert.pem"
echo "Private Key: ${ROOT_CA_DIR}/private/ca.key.pem (SECURE THIS FILE)"
