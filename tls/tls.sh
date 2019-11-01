#!/bin/sh
# Generates a self-signed certificate.
# $1 Domain or Server ip address
GENSIZE=2048
EXPDATE=3650
OPENSSL=/usr/bin/openssl
ISPATH=$(pwd)
MKDIR=$(which mkdir)
RM=$(which rm)
ISIP=$1
DIR=$ISPATH/$ISIP
KEYFILE=sc.key
CERTFILE=sc.crt
SIGNREQ=sc.csr
DHPARAM=sc.pem
INFOR="/C=JP/ST=Japan/L=Saitama/O=SmasrtCRM Global Security/OU=IT Operational department/CN=$ISIP"

if [ -z "$ISIP" ]; then
  echo "Please input value Domain or Server ip address [./stls.sh smartcrm.co.jp] !!!"
  exit 1
fi

if [ -d "/$DIR" ]; then
  echo "Installing config files in ${DIR}..."
else
  ###  Create Dir if $DIR does NOT exists ###
  echo "Create: ${DIR} and continue..."
  $MKDIR $DIR
fi

if [ -d "/$DIR" ]; then
  echo "Remove all files in ${DIR}..."
  $RM -f /$DIR/*.*
else
  echo "Error: ${DIR} not found. Can not continue."
  exit 1
fi
 
echo
echo "Generating key file, $DIR/$KEYFILE"
$OPENSSL genrsa $GENSIZE > $DIR/$KEYFILE || exit 2
chmod 0600 $DIR/$KEYFILE
echo "Generating sign request file, $DIR/$SIGNREQ"
#$OPENSSL req -new -key $DIR/$KEYFILE > $DIR/$SIGNREQ || exit2
$OPENSSL req -new -key $DIR/$KEYFILE -out $DIR/$SIGNREQ -subj "$INFOR" || exit2
echo "Generating cert file, $DIR/$CERTFILE"
$OPENSSL x509 -days $EXPDATE -req -signkey $DIR/$KEYFILE < $DIR/$SIGNREQ > $DIR/$CERTFILE || exit2
echo "Generating DH key, $DIR/$DHPARAM"
$OPENSSL dhparam -out $DIR/$DHPARAM $GENSIZE
echo "Now you have $CERTFILE, $KEYFILE and $DHPARAM"