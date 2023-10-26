#!/bin/bash

# sudo apt install --no-install-recommends software-properties-common -y

# sudo add-apt-repository ppa:vbernat/haproxy-2.4 -y

# sudo apt install haproxy=2.4 -y 

# echo "creating the haproxy config files"

# read -p "Enter your floating ip: " IP

# touch /tmp/uguyfgouf

# cat >> /tmp/uguyfgouf <<EOF

# frontend kubernetes-frontend
#   bind *:6443
#   mode tcp
#   option tcplog
#   default_backend kubernetes-backend

# backend kubernetes-backend
#   option httpchk GET /healthz
#   http-check expect status 200
#   mode tcp
#   option ssl-hello-chk
#   balance roundrobin
# EOF

# # Get the number of servers to create
# read -p "Enter the number of k8s master to create: " num_servers

# # Create the haproxy configuration
# config=""
# for (( i=1; i<=$num_servers; i++ ))
# do
#     read -p "Enter the ip addres of kubernetes master$i: " MIP
#     config+="  server kmaster$i $MIP:6443 check fall 3 rise 2\n"
# done

# # Save the configuration to a file
# echo -e "$config" >> /tmp/uguyfgouf
# if yrn; then
#     cat /tmp/uguyfgouf >> /etc/haproxy/haproxy.cfg
#     cat /etc/haproxy/haproxy.cfg
#     if yrn; then
#         cat /tmp/uguyfgouf >> /etc/haproxy/haproxy.cfg    
#         systemctl stop haproxy
#         systemctl enable haproxy && systemctl restart haproxy
# else
#     echo "bye";
# fi


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


 
sudo apt install net-tools
apt-get update && apt-get upgrade && apt-get install -y haproxy




echo "creating the haproxy config files"

read -p "Enter your floating ip: " IP

ip a 

read -p "Enter your network inteface: " NET

read -p "Enter your SERVER ip: " MYIP
rm -rf /tmp/uguyfgouf
touch /tmp/uguyfgouf
cat /etc/haproxy/haproxy.cfg >> /tmp/uguyfgouf
sudo echo "

global
    user haproxy
    group haproxy
defaults
    mode http
    log global
    retries 2
    timeout connect 3000ms
    timeout server 5000ms
    timeout client 5000ms
frontend kubernetes
    bind *:6443
    option tcplog
    mode tcp
    default_backend kubernetes-master-nodes
backend kubernetes-master-nodes
    mode tcp
    balance roundrobin
    option tcp-check
" >> /tmp/uguyfgouf

# Get the number of servers to create
read -p "Enter the number of k8s master to create: " num_servers

# Create the haproxy configuration
config=""
for (( i=0; i<$num_servers; i++ ))
do
    read -p "Enter the ip addres of kubernetes master$i: " MIP
    config+="  server k8s-master-$i $MIP:6443 check fall 3 rise 2\n"
done



echo -e "$config" >> /tmp/uguyfgouf
sudo cat /tmp/uguyfgouf
if yrn; then
        mv /etc/haproxy/haproxy.cfg{,.back} && sudo cat /tmp/uguyfgouf >> /etc/haproxy/haproxy.cfg  && sudo rm -rf /tmp/uguyfgouf
else
    echo "bye";
    exit 1

fi

sudo echo "net.ipv4.ip_nonlocal_bind=1" >> /etc/sysctl.conf
sysctl -p


systemctl stop haproxy
systemctl enable haproxy && systemctl restart haproxy && watch systemctl status haproxy

netstat -ntlp

