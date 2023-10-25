# websrv_1, websrv_2
Install `apache`:
```
apt install apache2
```
Changing the default page:
```
rm /var/www/html/index.html
vim index.html

# index.html
<!DOCTYPE html>
<html>
<head>
</head>
<body>
<p>Welcome to National Skills 2021 - <span id='time-date'></span>.</p>
<script>
var dt = new Date();
document.getElementById('time-date').innerHTML=dt;
</script>
</body>
</html>
```
Restart the `apache` service:
```
systemctl restart apache2
```
Set the header `X_Served_By`:
```
a2enmod headers
cd /etc/apache2
vim envvars

# envvars
export HOSTNAME=$(hostname)
```

Edit the apache config file:
```
vim /etc/apache2/sites-enabled/000-default.conf

# Add the following line
Header set X_Served_By "${HOSTNAME}"
```
Restart the `apache` service:
```
systemctl restart apache2
```
For testing:
```
curl -i localhost
```
It should reponse the `X_Served_By` header equal to hostname.  
![temp](https://github.com/gravityofskills/Iran-National-Skills-Competition/blob/apache2-doc/docs/19th/53%20-%20Cloud%20Computing/National/Solution/Day_1_v1.0/pictures/5.png)

![temp](https://github.com/gravityofskills/Iran-National-Skills-Competition/blob/apache2-doc/docs/19th/53%20-%20Cloud%20Computing/National/Solution/Day_1_v1.0/pictures/6.png)

Installing docker:
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg - -dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu focal stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install docker
```

# websrv_1
Mounting the 5G disk:
```
mkdir -p /mnt/blk_gp2_5g
mkfs.ext4 /dev/sdb
mount /dev/sdb /mnt/blk_gp2_5g
```
Persisting:
```
vim /etc/fstab

# fstab
UUID=3cbb9e1b-429b-4961-9bc3-2961a481cf27 /mnt/blk_gp2_5g ext4 defaults 0 1
```
Create file in the path:
```
vim /mnt/blk_gp2_5g/index.html

# index.html
This is additional_webservice
```
Creating `docker-compose` file in the path:
```
mkdir -p /opt/container
vim /opt/container/docker-compose.yml

# docker-compose.yml
version: "3"
services:
  nginx:
    container_name: "addtional_webservice"
    image: "nginx:alpine"
    ports:
      - "8080:80"
    restart: "always"
    volumes:
      - /mnt/blk_gp2_5g/index.html:/usr/share/nginx/html/index.html
```

Up the container:
```
docker-comopse up -d
```

# websrv_2
Creating a `docker-compose` file:
```
# docker-compose.yml
version: '3'

networks:
  monitoring:
    driver: bridge

volumes:
  prometheus_data: {}

services:
  prometheus:
    image: prom/prometheus
    container_name: monitoring_prometheus
    restart: unless-stopped
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    ports:
      - '9090:9090'
    networks:
      - monitoring

  grafana:
    image: grafana/grafana
    container_name: monitoring_grafana
    restart: unless-stopped
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=Skills53
      - GF_USERS_ALLOW_SIGN_UP=false
    ports:
      - '3000:3000'
    networks:
      - monitoring
  node_exporter:
    container_name: 'monitoring_node_exporter'
    volumes:
      - /:/host:ro  
    #CHANGING THE ROOT , PROC , SYS FILE SYSTEMS
    command:
      - '--path.rootfs=/host'
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
    networks:
      - monitoring
    image: prom/node-exporter
    ports:
      - '9100:9100'
```
For scraping `node exporter` metrics by prometheus, Create a `prometheus.yml` file in that directory:
```
global:
  scrape_interval: 1m

scrape_configs:
  - job_name: "prometheus"
    scrape_interval: 1m
    static_configs:
      - targets: ["prometheus:9090"]

  - job_name: "node"
    static_configs:
      - targets: ["node_exporter:9100"]
```
Up the containers:
```
docker-compose up -d
```
After uping the containers enter the grafana page and insert the promethues info in datasources section:

![Screenshot from 2023-05-16 21-53-36](https://github.com/gravityofskills/Iran-National-Skills-Competition/blob/main/docs/19th/53%20-%20Cloud%20Computing/National/Solution/Day_1_v1.0/pictures/1.png)

Save it and after that create a dashboard named `node exporter` and create a panel in it named `systemload` and run queries below:

![Screenshot from 2023-05-16 23-01-47](https://github.com/gravityofskills/Iran-National-Skills-Competition/blob/main/docs/19th/53%20-%20Cloud%20Computing/National/Solution/Day_1_v1.0/pictures/2.png)

![Screenshot from 2023-05-16 23-01-58](https://github.com/gravityofskills/Iran-National-Skills-Competition/blob/main/docs/19th/53%20-%20Cloud%20Computing/National/Solution/Day_1_v1.0/pictures/3.png)

![Screenshot from 2023-05-16 23-02-06](https://github.com/gravityofskills/Iran-National-Skills-Competition/blob/main/docs/19th/53%20-%20Cloud%20Computing/National/Solution/Day_1_v1.0/pictures/4.png)



# Elastic Load Balancer
Use `nginx` as a load-balancer:
```
rm /etc/nginx/sites-enabled/default
vim /etc/nginx/sites-enabled/default

# default
server {
  listen 80;
  location / {
     proxy_read_timeout 4;
     proxy_pass http://myapp1; 
  }
}
```
Edit the `/etc/nginx/nginx.conf` file in the `http` block:
```
upstream myapp1 {
          server websrv1 max_fails=10;
          server websrv2 max_fails=10;
        }
```
Set the domains of webservers with the ips in `/etc/hosts`:
```
192.168.122.67 websrv1
192.168.122.68 websrv2 
```
Restart the nginx service:
```
systemctl restart nginx
```
