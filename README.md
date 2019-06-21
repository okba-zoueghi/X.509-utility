# X.509-utility

The utility uses openssl command line and allows to create client or server certificate.

## Description

The utility consists of two bash scripts and two configuration files:

**openssl.root.cnf** : 

Root CA openssl configuration file

**openssl.intermediate.cnf** : 

Intermediate CA openssl configuration file

**create_CAs.sh** : 

1- Generates root CA key pair     

2- Creates self signed root certificate

3- Generate intermediate CA key pair  

4- Creates intermediate CA certificate request

5- Creates intermediate CA certificate (signed by the root CA's private key)

6- Creates chain of trust certificate (concatinate intermediate cert | root cert)              

**create_signed_certificate.sh** :

1- Generates a key pair

2- Creates a certificate signing request

3- Signs the certificates request with the intermediate Certificate Authority's private key

## Usage: 

```shell
create_CAs.sh <openssl root CA config file> <openssl intermediate CA config file>
create_signed_certificate.sh <certname> <openssl intermediate CA config file> <server | client> <validity in days>
```

## Example

```shell
create_CAs.sh openssl.root.cnf openssl.intermediate.cnf 
create_signed_certificate.sh server openssl.intermediate.cnf server 500
```

After running **create_CAs.sh**, the following files will be created:

**private/ca.key.pem** : root CA RSA key pair

**intermediate/private/intermediate.key.pem** : intermediate CA RSA key pair

**certs/ca.cert.pem** : self signed root CA certificate

**intermediate/certs/intermediate.cert.pem** : intermediate CA certificate (signed by the root CA)

**intermediate/certs/ca-chain.cert.pem** : Chain certificate (intermediate cert | root cert)

After running **create_signed_certificate.sh**, the following files will be created:

**intermediate/private/server.key.pem** : server RSA key pair

**intermediate/certs/server.cet.pem** : server certificate (signed by the intermediate CA)
