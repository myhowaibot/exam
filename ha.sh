#!/bin/bash

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


sudo apt install --no-install-recommends software-properties-common -y
sudo apt install haproxy -y

echo "creating the haproxy config files"

read -p "Enter your floating ip: " IP

touch /tmp/uguyfgouf

cat >> /tmp/uguyfgouf <<EOF

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
echo -e "$config" >> /tmp/uguyfgouf
cat /tmp/uguyfgouf    
if yrn; then
        cat /tmp/uguyfgouf >> /etc/haproxy/haproxy.cfg  && rm -rf /tmp/uguyfgouf
        sudo systemctl stop haproxy
        sudo systemctl enable haproxy && sudo systemctl restart haproxy && watch systemctl status haproxy
else
    echo "bye";
fi

