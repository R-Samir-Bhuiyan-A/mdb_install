#!/bin/bash

# Function to remove all components
remove_all() {
    echo "Removing all components..."
    
    # Stop and disable services
    systemctl stop mdbr
    systemctl disable mdbr
    systemctl stop mdb
    systemctl disable mdb
    
    # Remove systemd service files
    rm -f /etc/systemd/system/mdbr.service
    rm -f /etc/systemd/system/mdb.service
    
    # Remove the /etc/mdb directory
    rm -rf /etc/mdb/
    
    # Remove fnm and Node.js versions
    if command -v fnm &> /dev/null; then
        echo "Removing fnm..."
        rm -rf ~/.fnm
        rm -f ~/.bashrc # To remove fnm source line
    fi

    # Check and remove Node.js installations
    if [ -d /root/.fnm ]; then
        echo "Removing Node.js versions..."
        local node_path
        node_path=$(which node)
        if [ -n "$node_path" ]; then
            rm -f "$node_path"
        fi
    fi
    
    echo "Removing Nginx configuration..."
    rm -f /etc/nginx/sites-available/mdb.conf
    rm -f /etc/nginx/sites-enabled/mdb.conf
    
    echo "Reloading systemd..."
    systemctl daemon-reload
    
    echo "Removing curl and unzip..."
    apt remove -y curl unzip
    
    echo "Removing Nginx..."
    apt remove -y nginx
    
    echo "Uninstallation completed successfully."
}

# Function to remove Node.js and mdb
remove_node_mdb() {
    echo "Removing Node.js and mdb..."
    
    # Stop and disable services
    systemctl stop mdbr
    systemctl disable mdbr
    systemctl stop mdb
    systemctl disable mdb
    
    # Remove systemd service files
    rm -f /etc/systemd/system/mdbr.service
    rm -f /etc/systemd/system/mdb.service
    
    # Remove the /etc/mdb directory
    rm -rf /etc/mdb/
    
    # Remove fnm and Node.js versions
    if command -v fnm &> /dev/null; then
        echo "Removing fnm..."
        rm -rf ~/.fnm
        rm -f ~/.bashrc # To remove fnm source line
    fi

    # Check and remove Node.js installations
    local node_path
    node_path=$(which node)
    if [ -n "$node_path" ]; then
        rm -f "$node_path"
    fi
    
    echo "Removing Nginx configuration..."
    rm -f /etc/nginx/sites-available/mdb.conf
    rm -f /etc/nginx/sites-enabled/mdb.conf
    
    echo "Reloading systemd..."
    systemctl daemon-reload
    
    echo "Uninstallation completed successfully."
}

# Function to remove mdb only
remove_mdb() {
    echo "Removing mdb only..."
    
    # Stop and disable services
    systemctl stop mdbr
    systemctl disable mdbr
    systemctl stop mdb
    systemctl disable mdb
    
    # Remove systemd service files
    rm -f /etc/systemd/system/mdbr.service
    rm -f /etc/systemd/system/mdb.service
    
    # Remove the /etc/mdb directory
    rm -rf /etc/mdb/
    
    # Remove Nginx configuration
    rm -f /etc/nginx/sites-available/mdb.conf
    rm -f /etc/nginx/sites-enabled/mdb.conf
    
    echo "Reloading systemd..."
    systemctl daemon-reload
    
    echo "Uninstallation completed successfully."
}

# Main menu
echo "Select an option to uninstall:"
echo "1. Remove all components (Node.js, fnm, mdb files, services, Nginx config)"
echo "2. Remove Node.js and mdb (mdb files, Node.js, services, Nginx config)"
echo "3. Remove mdb only (mdb files, services, Nginx config)"
read -r choice

case "$choice" in
    1)
        remove_all
        ;;
    2)
        remove_node_mdb
        ;;
    3)
        remove_mdb
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
