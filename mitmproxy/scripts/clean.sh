#!/bin/bash
# Clean script for mitmproxy traffic capture scenario
# This script removes captured data and optionally resets configuration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Mitmproxy Scenario Cleanup${NC}"
echo ""

# Ask for confirmation
read -p "$(echo -e ${YELLOW}This will delete all captured traffic and logs. Continue? [y/N]: ${NC})" -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

# Stop containers first
echo -e "${BLUE}Stopping containers...${NC}"
docker-compose down

# Clean captured data
echo -e "${BLUE}Cleaning captured data...${NC}"

# Remove flow captures
if [ -d "captures" ]; then
    rm -rf captures/*
    echo -e "${GREEN}✓${NC} Cleared captures/"
fi

# Remove logs
if [ -d "logs" ]; then
    rm -rf logs/*
    echo -e "${GREEN}✓${NC} Cleared logs/"
fi

# Clean Firefox cache and logs (but keep profile)
if [ -d "firefox-config/cache2" ]; then
    rm -rf firefox-config/cache2/*
    echo -e "${GREEN}✓${NC} Cleared Firefox cache"
fi

if [ -d "firefox-config/log" ]; then
    rm -rf firefox-config/log/*
    echo -e "${GREEN}✓${NC} Cleared Firefox logs"
fi

echo ""
echo -e "${GREEN}✓ Cleanup completed${NC}"
echo ""

# Ask if user wants to reset completely
read -p "$(echo -e ${YELLOW}Do you want to completely reset the scenario (remove Firefox profile and CA certs)? [y/N]: ${NC})" -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Performing complete reset...${NC}"
    
    # Remove all Docker volumes
    docker-compose down -v
    
    # Remove Firefox profile
    if [ -d "firefox-config/profile" ]; then
        rm -rf firefox-config/profile
        echo -e "${GREEN}✓${NC} Removed Firefox profile"
    fi
    
    # Remove mitmproxy CA certificates
    if [ -d "mitmproxy-data" ]; then
        rm -rf mitmproxy-data/*
        echo -e "${GREEN}✓${NC} Removed mitmproxy CA certificates"
    fi
    
    echo ""
    echo -e "${GREEN}✓ Complete reset finished${NC}"
    echo -e "${BLUE}Run ./scripts/setup.sh to reinitialize the scenario${NC}"
else
    echo -e "${BLUE}Scenario data cleaned but configuration preserved${NC}"
    echo -e "${BLUE}Run ./scripts/start.sh to resume${NC}"
fi
