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
    echo -e "${GREEN}2) Wings Install${NC}"
    echo -e "${GREEN}3) Tailscale Setup${NC}"
    echo -e "${GREEN}4) Cloudflare Install${NC}"
    echo -e "${GREEN}5) Make Admin User${NC}"
    echo -e "${RED}0) Exit${NC}"
    echo ""
    read -p "Enter your choice: " choice

    case $choice in
        1)
            # Pterodactyl Panel Install (remote script)
            bash <(curl -fsSL https://raw.githubusercontent.com/opt2imo/hostingmanager/main/hostingmanager.sh)
            ;;
        2)
            # Wings Install
            echo -e "${CYAN}Starting Wings installation...${NC}"
    printf "2\n" | bash <(curl -fsSL https://vps1.jishnu.fun)
    echo -e "${YELLOW}Press Enter to return to main menu...${NC}"
    read
    ;;
        3)
            # Tailscale Setup
            echo -e "${CYAN}Starting Tailscale setup...${NC}"
            curl -fsSL https://tailscale.com/install.sh | sh && tailscale up
            echo -e "${YELLOW}Press Enter to return to main menu...${NC}"
            read
            ;;
        4)
            # Cloudflare Install
            echo -e "${CYAN}Installing Cloudflare (cloudflared)...${NC}"
            sudo mkdir -p --mode=0755 /usr/share/keyrings
            curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null
            echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
            sudo apt update && sudo apt install cloudflared -y
            echo -e "${YELLOW}Press Enter to return to main menu...${NC}"
            read
            ;;
        5)
            # Make Admin User
            read -p "Enter admin username: " ADMINUSER
            read -p "Enter admin email: " ADMINEMAIL
            read -p "Enter admin password: " ADMINPASS
            echo -e "${CYAN}Creating admin user in Pterodactyl panel...${NC}"
            cd /var/www/pterodactyl && php /var/www/pterodactyl/artisan p:user:make
            echo -e "${GREEN}Admin user created!${NC}"
            echo -e "${YELLOW}Press Enter to return to main menu...${NC}"
            read
            ;;
        0)
            echo -e "${YELLOW}Exiting... Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            sleep 1.5
            ;;
    esac
done
