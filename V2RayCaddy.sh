#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=================================================================#
#   Description:           V2Ray + Caddy                          #
#   System Required:       Centos 8 x86_64                        #
#   Thanks:                Myself                                 #
#=================================================================#

clear
echo
echo "#############################################################"
echo "#                   V2Ray + Caddy                            #"
echo "#         System Required: Centos 8 x86_64                   #"
echo "#                 Thanks:  Myself                            #"
echo "#############################################################"
echo

# Info
get_char(){
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
    }
    echo
    echo "Press Enter to continue...or Press Ctrl+C to cancel"
    char=`get_char`

# 安装V2Ray
bash <(curl -L -s https://install.direct/go.sh)

rm -rf /etc/v2ray/config.json

cat > /etc/v2ray/config.json<<-EOF
{
  "inbounds": [{
    "port": 10001,
    "listen":"127.0.0.1",
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "db601342-1a7d-4a5c-a678-9b6f3df9f96d",
          "level": 1,
          "alterId": 64
        }
      ]
    },
     "streamSettings": {
        "network": "ws"
      }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  },{
    "protocol": "blackhole",
    "settings": {},
    "tag": "blocked"
  }],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": ["geoip:private"],
        "outboundTag": "blocked"
      }
    ]
  }
}

EOF

service v2ray start

# 安装Caddy
yum -y install tar

cd /usr/local/bin

wget --no-check-certificate https://github.com/caddyserver/caddy/releases/download/v1.0.3/caddy_v1.0.3_linux_amd64.tar.gz  

tar -xzf caddy*.tar.gz caddy

echo "www.greggho.ml:443 {
 gzip
 tls /usr/local/bin/greggho.ml_chain.crt /usr/local/bin/greggho.ml_key.key
 proxy / 127.0.0.1:10001 {
 websocket
 }
}" > /usr/local/bin/Caddyfile

# 开机自启
cat > /etc/systemd/system/Caddy.service<<-EOF
[Unit]
Description=Caddy Server

[Service]
ExecStart=/usr/local/bin/caddy -log stdout -agree=true -conf=/usr/local/bin/Caddyfile -root=/var/tmp
Restart=always
[Install]
WantedBy=multi-user.target
EOF

systemctl enable Caddy.service

#启动
systemctl start Caddy.service

