#!/bin/bash

set -e

if [ -z "$SUBJECT" ]
then
  echo "Environment variable SUBJECT must be exported or passed to the script."
  exit 1
fi

SUBJECT_ALT_NAME=""

# Create self-signed CA certificate
openssl req \
	-new -x509 -nodes -days 365 \
	-subj "/CN=ca.${SUBJECT}" \
	-newkey rsa:2048 \
	-keyout root-ca.key \
	-out root-ca.crt

if [ -z "$SANS" ]
then
	# TODO: extract the commands below to a function and reuse it in the "else" block
	# Create a private key
	openssl genrsa 2048 > "${SUBJECT}".key
	echo "done"
	# Create a CSR
	openssl req -new \
		-subj "/CN=${SUBJECT}" \
		-key "${SUBJECT}".key \
		-out "${SUBJECT}".csr
	echo "done"
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
else
	IFS=',' read -ra SANS_ARR <<< "$SANS"

	SANS_ARR_DNS=()
	for SAN in "${SANS_ARR[@]}"
	do
		SANS_ARR_DNS+=("DNS:${SAN}")
	done
	SUBJECT_ALT_NAME=$(IFS=,;printf "%s" "${SANS_ARR_DNS[*]}")

	openssl req \
		-x509 -sha256 -nodes -days 3650 \
		-newkey rsa:2048 \
		-subj "/CN=${SUBJECT}" \
		-addext "subjectAltName = $SUBJECT_ALT_NAME" \
		-keyout "${SUBJECT}".key \
		-out "${SUBJECT}".crt
fi
