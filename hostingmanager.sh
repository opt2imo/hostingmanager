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
            echo -e "${CYAN}Starting Pterodactyl Panel installation...${NC}"
            echo -e "${YELLOW}(Auto-selecting Panel Install option)${NC}"
            echo ""

            # Auto-select option 0 (Panel install)
            printf "0\n" | bash <(curl -fsSL https://pterodactyl-installer.se/install.sh)

            echo ""
            echo -e "${GREEN}Pterodactyl installation finished.${NC}"
            echo ""

            # Create panel user
            if [ -d "/var/www/pterodactyl" ]; then
                echo -e "${CYAN}Creating panel user...${NC}"
                cd /var/www/pterodactyl || exit
                php artisan p:user:make
            else
                echo -e "${RED}Panel directory not found. User creation skipped.${NC}"
            fi

            echo ""
            echo -e "${YELLOW}Press Enter to return to main menu...${NC}"
            read
            ;;
        2)
            echo ""
            echo -e "${CYAN}Starting Tailscale setup...${NC}"
            curl -fsSL https://tailscale.com/install.sh | sh && tailscale up
            echo ""
            echo -e "${YELLOW}Press Enter to return to main menu...${NC}"
            read
            ;;
        3)
            echo ""
            echo -e "${CYAN}Installing Cloudflare (cloudflared)...${NC}"
            sudo mkdir -p --mode=0755 /usr/share/keyrings && \
            curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null && \
            echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list && \
            sudo apt update && sudo apt install cloudflared -y
            echo ""
            echo -e "${YELLOW}Press Enter to return to main menu...${NC}"
            read
            ;;
        0)
            echo ""
            echo -e "${YELLOW}Exiting... Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo ""
            echo -e "${RED}Invalid option!${NC}"
            sleep 1.5
            ;;
    esac
done
