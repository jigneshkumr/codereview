#!/bin/bash
sudo apt update
sudo apt install -y apache2 nginx

# Configure Apache
echo "<html><body><h1>Welcome to Apache on ${server_name}.${domain_name}</h1></body></html>" | sudo tee /var/www/html/index.html
sudo tee /etc/apache2/sites-available/${server_name}.${domain_name}.conf << EOF
<VirtualHost *:80>
    ServerName ${server_name}.${domain_name}
    DocumentRoot /var/www/html
</VirtualHost>
EOF
sudo a2ensite ${server_name}.${domain_name}
sudo systemctl restart apache2

# Configure NGINX
sudo tee /etc/nginx/sites-available/${server_name}.${domain_name} << EOF
server {
    listen 80;
    server_name ${server_name}.${domain_name};

    location / {
        proxy_pass http://127.0.0.1:80;
    }
}
EOF
sudo ln -s /etc/nginx/sites-available/${server_name}.${domain_name} /etc/nginx/sites-enabled/
sudo systemctl stop nginx
sudo systemctl restart apache2

sudo wget -qO - https://sb.files.autoinstallssl.com/packages/linux/version/latest/get.autoinstallssl.sh | sudo bash -s
#sudo runautoinstallssl.sh installcertificate --token Dv529d6iU395WXjQWWhIo55K5ZO555 --includewww --validationtype file --validationprovider filesystem