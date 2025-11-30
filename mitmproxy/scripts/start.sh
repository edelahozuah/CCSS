#!/bin/bash
# Start script for mitmproxy traffic capture scenario

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starting mitmproxy scenario...${NC}"
echo ""

# Start containers
docker-compose up -d

# Wait for services
echo "Waiting for services to be ready..."
sleep 3

# Check status
if docker-compose ps | grep -q "Up"; then
    echo ""
    echo -e "${GREEN}✓ Scenario started successfully!${NC}"
    echo ""
    echo -e "${BLUE}Access URLs:${NC}"
    echo -e "  Firefox (noVNC): ${GREEN}http://localhost:5800${NC}"
    echo -e "  Mitmweb:         ${GREEN}http://localhost:8081${NC} (password: mitm1234)"
    echo ""
else
    echo -e "\033[0;31m✗ Failed to start containers${NC}"
    echo "Check logs with: docker-compose logs"
    exit 1
fi
