#!/bin/bash

if [ -z "$SUBJECT" ]
then
  echo "Environment variable SUBJECT must be exported or passed to the script."
  exit 1
fi

SUBJECT_ALT_NAME=""

if [ -z "$SANS" ]
then
	openssl req \
		-x509 -sha256 -nodes -days 3650 \
		-newkey rsa:2048 \
		-subj "/CN=${SUBJECT}" \
		-keyout "${SUBJECT}".key \
		-out "${SUBJECT}".crt
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
