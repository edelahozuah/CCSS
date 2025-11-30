"""
Analyze HAR (HTTP Archive) files exported from mitmproxy

Usage:
    python3 analyze_har.py <har_file>

Example:
    python3 analyze_har.py ../captures/flows_20231125.har
"""

import json
import sys
from collections import Counter, defaultdict
from datetime import datetime


def analyze_har(har_file):
    """Analyze a HAR file and print statistics"""
    
    try:
        with open(har_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"❌ Error: File '{har_file}' not found")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"❌ Error: Invalid JSON in '{har_file}'")
        sys.exit(1)
    
    entries = data.get('log', {}).get('entries', [])
    
    if not entries:
        print("⚠️  No entries found in HAR file")
        return
    
    # Statistics
    total_requests = len(entries)
    methods = Counter()
    status_codes = Counter()
    domains = Counter()
    content_types = Counter()
    total_size = 0
    total_time = 0
    
    # Analyze each entry
    for entry in entries:
        request = entry.get('request', {})
        response = entry.get('response', {})
        
        # Method
        methods[request.get('method', 'UNKNOWN')] += 1
        
        # Status code
        status = response.get('status', 0)
        status_codes[status] += 1
        
        # Domain
        url = request.get('url', '')
        try:
            from urllib.parse import urlparse
            domain = urlparse(url).netloc
            domains[domain] += 1
        except:
            pass
        
        # Content type
        for header in response.get('headers', []):
            if header.get('name', '').lower() == 'content-type':
                ct = header.get('value', '').split(';')[0]
                content_types[ct] += 1
                break
        
        # Size
        total_size += response.get('bodySize', 0)
        
        # Time
        total_time += entry.get('time', 0)
    
    # Print report
    print("=" * 70)
    print("📊 HAR FILE ANALYSIS REPORT")
    print("=" * 70)
    print()
    
    print(f"📄 File: {har_file}")
    print(f"📅 Created: {data.get('log', {}).get('creator', {}).get('name', 'Unknown')}")
    print()
    
    print(f"📈 Total Requests: {total_requests}")
    print(f"💾 Total Size: {format_bytes(total_size)}")
    print(f"⏱️  Total Time: {total_time:.2f} ms")
    if total_requests > 0:
        print(f"⚡ Avg Time per Request: {total_time/total_requests:.2f} ms")
    print()
    
    print("🔹 HTTP Methods:")
    for method, count in methods.most_common():
        percentage = (count / total_requests) * 100
        print(f"  {method:8} {count:4} ({percentage:5.1f}%)")
    print()
    
    print("🔹 Status Codes:")
    for status, count in sorted(status_codes.items()):
        percentage = (count / total_requests) * 100
        emoji = get_status_emoji(status)
        print(f"  {emoji} {status:3} {count:4} ({percentage:5.1f}%)")
    print()
    
    print("🔹 Top 10 Domains:")
    for domain, count in domains.most_common(10):
        percentage = (count / total_requests) * 100
        print(f"  {domain:40} {count:4} ({percentage:5.1f}%)")
    print()
    
    print("🔹 Content Types:")
    for ct, count in content_types.most_common(10):
        percentage = (count / total_requests) * 100
        print(f"  {ct:40} {count:4} ({percentage:5.1f}%)")
    print()
    
    print("=" * 70)


def format_bytes(bytes_num):
    """Format bytes to human readable format"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if bytes_num < 1024.0:
            return f"{bytes_num:.2f} {unit}"
        bytes_num /= 1024.0
    return f"{bytes_num:.2f} TB"


def get_status_emoji(status):
    """Get emoji for status code"""
    if 200 <= status < 300:
        return "✅"
    elif 300 <= status < 400:
        return "🔄"
    elif 400 <= status < 500:
        return "⚠️ "
    elif 500 <= status < 600:
        return "❌"
    else:
        return "❓"


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 analyze_har.py <har_file>")
        sys.exit(1)
    
    analyze_har(sys.argv[1])
