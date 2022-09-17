#!/bin/bash

set -e

if [ -z "$SUBJECT" ]
then
  echo "Environment variable SUBJECT must be exported or passed to the script."
  exit 1
fi

# Create self-signed CA certificate
openssl req \
	-new -x509 -nodes -days 365 \
	-subj "/CN=ca.${SUBJECT}" \
	-newkey rsa:2048 \
	-keyout root-ca.key \
	-out root-ca.crt

# Create a private key
openssl genrsa 2048 > "${SUBJECT}".key

# Create a CSR
openssl req -new \
	-subj "/CN=${SUBJECT}" \
	-key "${SUBJECT}".key \
	-out "${SUBJECT}".csr

# Sign the CSR with the self-signed CA certificate
openssl x509 -req -days 365 \
	-in "${SUBJECT}".csr \
	-out "${SUBJECT}".crt \
	-CAcreateserial \
	-CA root-ca.crt \
	-CAkey root-ca.key

# cleanup temporary files
rm -f root-ca.*
rm -f "$SUBJECT".csr
