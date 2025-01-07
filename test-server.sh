#!/bin/bash

# Variables
SERVER_IP="$1"
DOMAIN="$2"
EMAIL="admin@example.com"
PRIVATE_KEY_PATH="./AIS-Jignesh.pem" # correct path to your PEM file

# Check if both SERVER_IP and DOMAIN are provided
if [ -z "$SERVER_IP" ] || [ -z "$DOMAIN" ]; then
  echo "Usage: $0 <server-ip> <domain>"
  exit 1
fi

# Function to check SSH connection
check_ssh_connection() {
  ssh -i "$PRIVATE_KEY_PATH" -o BatchMode=yes -o ConnectTimeout=5 ubuntu@$SERVER_IP "exit" 2>/dev/null
  return $?
}

# Check if we can SSH into the server
if ! check_ssh_connection; then
  echo "Failed to connect to $SERVER_IP. Please check the server IP and SSH access."
  exit 1
fi

# Update and Install Required Packages
ssh -o StrictHostKeyChecking=no ubuntu@$SERVER_IP <<EOF
  sudo apt-get update
  sudo apt-get install -y apache2 nginx certbot python3-certbot-apache
EOF

# Test Default Configuration for Apache
ssh ubuntu@$SERVER_IP <<EOF
  echo "Testing Default Apache Configuration..."
  if apache2ctl configtest; then
    echo "Default Apache configuration is valid."
  else
    echo "Default Apache configuration failed."
    exit 1
  fi
EOF

# Configure Apache with Certbot for SSL
ssh ubuntu@$SERVER_IP <<EOF
  echo "Configuring Apache for Certbot..."
  sudo certbot --apache --non-interactive --agree-tos -m $EMAIL -d $DOMAIN
  if [ \$? -eq 0 ]; then
    echo "Certbot configuration successful."
  else
    echo "Certbot configuration failed."
    exit 1
  fi
EOF

# Configure Apache for Non-Standard Port 8080
ssh ubuntu@$SERVER_IP <<EOF
  echo "Configuring non-standard port 8080 for Apache..."
  sudo bash -c 'echo "Listen 8080" >> /etc/apache2/ports.conf'
  sudo bash -c 'cat <<EOL > /etc/apache2/sites-available/test.conf
<VirtualHost *:8080>
    ServerName $DOMAIN
    DocumentRoot /var/www/html
</VirtualHost>
EOL'
  sudo a2ensite test
  sudo systemctl restart apache2

  echo "Validating non-standard port 8080..."
  curl -I http://localhost:8080
EOF
