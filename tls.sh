#!/bin/bash

set -e

if [ $# -gt 0 ]
then
    for i in "$@"
    do
		case $i in
			--root-cert)
				ROOT_CERT="true"
				shift
				;;
			--root-cert-path=*)
				ROOT_CERT_PATH="${i#*=}"
				shift
				;;
			--root-key-path=*)
				ROOT_KEY_PATH="${i#*=}"
				shift
				;;
			-s=*|--subject=*)
				SUBJECT="${i#*=}"
				shift
				;;
		esac
	done
fi

if [ -z "$SUBJECT" ]
then
  echo "Environment variable SUBJECT must be exported or passed as -s/--subject to the script."
  exit 1
fi

if [ "${ROOT_CERT}" == "true" ] && [[ ! -z "${ROOT_CERT_PATH}" || ! -z "${ROOT_KEY_PATH}" ]]
then
	echo "Argument --root-cert cannot be passed together with --root-cert-path or --root-key-path."
	exit 1
fi

function generateCA {
	local subject=$1
	openssl req \
		-new -x509 -nodes -days 365 \
		-subj "${subject}" \
		-newkey rsa:2048 \
		-keyout root-ca.key \
		-out root-ca.crt
}

function signCertificate {
	local rootCertPath=$1
	local rootKeyPath=$2
	# Sign the CSR with the self-signed CA certificate
	openssl x509 -req -days 365 \
		-in "${SUBJECT}".csr \
		-out "${SUBJECT}".crt \
		-CAcreateserial \
		-CA "${rootCertPath}" \
		-CAkey "${rootKeyPath}" \
		-extensions v3_req \
		-extfile cert.conf
}

function generateExtFile {
	local subject=$1
	cat > "cert.conf" <<EOF
[req]
req_extensions = v3_req
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names
[alt_names]
DNS = $subject
EOF
}

if [ "$ROOT_CERT" == "true" ]
then
	generateCA "/CN=${SUBJECT}"
else
	# Create a private key
	openssl genrsa 2048 > "${SUBJECT}".key
	# Create a CSR
	openssl req -new \
		-subj "/CN=${SUBJECT}" \
		-key "${SUBJECT}".key \
		-out "${SUBJECT}".csr

	generateExtFile $SUBJECT

	if [[ -z "$ROOT_CERT_PATH" || -z "$ROOT_KEY_PATH" ]]
	then
		generateCA "/CN=ca.${SUBJECT}"
		signCertificate root-ca.crt root-ca.key
	else
		signCertificate $ROOT_CERT_PATH $ROOT_KEY_PATH
	fi
fi

# cleanup temporary files
rm -f "$SUBJECT".csr
rm -f root-ca.srl
rm -f cert.conf
