#!/bin/bash
# Stop script for mitmproxy traffic capture scenario

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}Stopping mitmproxy scenario...${NC}"

docker-compose down

echo -e "${GREEN}✓ Scenario stopped${NC}"
