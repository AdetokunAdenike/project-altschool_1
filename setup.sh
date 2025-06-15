#!/bin/bash

# Exit immediately if a command fails
set -e

echo "🚀 Starting FarmLinks360 DevOps Setup..."

# Update and install system packages
echo "📦 Updating system..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing Node.js and npm..."
sudo apt install nodejs npm -y

echo "📦 Installing Nginx..."
sudo apt install nginx -y

# Install PM2 globally
echo "⚙️ Installing PM2..."
sudo npm install -g pm2

# Navigate to the project directory
echo "📁 Changing directory to project-altschool_1..."
cd ~/project-altschool_1

# Install Node.js dependencies
echo "📦 Installing project dependencies..."
npm install

# Start the app with PM2
echo "🚀 Starting app.js with PM2..."
pm2 start app.js --name farm-links || pm2 restart farm-links

# Setup PM2 to start on reboot
echo "🛠️ Setting up PM2 startup service..."
pm2 startup systemd -u $USER --hp $HOME
pm2 save

# Configure Nginx reverse proxy
echo "🌐 Configuring Nginx reverse proxy..."
NGINX_CONF="/etc/nginx/sites-available/default"

sudo bash -c "cat > $NGINX_CONF" <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location /static/ {
        alias /home/ubuntu/project-altschool_1/static/;
    }
}
EOF

# Reload Nginx
echo "🔄 Testing and reloading Nginx..."
sudo nginx -t && sudo systemctl reload nginx

# Configure UFW
echo "🔐 Setting up UFW rules..."
sudo ufw allow 'Nginx Full'
sudo ufw allow OpenSSH
sudo ufw --force enable

echo "✅ Setup complete! Visit your app at http://3.249.238.95/"

