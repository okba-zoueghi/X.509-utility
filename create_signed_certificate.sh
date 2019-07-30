# /bin/bash

################################################################################################
## This script                                                                                ##
## generates a private key                                                                    ##
## creates a certificate request                                                              ##
## signs the certificates request with the intermediate Certificate Authority's private key   ##
## $1 is the certificate name                                                                 ##
## $2 is openssl intermediate CA configuration file                                           ##
## $3 mention certificate type : the value should be "client" or "server"                     ##
## $4 Validity of the certificate in days                                                     ##
## $5 digital signature algorithm                                                             ##
################################################################################################

#Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if [[ $# -ne 5 ]]
then
  echo -e "${RED}bad arguments${NC}"
  echo "usage: create_signed_certificate.sh <certname> <openssl intermediate CA config file> <server | client> <validity in days> <rsa|ecdsa>"
  echo " <server | client> : choose 'server' to generate a server certificate and 'client' to generate a client certficate'"
  exit 1
fi

#Generate RSA pair
if [[ "$5" == "rsa" ]]
then
  openssl genrsa -out intermediate/private/$1.key.pem 2048
  echo -e "${GREEN}##### RSA key pair generated #####${NC}"
elif [[ "$5" == "ecdsa" ]]
then
  openssl ecparam -name prime256v1 -genkey -out intermediate/private/$1.key.pem &> /dev/null
  echo -e "${GREEN}##### ECDSA key pair generated #####${NC}"
fi


#Create a certificate signing request
echo -e "${GREEN}##### Creating certificate signing request #####${NC}"
openssl req -config $2 -key intermediate/private/$1.key.pem -new -sha256 -out intermediate/csr/$1.csr.pem

#Create the signed certificate
if [ "$3" == "server" ]
then
  openssl ca -config $2 \
        -extensions server_cert -days $4 -notext -md sha256 \
        -in intermediate/csr/$1.csr.pem \
        -out intermediate/certs/$1.cert.pem
elif [ "$3" == "client" ]
then
  openssl ca -config $2 \
        -extensions usr_cert -days $4 -notext -md sha256 \
        -in intermediate/csr/$1.csr.pem \
        -out intermediate/certs/$1.cert.pem
else
  echo -e "${RED}bad arguments${NC}"
  exit 1
fi

echo -e "${GREEN}##### Signed the $3 certificate with the intermediate CA private key #####${NC}"
