chown -R :www-data /var/www/html/laravel
chmod -R 755 /var/www/html/laravel
chown -R 755 www-data:www-data /var/www/html/laravel/storage
chmod -R 775 /var/www/html/laravel/storage /var/www/html/laravel/bootstrap/cache

