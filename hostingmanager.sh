#!/bin/bash

read -p "Enter your domain: " DOMAIN
read -p "Enter MySQL root password: " DBROOTPASS

# Install PHP 8.2 and dependencies
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y \
  curl tar unzip git nginx mariadb-server redis-server \
  php8.2 php8.2-cli php8.2-fpm php8.2-common php8.2-mbstring \
  php8.2-bcmath php8.2-gd php8.2-mysql php8.2-curl php8.2-xml php8.2-zip

# Composer
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Download Pterodactyl
sudo mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl || exit
sudo curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
sudo tar -xzvf panel.tar.gz
sudo chmod -R 755 storage/* bootstrap/cache/

# Composer dependencies
sudo composer install --no-dev --optimize-autoloader

# Environment
sudo cp .env.example .env
sudo sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|g" .env
sudo sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DBROOTPASS}|g" .env
sudo php artisan key:generate --force

# Database
sudo mysql -u root -p"${DBROOTPASS}" -e "CREATE DATABASE IF NOT EXISTS panel; CREATE USER 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '${DBROOTPASS}'; GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1'; FLUSH PRIVILEGES;"

# Migrations
sudo php artisan migrate --seed --force

# Nginx
sudo tee /etc/nginx/sites-available/pterodactyl.conf > /dev/null <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    root /var/www/pterodactyl/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo chown -R www-data:www-data /var/www/pterodactyl

echo "Pterodactyl installation complete! Exiting..."
exit 0
