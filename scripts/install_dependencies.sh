#!/bin/bash

if ! [ -x "$(command -v php)" ]; then
  echo "PHP is not installed. Installing PHP..."

  # Update package manager and install PHP along with necessary extensions
  sudo apt-get update
  sudo apt-get install -y php-cli php-fpm php-mbstring php-xml php-zip php-bcmath php-curl php-dom curl git unzip mysql-server php-mysql redis-server php-redis


  echo "php redis mysql installed successfully."
else
  echo "PHP is already installed."
fi


# Check if composer is installed
if ! [ -x "$(command -v composer)" ]; then
  echo "Composer is not installed. Installing Composer..."

  # Update package manager and install necessary dependencies
  sudo apt-get update
  sudo apt-get install -y curl php-cli php-mbstring git unzip

  # Download Composer installer
  curl -sS https://getcomposer.org/installer -o composer-setup.php

  # Verify the installer SHA-384 to ensure it was downloaded correctly
  HASH="$(curl -sS https://composer.github.io/installer.sig)"
  php -r "if (hash_file('sha384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"

  # Install Composer globally
  sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

  # Clean up the installer file
  rm composer-setup.php

  echo "Composer installed successfully."
  sudo systemctl start php8.3-fpm.service
  
else
  echo "Composer is already installed."
fi

if ! [ -x "$(command -v nginx)" ]; then
  sudo apt update && sudo apt install -y nginx
else
  echo "Nginx is already installed."
fi



sudo chmod -R 755 /var/www/html/laravel
sudo chown -R 755 www-data:www-data /var/www/html/laravel/storage
sudo chmod -R 775 /var/www/html/laravel/storage /var/www/html/laravel/bootstrap/cache
sudo chown -R www-data:www-data /var/www/html/laravel


# # Variables
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
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
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

sudo unlink /etc/nginx/sites-enabled/default

echo "Nginx setup complete."

sudo systemctl restart nginx
