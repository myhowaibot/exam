#!/bin/bash

## change directory to /tmp
cd /tmp
## Container runtime (containerd) https://github.com/containerd/containerd/blob/main/docs/getting-started.md

wget https://github.com/containerd/containerd/releases/download/v1.7.1/containerd-1.7.1-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-1.7.1-linux-amd64.tar.gz

# containerd service 
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
mv containerd.service /etc/systemd/system/containerd.service
systemctl daemon-reload
systemctl enable --now containerd

##runc installation
wget https://github.com/opencontainers/runc/releases/download/v1.1.8/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc

## CNI plugin
wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.3.0.tgz

## containerd config
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd



# Disable swap
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true
swapoff -a
line_number=$(grep -n "swap" /etc/fstab | tail -1 | awk -F: '{print $1}')

if [ -n "$line_number" ]; then 
    sed -i "${line_number}s/^/#/" /etc/fstab
fi
mount -a 


# bridge
sudo modprobe br_netfilter
echo -e "net.ipv4.ip_forward = 1\nnet.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
sudo sysctl -p

# backup dns setup & Set 403 DNS
cp /etc/resolv.conf /etc/resolv.conf.bak
# added at the end
sudo systemctl stop systemd-resolved.service
sudo systemctl disable systemd-resolved.service

sudo sed -i 's/nameserver .*/nameserver 10.202.10.202/' /etc/resolv.conf


# install kubeadm kubelet kubectl
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl
sudo mkdir -m 775 /etc/apt/keyrings/ && sudo touch /etc/apt/keyrings/kubernetes-apt-keyring.gpg 
sudo curl -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key && sudo gpg --dearmor /etc/apt/keyrings/kubernetes-apt-keyring.gpg
cat /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo cat /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update && sudo apt-get install -y kubeadm

# pull images with kubeadm
kubeadm config images pull  --image-repository docker.iranrepo.ir/kubesphere --kubernetes-version 1.27.1 


# Changing the sandbox image
sudo sed -i '/sandbox_image/s/\"registry.k8s.io\/pause:3.8"/\"docker.iranrepo.ir\/kubesphere\/pause:3.9"/' /etc/containerd/config.toml
sudo systemctl restart containerd


#sudo sed -i 's/nameserver .*/nameserver 178.22.122.100/' /etc/resolv.conf

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
