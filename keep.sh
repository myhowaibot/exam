#!/bin/sh

sudo apt install keepalived -y

yrn() {
    while true; do
        read -p "Do you want to proceed? (y/n) " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}



read -p "Enter your floating ip: " IP

ip a 

read -p "Enter your network inteface: " NET


read -p "Enter your ip: " VIP



echo "making a check file"

cat >> /etc/keepalived/check_apiserver.sh <<EOF

errorExit() {
  echo "*** $@" 1>&2
  exit 1
}

curl --silent --max-time 2 --insecure https://localhost:6443/ -o /dev/null || errorExit "Error GET https://localhost:6443/"
if ip addr | grep -q $IP; then
  curl --silent --max-time 2 --insecure https://$IP:6443/ -o /dev/null || errorExit "Error GET https://$IP:6443/"
fi
EOF


chmod +x /etc/keepalived/check_apiserver.sh



echo "setting up the keepalived config file"


read -p "Enter the number of keepalived and haproxy: " nm_servers

for (( i=1; i<=$nm_servers; i++ ))
do
    read -p "Enter the ip addres of ha node$i: " MIP
    configs+="        $MIP\n"
done


echo -e 'vrrp_script check_apiserver {\n  script "/etc/keepalived/check_apiserver.sh"\n  interval 1\n  timeout 1\n  fall 4\n  rise 2\n  weight -2\n}\n\nvrrp_instance VI_1 {\n    state BACKUP\n    interface $NET\n    virtual_router_id 60\n    priority 150\n    advert_int 3\n    unicast_src_ip $VIP\n    unicast_peer {\n  $configs    }\n    authentication {\n        auth_type PASS\n        auth_pass liesdfged\n    }\n    virtual_ipaddress {\n        $IP/24\n    }\n    track_script {\n        check_apiserver\n    }\n}\n'
if yrn; then
    echo -e 'vrrp_script check_apiserver {\n  script "/etc/keepalived/check_apiserver.sh"\n  interval 1\n  timeout 1\n  fall 4\n  rise 2\n  weight -2\n}\n\nvrrp_instance VI_1 {\n    state BACKUP\n    interface $NET\n    virtual_router_id 60\n    priority 150\n    advert_int 3\n    unicast_src_ip $VIP\n    unicast_peer {\n  $configs    }\n    authentication {\n        auth_type PASS\n        auth_pass liesdfged\n    }\n    virtual_ipaddress {\n        $IP/24\n    }\n    track_script {\n        check_apiserver\n    }\n}\n'  > /etc/keepalived/keepalived.conf;
    sudo systemctl enable --now keepalived && watch systemctl status keepalived 
else
    echo "bye";
fi


