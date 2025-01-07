#!/bin/bash

# Update and upgrade the system
echo "Updating system packages..."
sudo yum update -y

# Install Apache (httpd)
echo "Installing Apache (httpd)..."
sudo yum install httpd -y

# Start and enable Apache to start on boot
sudo systemctl start httpd
sudo systemctl enable httpd

# Create users and set their password
for user in sanket gaurang
do
    # Create user with home directory
    useradd -m -s /bin/bash "$user"
    
    # Set password to '123'
    echo "$user:123" | chpasswd
    
    echo "User $user created with home directory and password set to '123'."
done

# Add users to sudoers using visudo
{
    echo "sanket    ALL=(ALL:ALL) ALL"
    echo "gaurang   ALL=(ALL:ALL) ALL"
} | sudo EDITOR='tee -a' visudo

echo "Users sanket and gaurang have been added to sudoers."
echo "Apache (httpd) has been installed and started."