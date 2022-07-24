#!/bin/sh

if [ -z "$CLIENT" ]
then
  echo "Environment variable CLIENT must be exported or passed to the script."
  exit 1
fi

if [ -z "$SERVER" ]
then
  echo "Environment variable SERVER must be exported or passed to the script."
  exit 1
fi

if [ -z "$DOMAIN" ]
then
  echo "Environment variable DOMAIN must be exported or passed to the script."
  exit 1
fi

# create a root certificate and private key to sign certificates
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 \
	-subj "/CN=ca.${DOMAIN}" \
	-keyout "ca.${DOMAIN}".key \
	-out "ca.${DOMAIN}".crt

# create certificate and private key for server
openssl req -newkey rsa:2048 -nodes \
	-subj "/CN=${SERVER}.${DOMAIN}" \
	-keyout "${SERVER}.${DOMAIN}".key \
	-out "${SERVER}.${DOMAIN}".csr

openssl x509 -req -days 365 \
	-CA "ca.${DOMAIN}".crt \
	-CAkey "ca.${DOMAIN}".key \
	-CAcreateserial \
	-in "${SERVER}.${DOMAIN}".csr \
	-out "${SERVER}.${DOMAIN}".crt

# create certificate and private key for client
openssl req -newkey rsa:2048 -nodes \
	-out "${CLIENT}.${DOMAIN}".csr \
	-keyout "${CLIENT}.${DOMAIN}".key \
	-subj "/CN=${CLIENT}.${DOMAIN}"

openssl x509 -req -days 365 \
	-CA "ca.${DOMAIN}".crt \
	-CAkey "ca.${DOMAIN}".key \
	-CAcreateserial \
	-in "${CLIENT}.${DOMAIN}".csr \
	-out "${CLIENT}.${DOMAIN}".crt

