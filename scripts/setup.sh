#!/bin/bash


cd /var/www/html/laravel
composer install --no-dev --optimize-autoloader

# Variables
LARAVEL_ROOT="/var/www/html/laravel"
NGINX_CONF_DEST="/etc/nginx/sites-available/laravel"
NGINX_CONF_LINK="/etc/nginx/sites-enabled/laravel"

# Check if Nginx config for Laravel is already enabled
if [ ! -f "$NGINX_CONF_DEST" ]; then
    echo "Setting up Nginx for Laravel..."

    # Add the Nginx configuration directly to the file
    sudo bash -c "cat > $NGINX_CONF_DEST" << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /var/www/html/laravel/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

    # Enable the Nginx config by creating a symlink
    sudo ln -s "$NGINX_CONF_DEST" "$NGINX_CONF_LINK"

    echo "Nginx configuration created and enabled."
else
    echo "Nginx configuration already exists."
fi

# Test Nginx configuration
sudo nginx -t

# Reload Nginx to apply the changes
sudo systemctl reload nginx

echo "Nginx setup complete."

sudo systemctl restart nginx
