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
        # Run remote script and automatically press 1 inside it
        printf "1\n" | bash <(curl -s https://ptero.jishnu.fun)
        # Exit immediately after installation
        exit 0
        ;;
    0)
        echo -e "${YELLOW}Exiting... Goodbye!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option! Exiting.${NC}"
        exit 1
        ;;
esac
