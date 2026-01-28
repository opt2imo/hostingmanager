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
    echo -e "${GREEN}6) Uninstall Tool${NC}"
    echo -e "${GREEN}7) System Information${NC}"
    echo -e "${GREEN}8) Blueprint Installer${NC}"
    echo -e "${RED}0) Exit${NC}"
    echo ""
    read -p "Enter your choice: " choice

    case $choice in

        1)
            echo -e "${CYAN}Starting Pterodactyl Panel installer...${NC}"
            bash <(curl -fsSL https://raw.githubusercontent.com/opt2imo/hostingmanager/main/hostingmanager.sh)
            read -p "Press Enter to return to main menu..."
            ;;

        2)
            echo -e "${CYAN}Creating certificates for Wings...${NC}"
            sudo mkdir -p /etc/certs
            cd /etc/certs || exit 1
            sudo openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
                -subj "/C=NA/ST=NA/L=NA/O=NA/CN=Generic SSL Certificate" \
                -keyout privkey.pem -out fullchain.pem
            cd ~

            echo -e "${CYAN}Installing Wings...${NC}"
            bash <(curl -s https://pterodactyl-installer.se)
            read -p "Press Enter to return to main menu..."
            ;;

        3)
            echo -e "${CYAN}Installing Tailscale...${NC}"
            curl -fsSL https://tailscale.com/install.sh | sh
            tailscale up
            read -p "Press Enter to return to main menu..."
            ;;

        4)
            echo -e "${CYAN}Installing Cloudflare Tunnel...${NC}"
            sudo mkdir -p --mode=0755 /usr/share/keyrings
            curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null
            echo "deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main" | sudo tee /etc/apt/sources.list.d/cloudflared.list
            sudo apt update && sudo apt install cloudflared -y
            read -p "Press Enter to return to main menu..."
            ;;

        5)
            echo -e "${CYAN}Creating admin user...${NC}"
            cd /var/www/pterodactyl || { echo -e "${RED}Panel not found!${NC}"; sleep 2; break; }
            php artisan p:user:make --admin
            read -p "Press Enter to return to main menu..."
            ;;

        6)
            while true; do
                clear
                echo -e "${CYAN}==================================${NC}"
                echo -e "${GREEN}        UNINSTALL TOOL             ${NC}"
                echo -e "${CYAN}==================================${NC}"
                echo ""
                echo -e "${RED}1) Uninstall Panel${NC}"
                echo -e "${RED}2) Uninstall Wings${NC}"
                echo -e "${RED}3) Uninstall Panel + Wings${NC}"
                echo -e "${YELLOW}4) Exit to Main Menu${NC}"
                echo ""
                read -p "Enter your choice: " uchoice

                case $uchoice in
                    1)
                        sudo systemctl stop nginx php8.*-fpm 2>/dev/null
                        sudo rm -rf /var/www/pterodactyl
                        sudo rm -f /etc/nginx/sites-enabled/pterodactyl.conf
                        sudo rm -f /etc/nginx/sites-available/pterodactyl.conf
                        sudo systemctl reload nginx 2>/dev/null
                        read
                        ;;
                    2)
                        sudo systemctl stop wings 2>/dev/null
                        sudo systemctl disable wings 2>/dev/null
                        sudo rm -f /etc/systemd/system/wings.service
                        sudo rm -rf /etc/pterodactyl
                        sudo systemctl daemon-reload
                        read
                        ;;
                    3)
                        sudo systemctl stop nginx php8.*-fpm wings 2>/dev/null
                        sudo rm -rf /var/www/pterodactyl /etc/pterodactyl
                        sudo rm -f /etc/systemd/system/wings.service
                        sudo systemctl daemon-reload
                        read
                        ;;
                    4)
                        break
                        ;;
                esac
            done
            ;;

        7)
            sudo apt install neofetch -y && neofetch
            read -p "Press Enter to return to main menu..."
            ;;

        8)
            echo -e "${CYAN}Running Blueprint Installer...${NC}"
            cd /var/www/pterodactyl || { echo -e "${RED}Panel not found!${NC}"; sleep 2; break; }
            bash <(curl -fsSL https://raw.githubusercontent.com/opt2imo/hostingmanager/main/blueprint-installer.sh)
            cd ~
            read -p "Press Enter to return to main menu..."
            ;;

        0)
            exit 0
            ;;

        *)
            echo -e "${RED}Invalid option!${NC}"
            sleep 1.5
            ;;
    esac
done
