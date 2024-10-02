#!/bin/bash


cd /var/www/html/laravel
composer install --no-dev --optimize-autoloader

# Variables
LARAVEL_ROOT="/var/www/html/laravel"
NGINX_CONF_SOURCE="./nginx.conf"          # Path to the nginx.conf file in the current directory
NGINX_CONF_DEST="/etc/nginx/sites-available/laravel"
NGINX_CONF_LINK="/etc/nginx/sites-enabled/laravel"

# Check if the Nginx configuration file exists in the current directory
if [ ! -f "$NGINX_CONF_SOURCE" ]; then
    echo "Nginx configuration file not found in the current directory!"
    exit 1
fi

# Check if Nginx config for Laravel is already enabled
if [ ! -f "$NGINX_CONF_DEST" ]; then
    echo "Setting up Nginx for Laravel..."

    # Copy the provided Nginx config file to the appropriate location
    sudo cp "$NGINX_CONF_SOURCE" "$NGINX_CONF_DEST"

    # Enable the Nginx config by creating a symlink
    sudo ln -s "$NGINX_CONF_DEST" "$NGINX_CONF_LINK"

    echo "Nginx configuration copied and enabled."
else
    echo "Nginx configuration already exists."
fi

# Test Nginx configuration
sudo nginx -t

# Reload Nginx to apply the changes
sudo systemctl reload nginx

echo "Nginx setup complete."

sudo systemctl restart nginx
