<h1 align="center">
  <br>
  <a href="https://github.com/okba-zoueghi/X.509-utility"><img src="https://raw.githubusercontent.com/okba-zoueghi/X.509-utility/master/x509-utility-logo.png" alt="Markdownify" width="200"></a>
  <br>
  X.509-utility
  <br>
</h1>


<h4 align="center">The utility uses openssl command line and allows to create client or server certificate.
The utility supports RSA, ECDSA, and ED25519.</h4>



## Description  :bookmark_tabs:

The utility consists of two bash scripts and two configuration files:

**openssl.root.cnf** :

Root CA openssl configuration file

**openssl.intermediate.cnf** :

Intermediate CA openssl configuration file

**create_certificate_authorities.sh** : :key:

```bash

1- Generates root CA key pair     

2- Creates self signed root certificate

3- Generates intermediate CA key pair  

4- Creates intermediate CA certificate request

5- Creates intermediate CA certificate (signed by the root CA's private key)

6- Creates chain of trust certificate (concatinate intermediate cert | root cert)   
```           

**create_signed_certificate.sh** : :key:

```bash

1- Generates a key pair

2- Creates a certificate signing request

3- Signs the certificates request with the intermediate Certificate Authority's private key

```  
## Example using RSA :mag:

```shell
create_certificate_authorities.sh --root-cnf-file openssl.root.cnf --int-cnf-file openssl.intermediate.cnf --sig-alg rsa --validity 3700
create_signed_certificate.sh --cert-name server --int-cnf-file openssl.intermediate.cnf --role server --sig-alg rsa --validity 360
```

## Example using ECDSA :mag:

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
## Example using ED25519 :mag:

```shell
create_certificate_authorities.sh --root-cnf-file openssl.root.cnf --int-cnf-file openssl.intermediate.cnf --sig-alg ed25519 --validity 3700
create_signed_certificate.sh --cert-name server --int-cnf-file openssl.intermediate.cnf --role server --sig-alg ed25519 --validity 360
```




## Output :boom:

### After running **create_certificate_authorities.sh**, the following files will be created:

**private/ca.key.pem** : root CA key pair

**intermediate/private/intermediate.key.pem** : intermediate CA key pair

**certs/ca.cert.pem** : self signed root CA certificate

**intermediate/certs/intermediate.cert.pem** : intermediate CA certificate (signed by the root CA)

**intermediate/certs/ca-chain.cert.pem** : Chain certificate (intermediate cert | root cert)

After running **create_signed_certificate.sh**, the following files will be created:

**intermediate/private/server.key.pem** : server key pair

**intermediate/certs/server.cet.pem** : server certificate (signed by the intermediate CA)


## Support :clap: :clap: :clap:

<a href="https://www.buymeacoffee.com/5Zn8Xh3l9" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>


## License

MIT

---

