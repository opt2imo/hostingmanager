#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

clear

# Header
echo -e "${CYAN}==================================${NC}"
echo -e "${GREEN}        PTERODACTYL MANAGER        ${NC}"
echo -e "${CYAN}==================================${NC}"
echo -e "${YELLOW}          OptimoPlaysOP            ${NC}"
echo ""
echo -e "${GREEN}2) Tailscale Setup${NC}"
echo -e "${RED}0) Exit${NC}"
echo ""
read -p "Enter your choice: " choice

case $choice in
    2)
        echo ""
        echo -e "${CYAN}Starting Tailscale setup...${NC}"
        curl -fsSL https://tailscale.com/install.sh | sh && tailscale up
        ;;
    0)
        echo ""
        echo -e "${YELLOW}Exiting... Goodbye!${NC}"
        exit 0
        ;;
    *)
        echo ""
        echo -e "${RED}Invalid option. Please run the script again.${NC}"
        ;;
esac
