#!/bin/bash
set -e

rm -rf .gentmp
mkdir -p .gentmp
pushd .gentmp >/dev/null

# Note: We use a fixed pass phrase ("NmNTNA9idsq4iuzH") for this example. If
# this was an actually running server we would have kept that pass phrase
# very secret.

openssl genrsa -out ca.pem 4096

echo NmNTNA9idsq4iuzH | \
  openssl req -new -x509 -days 365 -key ca.pem -out ca.crt \
  -subj "/O=Rippling Inc/OU=Administration/CN=Rippling X509 CA" \
  -passin pass:stdin > /dev/null

openssl pkcs12 -export -clcerts -inkey ca.pem -in ca.crt -out ca.p12 \
  -name "Rippling X509 CA" -passout pass:hello > /dev/null

# Create the Server Key, CSR, and Certificate
openssl genrsa -out server.pem 1024 > /dev/null

openssl req -new -key server.pem -out server.csr \
  -subj "/O=Rippling Inc/OU=Administration/CN=test.rippling.com/subjectAltName=DNS.1=test.rippling.com" >/dev/null

# We're self signing our own server cert here.
# Hey, this is a no-no outside of experiments.

openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.pem \
  -set_serial 01 -out server.crt > /dev/null

openssl pkcs12 -export -clcerts -inkey server.pem -in server.crt \
  -out server.p12 -name "Rippling Inc" -passout pass: > /dev/null

popd >/dev/null
mv -f .gentmp/*.pem .gentmp/*.crt .gentmp/*.p12 .

echo "Success! Generated ca.{crt,p12,pem} and server.{crt,p12,pem}"
echo "The password for server.p12 is 'hello'."
