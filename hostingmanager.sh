#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

while true; do
    clear
    echo -e "${CYAN}==================================${NC}"
    echo -e "${GREEN}        PTERODACTYL MANAGER        ${NC}"
    echo -e "${CYAN}==================================${NC}"
    echo -e "${YELLOW}          OptimoPlaysOP            ${NC}"
    echo ""
    echo -e "${GREEN}1) Pterodactyl Panel Install${NC}"
    echo -e "${GREEN}2) Tailscale Setup${NC}"
    echo -e "${GREEN}3) Cloudflare Install${NC}"
    echo -e "${RED}0) Exit${NC}"
    echo ""
    read -p "Enter your choice: " choice

    case $choice in
        1)
            echo ""
            read -p "Enter your domain (example: panel.example.com): " DOMAIN
            read -p "Enter MySQL root password: " DBROOTPASS
            echo ""

            echo -e "${CYAN}Adding PHP 8.2 repository...${NC}"
            sudo apt update
            sudo apt install -y software-properties-common
            sudo add-apt-repository ppa:ondrej/php -y
            sudo apt update

            echo -e "${CYAN}Installing dependencies and PHP 8.2...${NC}"
            sudo apt install -y \
                curl tar unzip git nginx mariadb-server redis-server \
                php8.2 php8.2-cli php8.2-fpm php8.2-common php8.2-mbstring \
                php8.2-bcmath php8.2-gd php8.2-mysql php8.2-curl php8.2-xml php8.2-zip

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
            sudo sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|g" .env
            sudo sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DBROOTPASS}|g" .env
            sudo php artisan key:generate --force

            echo -e "${CYAN}Setting up database...${NC}"
            sudo mysql -u root -p"${DBROOTPASS}" -e "
