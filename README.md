# openssl-cert-gen

`openssl-cert-gen` makes it easy to create test SSL certificates and does not require repeating the extensive OpenSSL commands.

## Usage

### Simple TLS
The following command returns a self-signed key and certificate for a server:
```sh
wget https://raw.githubusercontent.com/jewertow/openssl-cert-gen/tls.sh | SUBJECT="app.testdomain" sh
```

### mTLS
The following command returns CA, client and server keys and certificates signed by a self-signed root certificate:
```sh
wget https://raw.githubusercontent.com/jewertow/openssl-cert-gen/mtls.sh | CLIENT="client-app" SERVER="server-app" DOMAIN="testdomain" sh
```

