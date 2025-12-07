#!/bin/bash

# HIDE Installation Script
# Installs the hide command system

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           HIDE - Installation Script v1.0.0                ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run with sudo: sudo ./install.sh${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/4] Checking dependencies...${NC}"

# Check for required commands
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python3 is required but not installed${NC}"
    exit 1
fi

if ! command -v base64 &> /dev/null; then
    echo -e "${RED}base64 is required but not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All dependencies found${NC}"
echo ""

echo -e "${YELLOW}[2/4] Making scripts executable...${NC}"
chmod +x hide
chmod +x hide-notepad
echo -e "${GREEN}✓ Scripts are now executable${NC}"
echo ""

echo -e "${YELLOW}[3/4] Installing to /usr/local/bin...${NC}"
cp hide /usr/local/bin/
cp hide-notepad /usr/local/bin/
echo -e "${GREEN}✓ Installed successfully${NC}"
echo ""

echo -e "${YELLOW}[4/4] Verifying installation...${NC}"
if command -v hide &> /dev/null && command -v hide-notepad &> /dev/null; then
    echo -e "${GREEN}✓ Installation verified${NC}"
else
    echo -e "${RED}✗ Installation verification failed${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                 INSTALLATION COMPLETE!                     ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}The 'hide' command is now available system-wide!${NC}"
echo ""
echo -e "${YELLOW}Quick Start:${NC}"
echo -e "  ${CYAN}hide${NC}              - Create a new hidden file/folder"
echo -e "  ${CYAN}hide ls all${NC}       - List all hidden items"
echo -e "  ${CYAN}hide help${NC}         - Show full command reference"
echo ""
echo -e "${YELLOW}Example workflow:${NC}"
echo -e "  1. Run ${CYAN}hide${NC} to create a hidden file"
echo -e "  2. Follow the prompts to name it"
echo -e "  3. Use ${CYAN}hide open <n>${NC} to access it"
echo -e "  4. Use ${CYAN}hide key <n>${NC} to lock it with password"
echo ""
echo -e "${GREEN}Enjoy your invisible file system!${NC}"
echo ""
