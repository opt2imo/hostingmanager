#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${CYAN}==================================${NC}"
echo -e "${GREEN}        PTERODACTYL MANAGER        ${NC}"
echo -e "${CYAN}==================================${NC}"
echo -e "${YELLOW}          OptimoPlaysOP            ${NC}"
echo ""

echo -e "${GREEN}1) Pterodactyl Panel Install${NC}"
echo -e "${RED}0) Exit${NC}"
echo ""
read -p "Enter your choice: " choice

case $choice in
    1)
        echo ""
        read -p "Enter your domain (example: panel.example.com): " DOMAIN
        read -p "Enter MySQL root password: " DBROOTPASS
        echo ""

        echo -e "${CYAN}Installing dependencies...${NC}"
        sudo apt update
        sudo apt install -y \
            curl tar unzip git nginx mariadb-server redis-server \
            php8.1 php8.1-cli php8.1-fpm php8.1-common php8.1-mbstring \
            php8.1-bcmath php8.1-gd php8.1-mysql php8.1-curl php8.1-xml php8.1-zip

        echo -e "${CYAN}Installing Composer...${NC}"
        curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

        echo -e "${CYAN}Downloading Pterodactyl Panel...${NC}"
        sudo mkdir -p /var/www/pterodactyl
        cd /var/www/pterodactyl || exit
        sudo curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
        sudo tar -xzvf panel.tar.gz
        sudo chmod -R 755 storage/* bootstrap/cache/

        echo -e "${CYAN}Installing PHP dependencies...${NC}"
        sudo composer install --no-dev --optimize-autoloader

        echo -e "${CYAN}Setting up environment...${NC}"
        sudo cp .env.example .env

        # Auto configure environment
        sudo sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|g" .env
        sudo sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DBROOTPASS}|g" .env

        sudo php artisan key:generate --force

        echo -e "${CYAN}Setting up database...${NC}"
        sudo mysql -u root -p"${DBROOTPASS}" -e "CREATE DATABASE IF NOT EXISTS panel; CREATE USER 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '${DBROOTPASS}'; GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1'; FLUSH PRIVILEGES;"

        echo -e "${CYAN}Running migrations & seeders...${NC}"
        sudo php artisan migrate --seed --force

        echo -e "${CYAN}Creating Nginx config for ${DOMAIN}...${NC}"
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
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

        sudo ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
        sudo nginx -t && sudo systemctl reload nginx

        echo -e "${CYAN}Setting permissions...${NC}"
        sudo chown -R www-data:www-data /var/www/pterodactyl

        echo -e "${CYAN}Creating admin panel user...${NC}"
        cd /var/www/pterodactyl || exit
        sudo php artisan p:user:make --email admin@${DOMAIN} --name Admin --password "ChangeMe123" --

