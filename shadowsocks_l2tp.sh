#!/bin/bash


# <UDF name="SERVER_PORT" Label="Shadowsocks Server Port" default="8388" />
# <UDF name="LOCAL_ADDRESS" Label="Local Address" default="127.0.0.1" />
# <UDF name="LOCAL_PORT" Label="Local Port" default="1080" />
# <UDF name="PASSWORD" Label="Password" />
# <UDF name="METHOD" Label="Method" default="rc4-md5" />

# <UDF name="L2TP_USERNAME" Label="L2TP Username" default="" />
# <UDF name="L2TP_PASSWORD" Label="L2TP Password" default="" />
# <UDF name="L2TP_PSK" Label="L2TP PSK" default="" />

cat >>/etc/gai.conf<<EOF
precedence ::ffff:0:0/96  100
EOF

sudo apt-get update

sudo apt-get install -y python-pip
export LC_ALL=C
pip install --upgrade pip

sudo pip install shadowsocks
sudo apt-get install -y python-m2crypto

cat >>/etc/shadowsocks.json<<EOF
{
  "server":"0.0.0.0",
  "server_port":$SERVER_PORT,
  "password":"$PASSWORD",
  "local_address":"$LOCAL_ADDRESS",
  "local_port":$LOCAL_PORT,
  "method":"$METHOD",
  "timeout":300
}
EOF

sudo chmod 755 /etc/shadowsocks.json

cat >>/etc/rc.local<<EOF
/usr/local/bin/ssserver –c /etc/shadowsocks.json
EOF

sudo ssserver -c /etc/shadowsocks.json -d start

wget https://git.io/vpnsetup -O vpnsetup.sh
sudo VPN_IPSEC_PSK=$L2TP_PSK VPN_USER=$L2TP_USERNAME VPN_PASSWORD=$L2TP_PASSWORD sh vpnsetup.sh

echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf

sysctl -p

reboot
