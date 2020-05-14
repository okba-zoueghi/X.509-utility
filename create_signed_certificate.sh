# /bin/bash

################################################################################################
## This script                                                                                ##
## generates a private key                                                                    ##
## creates a certificate request                                                              ##
## signs the certificates request with the intermediate Certificate Authority's private key   ##
################################################################################################

if [[ ($# -lt 10) || ($# -gt 12) ]]
then
  echo "usage: create_signed_certificate.sh --cert-name <certname> \
  --int-cnf-file <openssl intermediate CA config file> \
  --role <server | client> \
  --validity <validity in days>
  --sig-alg <rsa|ecdsa|ed25519>"

  echo "if ecdsa is used, specify the curve with the option --curve <openssl curve name>"
  exit 1
fi

#Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

#Default ECDSA curve
ECDSA_CURVE=prime256v1

TEMP=$(getopt -o n:i:r:s:c:v: --long cert-name:,int-cnf-file:,role:,sig-alg:,curve:,validity: -- "$@")
eval set -- "$TEMP"

while true; do
  case "$1" in
    -n|--cert-name)
      CERT_NAME=$2 ; shift 2
    ;;
    -i|--int-cnf-file)
      INTERMEDIATE_CA_CNF_FILE=$2 ; shift 2
    ;;
    -r|--role)
      case "$2" in
        server|client) ROLE=$2 ; shift 2;;
        *) echo "Role $2 unrecognized"; exit 1;;
      esac
    ;;
    -s|--sig-alg)
      case "$2" in
        rsa) SIGNATURE_ALGORITHM="rsa"; shift 2 ;;
        ecdsa) SIGNATURE_ALGORITHM="ecdsa"; shift 2 ;;
        ed25519) SIGNATURE_ALGORITHM="ed25519"; shift 2;;
        *) echo "Signature algorithm $2 unrecognized"; exit 1;;
      esac
    ;;
    -c|--curve)
      ECDSA_CURVE=$2 ; shift 2
    ;;
    -v|--validity)
      VALIDITY_IN_DAYS=$2 ; shift 2
    ;;
    --) shift; break
    ;;
    *) echo "Invalid option $1" >&2; exit 1
    ;;
  esac
done

#Generate RSA pair
if [[ "$SIGNATURE_ALGORITHM" == "rsa" ]]
then
  openssl genrsa -out intermediate/private/$CERT_NAME.key.pem 2048
  echo -e "${GREEN}##### RSA key pair generated #####${NC}"
elif [[ "$SIGNATURE_ALGORITHM" == "ecdsa" ]]
then
  openssl ecparam -name $ECDSA_CURVE -genkey -out intermediate/private/$CERT_NAME.key.pem &> /dev/null
  echo -e "${GREEN}##### ECDSA key pair generated #####${NC}"
elif [[ "$SIGNATURE_ALGORITHM" == "ed25519" ]]
then
  openssl genpkey -algorithm ED25519 -out intermediate/private/$CERT_NAME.key.pem &> /dev/null
  echo -e "${GREEN}##### ED25519 key pair generated #####${NC}"
fi

#Create a certificate signing request
echo -e "${GREEN}##### Creating certificate signing request #####${NC}"
openssl req -config $INTERMEDIATE_CA_CNF_FILE -key intermediate/private/$CERT_NAME.key.pem -new -sha256 -out intermediate/csr/$CERT_NAME.csr.pem

#Create the signed certificate
if [ "$ROLE" == "server" ]
then
  openssl ca -config $INTERMEDIATE_CA_CNF_FILE \
        -extensions server_cert -days $VALIDITY_IN_DAYS -notext -md sha256 \
        -in intermediate/csr/$CERT_NAME.csr.pem \
        -out intermediate/certs/$CERT_NAME.cert.pem
elif [ "$ROLE" == "client" ]
then
  openssl ca -config $INTERMEDIATE_CA_CNF_FILE \
        -extensions usr_cert -days $VALIDITY_IN_DAYS -notext -md sha256 \
        -in intermediate/csr/$CERT_NAME.csr.pem \
        -out intermediate/certs/$CERT_NAME.cert.pem
fi

echo -e "${GREEN}##### Signed the $ROLE certificate with the intermediate CA private key #####${NC}"


#Create certificate chain (chain.cert => endPoint.cert || intermediate.cert)
cat intermediate/certs/$CERT_NAME.cert.pem \
intermediate/certs/intermediate.cert.pem > intermediate/certs/$CERT_NAME.chain.cert.pem
echo -e "${GREEN}##### Created the certificate chain file #####${NC}"
