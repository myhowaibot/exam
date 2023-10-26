wget -c https://get.helm.sh/helm-v3.13.0-linux-amd64.tar.gz
tar -xzvf helm-v3.13.0-linux-amd64.tar.gz
mv linux-amd64/helm /bin/helm
chmod +x /bin/helm
rm -rf helm-v3.13.0-linux-amd64.tar.gz linux-amd64