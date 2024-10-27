#!/bin/bash
sfile="https://github.com/daffahelmi/marzdaf/blob/main"

#domain
read -rp "Masukkan Domain: " domain
echo "$domain" > /root/domain
domain=$(cat /root/domain)

#email
read -rp "Masukkan Email anda: " email

#Preparation
clear
cd;
apt-get update;

#Remove unused Module
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

#install bbr
echo 'fs.file-max = 500000
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.core.rmem_max=4000000
net.ipv4.tcp_mtu_probing = 1
net.ipv4.ip_forward=1
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1' >> /etc/sysctl.conf
sysctl -p;

#install toolkit
timedatectl set-timezone Asia/Jakarta
apt-get install net-tools lnav vnstat haproxy -y

#Install Marzban
sudo bash -c "$(curl -sL https://github.com/daffahelmi/Marzban-scripts/raw/master/marzban.sh)" @ install

#install socat
apt install iptables -y
apt install cron socat -y

#install cert
sudo mkdir -p /var/lib/marzban/certs/
systemctl stop docker
curl https://get.acme.sh | sh -s email=$email
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --standalone -d $domain \
--key-file /var/lib/marzban/certs/key.pem \
--fullchain-file /var/lib/marzban/certs/fullchain.pem
systemctl start docker

#swap ram 1gb
wget https://raw.githubusercontent.com/Cretezy/Swap/master/swap.sh -O swap
sh swap 1G
rm swap

# Unduh db.sqlite3 langsung ke /var/lib/marzban
sudo wget -O /var/lib/marzban/db.sqlite3 https://github.com/daffahelmi/marzdaf/blob/main/db.sqlite3

# Unduh xray_config.json langsung ke /var/lib/marzban
sudo wget -O /var/lib/marzban/xray_config.json https://github.com/daffahelmi/marzdaf/blob/main/xray_config.json

# Unduh haproxy.cfg langsung ke /etc/haproxy
sudo wget -O /etc/haproxy/haproxy.cfg https://github.com/daffahelmi/marzdaf/blob/main/haproxy.cfg

#finishing
apt autoremove -y
apt clean
systemctl restart docker
cd /opt/marzban
docker compose down && docker compose up -d
cd
rm /root/marzdaf.sh




