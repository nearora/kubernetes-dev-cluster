#!/bin/bash

num_workers=1

if [ $# -gt 1 ]; then
    echo "$0 <num_instances>"
    echo "\t\tA minimum of 1 instance enforced"
    exit
fi

if [ $# -eq 1 ]; then
    if [ $1 -ge 1 ]; then
        num_workers=$1
    fi
fi

mkdir -p ssl-certs

openssl genrsa -out "ssl-certs/ca-key.pem" 2048
openssl req -x509 -new -nodes -key "ssl-certs/ca-key.pem" \
    -days 10000 -out "ssl-certs/ca.pem" -subj "/CN=kube-ca"

openssl genrsa -out "ssl-certs/apiserver-key.pem" 2048
openssl req -new -key "ssl-certs/apiserver-key.pem" \
    -out "ssl-certs/apiserver.csr" -subj "/CN=kube-apiserver" \
    -config openssl.cnf
openssl x509 -req -in "ssl-certs/apiserver.csr" \
    -CA "ssl-certs/ca.pem" -CAkey "ssl-certs/ca-key.pem" \
    -CAcreateserial -out "ssl-certs/apiserver.pem" \
    -days 365 -extensions v3_req -extfile openssl.cnf

for ((i=1; i<=$num_workers; i++)); do
    worker_fqdn=core-$(printf "%02d" ${i})
    worker_ip=192.168.211.$((i+100))
    openssl genrsa -out "ssl-certs/${worker_fqdn}-key.pem" 2048
    WORKER_IP=${worker_ip} openssl req -new -key "ssl-certs/${worker_fqdn}-key.pem" \
        -out "ssl-certs/${worker_fqdn}.csr" -subj "/CN=${worker_fqdn}" \
        -config worker-openssl.cnf
    WORKER_IP=${worker_ip} openssl x509 -req -in "ssl-certs/${worker_fqdn}.csr" \
        -CA "ssl-certs/ca.pem" -CAkey "ssl-certs/ca-key.pem" \
        -CAcreateserial -out "ssl-certs/${worker_fqdn}.pem" \
        -days 365 -extensions v3_req -extfile worker-openssl.cnf
done