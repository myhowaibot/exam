#!/bin/bash

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



read -p "Enter your PR: " PR



echo "making a check file"



chmod +x /etc/keepalived/check_apiserver.sh



echo "setting up the keepalived config file"


read -p "Enter the number of keepalived: " nm_servers

configs=""

for (( i=1; i<=$nm_servers; i++ ))
do
    read -p "Enter the ip addres of keepalived node$i: " MIP
    configs+="        $MIP\n"
done


echo -e "vrrp_script check_apiserver {\n  script '/etc/keepalived/check_apiserver.sh'\n  interval 1\n  timeout 1\n  fall 4\n  rise 2\n  weight -2\n}\n\nvrrp_instance VI_1 {\n    state BACKUP\n    interface $NET\n    virtual_router_id 60\n    priority $PR\n    advert_int 1\n    unicast_src_ip $VIP\n    unicast_peer {\n$configs    }\n    authentication {\n        auth_type PASS\n        auth_pass liesdfged\n    }\n    virtual_ipaddress {\n        $IP/24\n    }\n    track_script {\n        check_apiserver\n    }\n}\n"
if yrn; then
    echo -e "vrrp_script check_apiserver {\n  script '/etc/keepalived/check_apiserver.sh'\n  interval 1\n  timeout 1\n  fall 4\n  rise 2\n  weight -2\n}\n\nvrrp_instance VI_1 {\n    state BACKUP\n    interface $NET\n    virtual_router_id 60\n    priority $PR\n    advert_int 1\n    unicast_src_ip $VIP\n    unicast_peer {\n$configs    }\n    authentication {\n        auth_type PASS\n        auth_pass liesdfged\n    }\n    virtual_ipaddress {\n        $IP/24\n    }\n    track_script {\n        check_apiserver\n    }\n}\n"  > /etc/keepalived/keepalived.conf;
    sudo systemctl enable --now keepalived && journalctl -flu keepalived
else
    echo "bye";
fi
 

