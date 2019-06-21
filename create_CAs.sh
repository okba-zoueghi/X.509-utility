#! /bin/bash


################################################################################################
## This script                                                                                ##
## generates root CA key pair                                                                 ##
## creates self signed root certificate                                                       ##
## generate intermediate CA key pair                                                          ##
## create intermediate CA certificate request                                                 ##
## create intermediate CA certificate (signed by the root CA's private key)                   ##
## create chain of trust certificate (concatinate intermediate cert | root cert)              ##
## $1 root CA openssl configuration file                                                      ##
## $2 intermediate CA openssl configuration file                                              ##
################################################################################################

#Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if [[ $# -ne 2 ]]
then
  echo -e "${RED}bad arguments${NC}"
  echo "usage: create_CAs.sh <openssl root CA config file> <openssl intermediate CA config file>"
  exit 1
fi

############################# Root Certificate Authority ######################
#prepare directories
mkdir certs crl newcerts private

#set permissions for the folder which will contain the keys
chmod 700 private

#these files will keep track of the created certificates
touch index.txt
echo 1000 > serial

#generate root key
openssl genrsa -out private/ca.key.pem 4096 &> /dev/null
echo -e "${GREEN}##### Root certificate authority RSA key pair generated #####${NC}"


#set permissions for the root key
chmod 400 private/ca.key.pem


#create the self signed root certificate
echo -e "${GREEN}##### Creating self signed Root certificate #####${NC}"
openssl req -config $1 \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
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
openssl genrsa -out private/intermediate.key.pem 4096 &> /dev/null
echo -e "${GREEN}##### Intermediate certificate authority RSA key pair generated #####${NC}"

#set permissions
chmod 400 private/intermediate.key.pem
ls
#create certificate signing request
echo -e "${GREEN}##### Creating certificate signing request #####${NC}"
openssl req -config ../$2 -new -sha256 \
      -key private/intermediate.key.pem \
      -out csr/intermediate.csr.pem

#sign the intermediate certificate with the root private key
cd ..
ls
echo -e "${GREEN}##### Signing the intermediate CA's certificate with the root private key #####${NC}"
openssl ca -config $1 -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in intermediate/csr/intermediate.csr.pem \
      -out intermediate/certs/intermediate.cert.pem

#set permissions
chmod 444 intermediate/certs/intermediate.cert.pem

#create the certificate chain file (chain.cert => intermediate.cert | root.cert)
cat intermediate/certs/intermediate.cert.pem \
      certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
echo -e "${GREEN}##### Created the certificate chain file #####${NC}"

#set permissions
chmod 444 intermediate/certs/ca-chain.cert.pem
#############################  Intermediate Certificate Authority ######################
