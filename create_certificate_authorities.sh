#! /bin/bash

################################################################################################
## This script                                                                                ##
## generates root CA key pair                                                                 ##
## creates self signed root certificate                                                       ##
## generate intermediate CA key pair                                                          ##
## create intermediate CA certificate request                                                 ##
## create intermediate CA certificate (signed by the root CA's private key)                   ##
## create chain of trust certificate (concatinate intermediate cert | root cert)              ##
################################################################################################

if [[ ($# -lt 8) || ($# -gt 10) ]]
then
  echo "usage: create_CAs.sh --root-cnf-file <openssl root CA config file> \
  --int-cnf-file <openssl intermediate CA config file> \
  --sig-alg <rsa|ecdsa|ed25519>\
  --validity <validity in days>\
  "

  echo "if ecdsa is used, specify the curve with the option --curve <openssl curve name>"
  exit 1
fi

#Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

#Default ECDSA curve
ECDSA_CURVE=prime256v1

TEMP=$(getopt -o r:i:s:c:v: --long root-cnf-file:,int-cnf-file:,sig-alg:,curve:,validity: -- "$@")
eval set -- "$TEMP"

while true; do
  case "$1" in
    -r|--root-cnf-file)
      ROOT_CA_CNF_FILE=$2 ; shift 2
    ;;
    -i|--int-cnf-file)
      INTERMEDIATE_CA_CNF_FILE=$2 ; shift 2
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

############################# Root Certificate Authority ######################
#prepare directories
mkdir certs crl newcerts private

#set permissions for the folder which will contain the keys
chmod 700 private

#these files will keep track of the created certificates
touch index.txt
echo 1000 > serial

#generate root key
if [[ "$SIGNATURE_ALGORITHM" == "rsa" ]]
then
  openssl genrsa -out private/ca.key.pem 4096 &> /dev/null
  echo -e "${GREEN}##### Root certificate authority RSA key pair generated #####${NC}"
elif [[ "$SIGNATURE_ALGORITHM" == "ecdsa" ]]
then
  openssl ecparam -name $ECDSA_CURVE -genkey -out private/ca.key.pem &> /dev/null
  echo -e "${GREEN}##### Root certificate authority ECDSA key pair generated #####${NC}"
elif [[ "$SIGNATURE_ALGORITHM" == "ed25519" ]]
then
  openssl genpkey -algorithm ED25519 -out private/ca.key.pem &> /dev/null
  echo -e "${GREEN}##### Root certificate authority ED25519 key pair generated #####${NC}"
fi

#set permissions for the root key
chmod 400 private/ca.key.pem


#create the self signed root certificate
echo -e "${GREEN}##### Creating self signed Root certificate #####${NC}"
openssl req -config $ROOT_CA_CNF_FILE \
      -key private/ca.key.pem \
      -new -x509 -days $VALIDITY_IN_DAYS -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem

#set permissions for the root certificates
chmod 444 certs/ca.cert.pem
############################# Root Certificate Authority ######################

#############################  Intermediate Certificate Authority ######################
#prepare the directory
mkdir intermediate
cd intermediate

#prepare directories
mkdir certs crl newcerts private csr

#set permissions for the folder which will contain the keys
chmod 700 private

#these files will keep track of the created certificates
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

#generate private key
if [[ "$SIGNATURE_ALGORITHM" == "rsa" ]]
then
  openssl genrsa -out private/intermediate.key.pem 4096 &> /dev/null
  echo -e "${GREEN}##### Intermediate certificate authority RSA key pair generated #####${NC}"
elif [[ "$SIGNATURE_ALGORITHM" == "ecdsa" ]]
then
  openssl ecparam -name $ECDSA_CURVE -genkey -out private/intermediate.key.pem &> /dev/null
  echo -e "${GREEN}##### Intermediate certificate authority ECDSA key pair generated #####${NC}"
elif [[ "$SIGNATURE_ALGORITHM" == "ed25519" ]]
then
  openssl genpkey -algorithm ED25519 -out private/intermediate.key.pem &> /dev/null
  echo -e "${GREEN}##### Intermediate certificate authority ed25519 key pair generated #####${NC}"
fi

#set permissions
chmod 400 private/intermediate.key.pem
ls
#create certificate signing request
echo -e "${GREEN}##### Creating certificate signing request #####${NC}"
openssl req -config ../$INTERMEDIATE_CA_CNF_FILE -new -sha256 \
      -key private/intermediate.key.pem \
      -out csr/intermediate.csr.pem

#sign the intermediate certificate with the root private key
cd ..
ls
echo -e "${GREEN}##### Signing the intermediate CA's certificate with the root private key #####${NC}"
openssl ca -config $ROOT_CA_CNF_FILE -extensions v3_intermediate_ca \
      -days $VALIDITY_IN_DAYS -notext -md sha256 \
      -in intermediate/csr/intermediate.csr.pem \
      -out intermediate/certs/intermediate.cert.pem

#set permissions
chmod 444 intermediate/certs/intermediate.cert.pem
#############################  Intermediate Certificate Authority ######################
