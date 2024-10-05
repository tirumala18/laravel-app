#!/bin/bash


cd /var/www/html/laravel

composer install --no-dev --optimize-autoloader

# Run Laravel artisan commands
php artisan cache:clear
php artisan config:cache
php artisan route:cache

sudo systemctl daemon-reload
sudo systemctl reload php8.3-fpm
