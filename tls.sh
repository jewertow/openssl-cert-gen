#!/bin/sh

if [ -z "$SUBJECT" ]
then
  echo "Environment variable SUBJECT must be exported or passed to the script."
  exit 1
fi

openssl req \
	-x509 -sha256 -nodes \
	-days 3650 \
	-newkey rsa:2048 \
	-subj "/CN=${SUBJECT}" \
	-keyout "${SUBJECT}".key \
	-out "${SUBJECT}".crt

