#!/bin/bash
sudo chown -R www-data:www-data /var/www/laravel
sudo chmod -R 755 /var/www/laravel/storage
sudo chmod -R 755 /var/www/laravel/bootstrap/cache
