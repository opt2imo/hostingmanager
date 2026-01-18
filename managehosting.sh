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
            echo -e "${CYAN}Installing Docker & Wings...${NC}"
    sudo apt update && sudo apt upgrade -y && \
    sudo apt install -y curl tar unzip && \
    curl -fsSL https://get.docker.com | sh && \
    sudo systemctl enable --now docker && \
    sudo mkdir -p /etc/pterodactyl && \
    cd /etc/pterodactyl && \
    curl -L -o wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64 && \
    chmod +x wings

    echo -e "${CYAN}Creating wings.service...${NC}"
    sudo tee /etc/systemd/system/wings.service > /dev/null << 'EOF'
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/etc/pterodactyl/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable wings

    echo -e "${GREEN}Wings installed successfully.${NC}"
    echo -e "${YELLOW}Paste your Wings configuration from the panel to start it.${NC}"
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
