#!/bin/bash
# Setup script for mitmproxy traffic capture scenario
# This script performs initial installation and configuration

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  Mitmproxy Scenario Setup Script${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if Docker is installed
echo -e "${BLUE}[1/6]${NC} Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    echo "  Visit: https://docs.docker.com/get-docker/"
    exit 1
fi
print_success "Docker is installed ($(docker --version))"

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    echo "  Visit: https://docs.docker.com/compose/install/"
    exit 1
fi
print_success "Docker Compose is installed ($(docker-compose --version))"

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running. Please start Docker first."
    exit 1
fi
print_success "Docker daemon is running"

# Check if required ports are available
echo ""
echo -e "${BLUE}[2/6]${NC} Checking port availability..."
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        print_warning "Port $port is already in use"
        return 1
    else
        print_success "Port $port is available"
        return 0
    fi
}

ports_ok=true
check_port 5800 || ports_ok=false
check_port 8080 || ports_ok=false
check_port 8081 || ports_ok=false

if [ "$ports_ok" = false ]; then
    print_warning "Some ports are in use. You may need to stop other services or modify .env"
fi

# Create directory structure
echo ""
echo -e "${BLUE}[3/6]${NC} Creating directory structure..."
mkdir -p scripts
mkdir -p addons
mkdir -p ejercicios/soluciones
mkdir -p captures
mkdir -p logs

print_success "Directory structure created"

# Create .env file if it doesn't exist
echo ""
echo -e "${BLUE}[4/6]${NC} Setting up environment variables..."
if [ ! -f .env ]; then
    cp .env.example .env
    print_success "Created .env file from template"
    print_info "You can edit .env to customize ports and settings"
else
    print_info ".env already exists, skipping creation"
fi

# Pull Docker images
echo ""
echo -e "${BLUE}[5/6]${NC} Pulling Docker images (this may take a few minutes)..."
docker-compose pull
print_success "Docker images pulled successfully"

# Start containers
echo ""
echo -e "${BLUE}[6/6]${NC} Starting containers..."
docker-compose up -d

# Wait for services to be ready
echo ""
print_info "Waiting for services to start..."
sleep 5

# Check if containers are running
if docker-compose ps | grep -q "Up"; then
    print_success "Containers are running"
else
    print_error "Failed to start containers. Check logs with: docker-compose logs"
    exit 1
fi

# Display access information
echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  Setup completed successfully! 🎉${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${BLUE}Access URLs:${NC}"
echo -e "  📱 Firefox (noVNC):  ${GREEN}http://localhost:5800${NC}"
echo -e "  🔍 Mitmweb:          ${GREEN}http://localhost:8081${NC} (password: mitm1234)"
echo ""
echo -e "${BLUE}Quick start:${NC}"
echo "  1. Open Firefox at http://localhost:5800"
echo "  2. Browse any website in the containerized Firefox"
echo "  3. View captured traffic at http://localhost:8081"
echo ""
echo -e "${YELLOW}Important:${NC} For HTTPS traffic capture, install the CA certificate."
echo "  See README.md for detailed instructions."
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo "  ./scripts/start.sh   - Start the scenario"
echo "  ./scripts/stop.sh    - Stop the scenario"
echo "  ./scripts/clean.sh   - Clean captured data"
echo ""
echo -e "${BLUE}View logs:${NC}"
echo "  docker-compose logs -f"
echo ""
