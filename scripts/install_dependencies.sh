#!/bin/bash

if ! [ -x "$(command -v php)" ]; then
  echo "PHP is not installed. Installing PHP..."

  # Update package manager and install PHP along with necessary extensions
  sudo apt-get update
  sudo apt-get install -y php-cli php-mbstring php-xml php-zip php-dom curl git unzip

  echo "PHP installed successfully."
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
else
  echo "Composer is already installed."
fi

if ! [ -x "$(command -v nginx)" ]; then
  sudo apt update && sudo apt install -y nginx
else
  echo "Nginx is already installed."
fi
