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
    echo -e "${GREEN}         ██████╗ ██████╗ ████████╗██╗███╗   ███╗ ██████╗     ██████╗ ██╗      █████╗ ██╗   ██╗███████╗     ██████╗ ██████╗ 
██╔═══██╗██╔══██╗╚══██╔══╝██║████╗ ████║██╔═══██╗    ██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝██╔════╝    ██╔═══██╗██╔══██╗
██║   ██║██████╔╝   ██║   ██║██╔████╔██║██║   ██║    ██████╔╝██║     ███████║ ╚████╔╝ ███████╗    ██║   ██║██████╔╝
██║   ██║██╔═══╝    ██║   ██║██║╚██╔╝██║██║   ██║    ██╔═══╝ ██║     ██╔══██║  ╚██╔╝  ╚════██║    ██║   ██║██╔═══╝ 
╚██████╔╝██║        ██║   ██║██║ ╚═╝ ██║╚██████╔╝    ██║     ███████╗██║  ██║   ██║   ███████║    ╚██████╔╝██║     
 ╚═════╝ ╚═╝        ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝     ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝     ╚═════╝ ╚═╝     
                                                                                                                           ${NC}"
    echo -e "${CYAN}==================================${NC}"
    echo -e "${YELLOW}          PTERODACTYL MANAGER            ${NC}"
    echo ""
    echo -e "${GREEN}1) Pterodactyl Panel Install${NC}"
    echo -e "${GREEN}2) Wings Install${NC}"
    echo -e "${GREEN}3) Tailscale Setup${NC}"
    echo -e "${GREEN}4) Cloudflare Install${NC}"
    echo -e "${GREEN}5) Make Admin User${NC}"
    echo -e "${GREEN}6) Uninstall Tool${NC}"
    echo -e "${GREEN}7) System Information${NC}"
    echo -e "${GREEN}8) Blueprint Installer${NC}"
    echo -e "${GREEN}9) Blueprint Extensions${NC}"
    echo -e "${GREEN}10) Blueprint Themes${NC}"
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
    echo -e "${CYAN}Generating certificates...${NC}"
    mkdir -p /etc/certs && cd /etc/certs && \
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
        -subj "/C=NA/ST=NA/L=NA/O=NA/CN=Generic SSL Certificate" \
        -keyout privkey.pem -out fullchain.pem && cd

    echo -e "${CYAN}Installing Wings...${NC}"
    bash <(curl -s https://pterodactyl-installer.se)

    echo ""
    echo -e "${CYAN}Wings configuration${NC}"
    read -p "Enter Node UUID: " W_UUID
    read -p "Enter Token ID: " W_TOKEN_ID
    read -p "Enter Token: " W_TOKEN
    read -p "Enter Panel URL (example: https://panel.example.com): " W_PANEL

    echo -e "${CYAN}Creating Wings config.yml...${NC}"
    sudo mkdir -p /etc/pterodactyl
    sudo tee /etc/pterodactyl/config.yml > /dev/null <<EOF
debug: false
uuid: ${W_UUID}
token_id: ${W_TOKEN_ID}
token: ${W_TOKEN}
api:
  host: 0.0.0.0
  port: 8443
  ssl:
    enabled: true
    cert: /etc/certs/fullchain.pem
    key: /etc/certs/privkey.pem
  upload_limit: 100
system:
  data: /var/lib/pterodactyl/volumes
  sftp:
    bind_port: 2022
allowed_mounts: []
remote: '${W_PANEL}'
EOF

    echo -e "${GREEN}Wings configured successfully!${NC}"

    sudo systemctl start wings

    echo -e "${CYAN}Wings service started.${NC}"
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
            cd /var/www/pterodactyl || { echo -e "${RED}Panel not found!${NC}"; sleep 2; continue; }
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
                        sudo systemctl reload nginx 2>/dev/null
                        read -p "Panel removed. Press Enter..."
                        ;;
                    2)
                        sudo systemctl stop wings 2>/dev/null
                        sudo systemctl disable wings 2>/dev/null
                        sudo rm -rf /etc/pterodactyl
                        sudo rm -f /etc/systemd/system/wings.service
                        sudo systemctl daemon-reload
                        read -p "Wings removed. Press Enter..."
                        ;;
                    3)
                        sudo systemctl stop nginx php8.*-fpm wings 2>/dev/null
                        sudo rm -rf /var/www/pterodactyl /etc/pterodactyl
                        sudo rm -f /etc/systemd/system/wings.service
                        sudo systemctl daemon-reload
                        read -p "Panel + Wings removed. Press Enter..."
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
            cd /var/www/pterodactyl || { echo -e "${RED}Panel not found!${NC}"; sleep 2; continue; }
            bash <(curl -fsSL https://raw.githubusercontent.com/opt2imo/hostingmanager/main/blueprint-installer.sh)
            cd ~
            read -p "Press Enter to return to main menu..."
            ;;

        9)
            while true; do
                clear
                echo -e "${CYAN}==================================${NC}"
                echo -e "${GREEN}     BLUEPRINT EXTENSIONS          ${NC}"
                echo -e "${CYAN}==================================${NC}"
                echo ""
                echo -e "${GREEN}1) Install MC Plugins Blueprint${NC}"
                echo -e "${RED}0) Exit to Main Menu${NC}"
                echo ""
                read -p "Enter your choice: " bchoice

                case $bchoice in
                    1)
                        cd /var/www/pterodactyl || { echo -e "${RED}Panel not found!${NC}"; sleep 2; continue; }
                        wget -O mcplugins.blueprint https://github.com/OptimoPEOP/blueprint-extentions/releases/download/ok/mcplugins.blueprint
                        blueprint -install mcplugins.blueprint
                        cd ~
                        read -p "Installation complete. Press Enter..."
                        ;;
                    0)
                        break
                        ;;
                esac
            done
            ;;

10)
    while true; do
        clear
        echo -e "${CYAN}==================================${NC}"
        echo -e "${GREEN}        BLUEPRINT THEMES           ${NC}"
        echo -e "${CYAN}==================================${NC}"
        echo ""
        echo -e "${GREEN}1) Nebula Theme${NC}"
        echo -e "${GREEN}2) Euphoria Theme${NC}"
        echo -e "${GREEN}3) Nook Theme${NC}"
        echo -e "${RED}0) Exit to Main Menu${NC}"
        echo ""
        read -p "Enter your choice: " tchoice

        case $tchoice in
            1)
                echo -e "${CYAN}Installing Nebula Theme...${NC}"
                cd || exit
                git clone https://github.com/username5642/nebula.git
                cd nebula || exit
                bash install.gg
                blueprint -install nebula
                cd
                read -p "Nebula installed. Press Enter..."
                ;;
            2)
                echo -e "${CYAN}Installing Euphoria Theme...${NC}"
                cd /var/www/pterodactyl || { echo "Panel not found"; sleep 2; continue; }
                wget -O euphoriatheme.blueprint "https://cdn.discordapp.com/attachments/1376132032689606676/1466408735772770444/euphoriatheme.blueprint?ex=697ca30f&is=697b518f&hm=31151cef7178d831bcdefbd657132dec7d91d7f8ef07aa9838f90b32ee390135"
                blueprint -install euphoriatheme.blueprint
                cd
                read -p "Euphoria installed. Press Enter..."
                ;;
            3)
                echo -e "${CYAN}Installing Nook Theme...${NC}"
                sudo apt update
                sudo apt install -y software-properties-common
                sudo add-apt-repository ppa:ondrej/php -y
                sudo apt update
                sudo apt install -y php8.3
                php -v

                cd /var/www/pterodactyl || { echo "Panel not found"; sleep 2; continue; }
                php artisan down
                curl -L https://github.com/Nookure/NookTheme/releases/latest/download/panel.tar.gz | tar -xzv
                chmod -R 755 storage/* bootstrap/cache
                composer install --no-dev --optimize-autoloader
                php artisan view:clear
                php artisan config:clear
                php artisan migrate --seed --force
                chown -R www-data:www-data /var/www/pterodactyl/*
                php artisan queue:restart
                php artisan up

                cd
                read -p "Nook Theme installed. Press Enter..."
                ;;
            0)
                break
                ;;
            *)
                echo -e "${RED}Invalid option!${NC}"
                sleep 1.5
                ;;
        esac
    done
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
