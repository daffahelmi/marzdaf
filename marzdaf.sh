#!/bin/bash
sfile="https://github.com/daffahelmi/marzdaf/blob/main"

# Install wget, curl, and sudo if not already installed
apt-get update
apt-get install -y wget curl sudo

# Input domain
read -rp "Masukkan Domain: " domain
echo "$domain" > /root/domain
domain=$(cat /root/domain)

# Preparation
clear
cd;
apt-get update;
apt-get upgrade -y;

# Remove unused Modules
apt-get -y --purge remove samba* apache2* sendmail* bind9*;

# Install BBR
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

# Install toolkit
timedatectl set-timezone Asia/Jakarta && \
apt-get install net-tools lnav haveged htop vnstat gpg neofetch -y

# Install Marzban
sudo bash -c "$(curl -sL https://github.com/daffahelmi/Marzban-scripts/raw/master/marzban.sh)" @ install

# Install socat
apt install iptables cron socat -y

# Install SSL cert
sudo mkdir -p /var/lib/marzban/certs/ && \
systemctl stop docker && \
curl https://get.acme.sh | sh && \
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --issue --standalone -d $domain \
--key-file /var/lib/marzban/certs/key.pem \
--fullchain-file /var/lib/marzban/certs/fullchain.pem && \
systemctl start docker

# cronjob setup
(crontab -l ; echo "0 */6 * * * sync; echo 3 > /proc/sys/vm/drop_caches") | crontab - 
(crontab -l ; echo "0 0 * * * systemctl restart wireproxy") | crontab -

# Swap RAM 1GB
wget https://raw.githubusercontent.com/Cretezy/Swap/master/swap.sh -O swap && sh swap 1G && rm swap

# Download db.sqlite3
wget -O /var/lib/marzban/db.sqlite3 https://raw.githubusercontent.com/daffahelmi/marzdaf/main/db.sqlite3

# Download xray_config.json
wget -O /var/lib/marzban/xray_config.json https://raw.githubusercontent.com/daffahelmi/marzdaf/main/xray_config.json

# Download .env
wget -O /opt/marzban/.env https://raw.githubusercontent.com/daffahelmi/marzdaf/main/env

# Download Subscription
sudo wget -N -P /var/lib/marzban/templates/subscription/  https://raw.githubusercontent.com/daffahelmi/marzdaf/refs/heads/main/index.html

# Download Geositemod
wget -O /root/geositemod https://raw.githubusercontent.com/daffahelmi/marzdaf/main/geositemod && chmod +x /root/geositemod && /root/geositemod && rm -f /root/geositemod

# Fix Marzban error log
wget -O /usr/local/bin/fixmarzban https://raw.githubusercontent.com/daffahelmi/marzdaf/main/fixnodeusage && \
wget -O /etc/systemd/system/fix.service https://raw.githubusercontent.com/daffahelmi/marzdaf/main/fix.service && \
chmod +x /usr/local/bin/fixmarzban && \
systemctl enable fix.service && \
systemctl start fix.service

# Install cek service
wget -O /root/.bash_profile https://raw.githubusercontent.com/daffahelmi/marzdaf/main/profile && \
wget -O /usr/bin/cek https://raw.githubusercontent.com/daffahelmi/marzdaf/main/cek && \
chmod +x /usr/bin/cek

# Install WARP Proxy
bash <(curl -sSL https://raw.githubusercontent.com/hamid-gh98/x-ui-scripts/main/install_warp_proxy.sh) -y

# Finalizing
apt autoremove -y && apt clean && \
systemctl restart docker && \
cd /opt/marzban && \
docker compose down && docker compose up -d && \
cd && \
rm /root/marzdaf.sh