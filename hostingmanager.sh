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
            cd
