# X.509-utility

The utility uses openssl command line and allows to create client or server certificate.
The utility supports RSA, ECDSA, and ED25519.

## Description

The utility consists of two bash scripts and two configuration files:

**openssl.root.cnf** :

Root CA openssl configuration file

**openssl.intermediate.cnf** :

Intermediate CA openssl configuration file

**create_certificate_authorities.sh** :

1- Generates root CA key pair     

2- Creates self signed root certificate

3- Generates intermediate CA key pair  

4- Creates intermediate CA certificate request

5- Creates intermediate CA certificate (signed by the root CA's private key)

**create_signed_certificate.sh** :

1- Generates a key pair

2- Creates a certificate signing request

3- Signs the certificates request with the intermediate Certificate Authority's private key

4- Creates chain of trust certificate (concatenate endPoint cert | root cert) 

## Example using RSA

```shell
create_certificate_authorities.sh --root-cnf-file openssl.root.cnf --int-cnf-file openssl.intermediate.cnf --sig-alg rsa --validity 3700
create_signed_certificate.sh --cert-name server --int-cnf-file openssl.intermediate.cnf --role server --sig-alg rsa --validity 360
```

## Example using ECDSA

```shell
create_certificate_authorities.sh --root-cnf-file openssl.root.cnf --int-cnf-file openssl.intermediate.cnf --sig-alg ecdsa --curve prime256v1 --validity 3700
create_signed_certificate.sh --cert-name server --int-cnf-file openssl.intermediate.cnf --role server --sig-alg ecdsa --curve prime256v1 --validity 360
```

If the curve is not specified then the default one is used.
The default curve is **prime256v1**.

To see of the list of supported curves, the following openssl command could be used:

```shell
openssl ecparam -list_curves
```
## Example using ED25519

```shell
create_certificate_authorities.sh --root-cnf-file openssl.root.cnf --int-cnf-file openssl.intermediate.cnf --sig-alg ed25519 --validity 3700
create_signed_certificate.sh --cert-name server --int-cnf-file openssl.intermediate.cnf --role server --sig-alg ed25519 --validity 360
```

## Output

After running **create_certificate_authorities.sh**, the following files will be created:

**private/ca.key.pem** : root CA key pair

**intermediate/private/intermediate.key.pem** : intermediate CA key pair

**certs/ca.cert.pem** : self signed root CA certificate

**intermediate/certs/intermediate.cert.pem** : intermediate CA certificate (signed by the root CA)

**intermediate/certs/ca-chain.cert.pem** : Chain certificate (intermediate cert | root cert)

After running **create_signed_certificate.sh**, the following files will be created:

**intermediate/private/server.key.pem** : server key pair

**intermediate/certs/server.cet.pem** : server certificate (signed by the intermediate CA)
