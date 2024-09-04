#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Function to install required packages
install_packages() {
    echo "Installing required packages..."
    apt update
    apt install -y unzip curl nginx certbot python3-certbot-nginx
}

# Function to install or update fnm
install_fnm() {
    if ! command -v fnm &> /dev/null; then
        echo "Installing fnm..."
        curl -fsSL https://fnm.vercel.app/install | bash
        source ~/.bashrc
    else
        echo "fnm is already installed."
    fi
}

# Function to install a specific Node.js version
install_node() {
    local version=$1
    echo "Installing Node.js version $version..."
    fnm install "$version" --latest
    fnm use "$version"
}

# Prompt user for Node.js version
echo "Choose the Node.js version to install (20, 21, or 22):"
read -r node_version

case "$node_version" in
    20|21|22)
        install_node "$node_version"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Verify the installed Node.js and npm versions
echo "Verifying Node.js version:"
node -v
echo "Verifying npm version:"
npm -v

# Create the directory /etc/mdb if it does not exist
echo "Creating directory /etc/mdb if it does not exist..."
mkdir -p /etc/mdb/

# Download and unzip the MDB.zip file
echo "Downloading MDB.zip..."
curl -L -o /tmp/MDB.zip https://github.com/R-Samir-Bhuiyan-A/minecraft-kit-bot/releases/download/mdb2.0/MDB.zip

echo "Unzipping MDB.zip to /etc/mdb..."
unzip -o /tmp/MDB.zip -d /etc/mdb/

# Prompt user for .env file values
read -p "Enter IP (default: 6b6t.org): " ip
ip=${ip:-6b6t.org}

read -p "Enter PORT (default: 25565): " port
port=${port:-25565}

read -p "Enter BOTNAME (default: changeme_mdb): " botname
botname=${botname:-changeme_mdb}

read -p "Enter PASSWORD (default: changeme_mdb): " password
password=${password:-changeme_mdb}

read -p "Enter VERSION (default: 1.17): " version
version=${version:-1.17}

read -p "Enter SERVER_PORT (default: 8081): " server_port
server_port=${server_port:-8081}

read -p "Enter WS_PORT (default: 3000): " ws_port
ws_port=${ws_port:-3000}

# Update .env file
echo "Updating .env file..."
env_file="/etc/mdb/.env"
tee "$env_file" > /dev/null <<EOL
IP=$ip
PORT=$port
BOTNAME=$botname
PASSWORD=$password
VERSION=$version
SERVER_PORT=$server_port
WS_PORT=$ws_port
EOL

# Make everything executable and set permissions
echo "Setting permissions..."
chmod -R +x /etc/mdb/
chown -R root:root /etc/mdb/

# Create the systemd service files
node_path=$(which node)
service_file_mdbr="/etc/systemd/system/mdbr.service"
service_file_mdb="/etc/systemd/system/mdb.service"

# mdbr.service file
tee "$service_file_mdbr" > /dev/null <<EOL
[Unit]
Description=Mineflayer delivery bot API daemon
After=network.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/etc/mdb/
ExecStart=${node_path} /etc/mdb/server.js
Restart=always
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOL

# mdb.service file
tee "$service_file_mdb" > /dev/null <<EOL
[Unit]
Description=Mineflayer delivery bot panel
After=network.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/etc/mdb/
ExecStart=${node_path} /etc/mdb/panel.js
Restart=always
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOL

# Configure nginx
read -p "Enter domain name (leave blank for no SSL): " domain

nginx_conf="/etc/nginx/sites-available/mdb.conf"
if [ -n "$domain" ]; then
    echo "Configuring nginx with SSL for domain: $domain"
    tee "$nginx_conf" > /dev/null <<EOL
# Redirect HTTPS to HTTP
server {
    listen 443 ssl;
    server_name $domain;

    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;

    # Add any additional SSL configurations here
    
    location / {
        return 301 http://\$host\$request_uri;
    }
}

# Serve HTTP requests
server {
    listen 80;
    server_name $domain;

    location / {
        proxy_pass http://localhost:\$(grep SERVER_PORT $env_file | cut -d '=' -f 2);
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

    # Install SSL certificates using Certbot
    echo "Installing SSL certificates..."
    certbot --nginx -d "$domain"
else
    echo "Configuring nginx without SSL"
    tee "$nginx_conf" > /dev/null <<EOL
server {
    listen 80;
    server_name dlm.lol;

    location / {
        proxy_pass http://localhost:\$(grep SERVER_PORT $env_file | cut -d '=' -f 2);
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL
fi

# Enable the new nginx configuration and restart nginx
ln -sf /etc/nginx/sites-available/mdb.conf /etc/nginx/sites-enabled/
echo "Restarting nginx..."
systemctl restart nginx

# Reload systemd and start the new services
systemctl daemon-reload
systemctl start mdbr
systemctl enable mdbr
systemctl start mdb
systemctl enable mdb

echo "Setup completed successfully."
