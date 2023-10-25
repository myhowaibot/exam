#!/bin/bash

sudo apt install --no-install-recommends software-properties-common -y

sudo add-apt-repository ppa:vbernat/haproxy-2.4 -y

sudo apt install libipset13 keepalived haproxy=2.4.\* -y 

read -p "Enter your floating ip: " IP

ip a 

read -p "Enter your network inteface: " NET


read -p "Enter your ip: " VIP

# Get the number of servers to create
read -p "Enter the number of keepalived and haproxy: " nm_servers


echo "making a check file"

cat >> /etc/keepalived/check_apiserver.sh <<EOF

#!/bin/sh

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

# Create the haproxy configuration
for (( i=1; i<$nm_servers; i++ ))
do
    read -p "Enter the ip addres of ha node$i: " MIP
    configs+="        $MIP\n"
done

echo -e "vrrp_script check_apiserver {\n  script '/etc/keepalived/check_apiserver.sh'\n  interval 1\n  timeout 1\n  fall 4\n  rise 2\n  weight -2\n}\n\nvrrp_instance VI_1 {\n    state BACKUP\n    interface $NET\n    virtual_router_id 60\n    priority 150\n    advert_int 1\n    unicast_src_ip $VIP\n    unicast_peer {\n  $configs    }\n    authentication {\n        auth_type PASS\n        auth_pass liesdfged\n    }\n    virtual_ipaddress {\n        $IP/24\n    }\n    track_script {\n        check_apiserver\n    }\n}\n"  > /etc/keepalived/keepalived.conf

systemctl enable --now keepalived

echo "creating the haproxy config files"

cat >> /etc/haproxy/haproxy.cfg <<EOF

frontend kubernetes-frontend
  bind *:6443
  mode tcp
  option tcplog
  default_backend kubernetes-backend

backend kubernetes-backend
  option httpchk GET /healthz
  http-check expect status 200
  mode tcp
  option ssl-hello-chk
  balance roundrobin
EOF

# Get the number of servers to create
read -p "Enter the number of k8s master to create: " num_servers

# Create the haproxy configuration
config=""
for (( i=1; i<=$num_servers; i++ ))
do
    read -p "Enter the ip addres of kubernetes master$i: " MIP
    config+="  server kmaster$i $MIP:6443 check fall 3 rise 2\n"
done

# Save the configuration to a file
echo -e "$config" >> /etc/haproxy/haproxy.cfg

systemctl stop haproxy

systemctl enable --now keepalived

watch systemctl status keepalived &&  systemctl enable haproxy && systemctl restart haproxy
