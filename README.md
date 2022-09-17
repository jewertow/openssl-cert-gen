# openssl-cert-gen

`openssl-cert-gen` makes it easy to create test SSL certificates and does not require repeating the extensive OpenSSL commands.

## Usage

### Simple TLS
The following command returns a self-signed key and certificate for a server:
```sh
curl https://raw.githubusercontent.com/jewertow/openssl-cert-gen/master/tls.sh | SUBJECT="app.com" sh
```
