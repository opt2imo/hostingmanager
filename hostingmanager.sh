#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

while true; do
    clear

    # Header
    echo -e "${CYAN}==================================${NC}"
    echo -e "${GREEN}        PTERODACTYL MANAGER        ${NC}"
    echo -e "${CYAN}==================================${NC}"
    echo -e "${YELLOW}          OptimoPlaysOP            ${NC}"
    echo ""
    echo -e "${GREEN}2) Tailscale Setup${NC}"
    echo -e "${GREEN}3) Cloudflare Install${NC}"
    echo -e "${RED}0) Exit${NC}"
    echo ""
    read -p "Enter your choice: " choice

    case $choice in
        2)
            echo ""
            echo -e "${CYAN}Starting Tailscale setup...${NC}"
            curl -fsSL https://tailscale.com/install.sh | sh && tailscale up
            echo ""
            read -p "Press Enter to return to main menu..."
            ;;
        3)
            echo ""
            echo -e "${CYAN}Installing Cloudflare (cloudflared)...${NC}"
            sudo mkdir -p --mode=0755 /usr/share/keyrings && \
            curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null && \
            echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list && \
            sudo apt-get update && \
            sudo apt-get install cloudflared -y
            echo ""
            read -p "Press Enter to return to main menu..."
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
