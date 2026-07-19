#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}[*] Verifying target environment...${NC}"

IS_ROOT=0
if [ "$(id -u)" -eq 0 ]; then
    IS_ROOT=1
fi

IS_NETHUNTER=0
IS_TERMUX=0

if [ -f /etc/os-release ] && grep -q -i "kali" /etc/os-release; then
    IS_NETHUNTER=1
elif [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
    IS_TERMUX=1
fi

if [ "$IS_NETHUNTER" -eq 1 ]; then
    echo -e "${GREEN}[+] Environment: Kali NetHunter${NC}"
    PKG_MANAGER="apt"
elif [ "$IS_TERMUX" -eq 1 ] && [ "$IS_ROOT" -eq 1 ]; then
    echo -e "${GREEN}[+] Environment: Termux (Root)${NC}"
    PKG_MANAGER="pkg"
elif [ "$IS_TERMUX" -eq 1 ] && [ "$IS_ROOT" -eq 0 ]; then
    echo -e "${GREEN}[+] Environment: Termux (Non-Root)${NC}"
    if ! pm path com.termux.api 2>/dev/null | grep -q "com.termux.api"; then
        echo -e "${RED}[!] Error: Termux:API companion app is missing.${NC}"
        echo -e "${YELLOW}[i] Install it from F-Droid: https://f-droid.org/packages/com.termux.api/${NC}"
        exit 1
    fi
    PKG_MANAGER="pkg"
else
    echo -e "${RED}[!] Error: Unsupported environment platform.${NC}"
    exit 1
fi

echo -e "${BLUE}[*] Syncing repositories and core dependencies...${NC}"
if [ "$PKG_MANAGER" = "apt" ]; then
    apt update -y && apt install -y python3 python3-pip libusb-1.0-0 git
    PIP_CMD="pip3"
elif [ "$PKG_MANAGER" = "pkg" ]; then
    pkg update -y && pkg install -y python termux-api libusb git
    PIP_CMD="pip"
fi

echo -e "${BLUE}[*] Configuring Python framework...${NC}"
$PIP_CMD install --upgrade pip 2>/dev/null
$PIP_CMD install pyusb || {
    echo -e "${RED}[!] Error: Failed to build pyusb constraints.${NC}"
    exit 1
}
$PIP_CMD install espbridge

if [ ! -f "nrsuite" ]; then
    echo -e "${BLUE}[*] Fetching NRSuite source binaries...${NC}"
    git clone https://github.com/7wp81x/NRSuite.git
    cd NRSuite || exit 1
fi

if [ -f "nrsuite" ]; then
    chmod +x nrsuite
else
    echo -e "${RED}[!] Error: Script infrastructure layout missing.${NC}"
    exit 1
fi

echo -e "${GREEN}[+] Setup finalized successfully.${NC}"
