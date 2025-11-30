#!/bin/bash
# Export flows script for mitmproxy traffic capture scenario
# Exports captured flows to various formats

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Default values
FORMAT="har"
OUTPUT_DIR="./captures"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --format FORMAT    Export format: har, json, or mitm (default: har)"
            echo "  --output DIR       Output directory (default: ./captures)"
            echo "  --help            Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --format har --output ./exports"
            echo "  $0 --format json"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo -e "${BLUE}Exporting mitmproxy flows${NC}"
echo -e "Format: ${GREEN}$FORMAT${NC}"
echo -e "Output: ${GREEN}$OUTPUT_DIR${NC}"
echo ""

# Check if mitmproxy container is running
if ! docker-compose ps | grep mitmproxy | grep -q Up; then
    echo -e "${YELLOW}Warning: mitmproxy container is not running${NC}"
    echo "Starting container..."
    docker-compose up -d mitmproxy
    sleep 2
fi

# Export based on format
case $FORMAT in
    har)
        OUTPUT_FILE="$OUTPUT_DIR/flows_${TIMESTAMP}.har"
        echo -e "${BLUE}Exporting to HAR format...${NC}"
        
        # Use mitmdump to convert flows to HAR
        docker-compose exec -T mitmproxy sh -c \
            "if [ -f /home/mitmproxy/.mitmproxy/flows ]; then \
                mitmdump -r /home/mitmproxy/.mitmproxy/flows --set hardump='$OUTPUT_FILE'; \
            else \
                echo 'No flows file found'; \
                exit 1; \
            fi" || {
            echo -e "${YELLOW}No existing flows found. Flows will be saved on next capture.${NC}"
            exit 0
        }
        ;;
    json)
        OUTPUT_FILE="$OUTPUT_DIR/flows_${TIMESTAMP}.json"
        echo -e "${BLUE}Exporting to JSON format...${NC}"
        
        docker-compose exec -T mitmproxy sh -c \
            "if [ -f /home/mitmproxy/.mitmproxy/flows ]; then \
                cat /home/mitmproxy/.mitmproxy/flows; \
            else \
                echo 'No flows file found'; \
                exit 1; \
            fi" > "$OUTPUT_FILE" || {
            echo -e "${YELLOW}No existing flows found.${NC}"
            exit 0
        }
        ;;
    mitm)
        OUTPUT_FILE="$OUTPUT_DIR/flows_${TIMESTAMP}.mitm"
        echo -e "${BLUE}Exporting to mitmproxy format...${NC}"
        
        docker-compose cp mitmproxy:/home/mitmproxy/.mitmproxy/flows "$OUTPUT_FILE" 2>/dev/null || {
            echo -e "${YELLOW}No flows file found. Capture some traffic first.${NC}"
            exit 0
        }
        ;;
    *)
        echo -e "${RED}Error: Unknown format '$FORMAT'${NC}"
        echo "Supported formats: har, json, mitm"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✓ Flows exported successfully${NC}"
echo -e "File: ${GREEN}$OUTPUT_FILE${NC}"
echo ""
