#!/bin/bash

# Baca domain dari file
domain=$(cat /root/domain)

# Hasilkan konfigurasi HAProxy dengan domain
cat <<EOF > /etc/haproxy/haproxy.cfg
listen front
    mode tcp
    bind *:443
    tcp-request inspect-delay 5s
    tcp-request content accept if { req_ssl_hello_type 1 }
    use_backend fallback if { req.ssl_sni -i end $domain }

backend fallback
    mode tcp
    server srv1 127.0.0.1:11000
EOF
