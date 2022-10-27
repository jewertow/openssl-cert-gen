# openssl-cert-gen

`openssl-cert-gen` makes it easy to create test SSL certificates and does not require repeating verbose OpenSSL commands.

## Usage

### Simple TLS
The following command returns self-signed root certificate and a certificate signed by that root.
Argument `--subject` is used to specify subject's common name.
Common name of root certificate is prefixed with `ca.`.

```sh
curl https://raw.githubusercontent.com/jewertow/openssl-cert-gen/master/tls.sh | sh -s - --subject="app.com"
```

### Mutual TLS

First generate a root certificate to sign peer certificates.
In this context, `--subject` specifies common name of the root certificate.
```sh
curl https://raw.githubusercontent.com/jewertow/openssl-cert-gen/master/tls.sh | sh -s - --subject="cluster.local" --root-cert
```
To generate peer certificates signed by previously created root certificate, pass a path to that root and specifiy peer's subject:
```sh
curl https://raw.githubusercontent.com/jewertow/openssl-cert-gen/master/tls.sh | sh -s - --subject="external-app.external.svc.cluster.local" --root-cert-path=root-ca.crt --root-key-path=root-ca.key

curl https://raw.githubusercontent.com/jewertow/openssl-cert-gen/master/tls.sh | sh -s - --subject="egress-gateway.istio-system.svc.cluster.local" --root-cert-path=root-ca.crt --root-key-path=root-ca.key
```

## TODO
- use conf file to specify extensions, like CA:false, etc.
- add support for settings SAN in certificates
