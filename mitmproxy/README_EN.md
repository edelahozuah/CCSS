# Mitmproxy Traffic Capture Scenario

This repository contains a complete ready-to-use scenario for capturing and analyzing HTTP/HTTPS traffic using **mitmproxy** with a pre-configured Firefox browser, all running in Docker containers.

## 📋 Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Accessing Interfaces](#accessing-interfaces)
- [CA Certificate Installation](#ca-certificate-installation)
- [Automation Scripts](#automation-scripts)
- [Custom Addons](#custom-addons)
- [Practical Exercises](#practical-exercises)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)

## ✨ Features

- 🔍 **HTTP/HTTPS traffic capture** with intuitive web interface (mitmweb)
- 🦊 **Pre-configured Firefox** with automatic proxy and browser access (noVNC)
- 📦 **No additional software installation** (everything runs in Docker containers)
- 💾 **Persistent** CA certificates and Firefox configuration
- 🔧 **Custom addons** for logging, credential detection, and traffic modification
- 📚 **Practical exercises** for guided learning
- 🚀 **Automation scripts** for ease of use

## 📦 Prerequisites

- **Docker** (version 20.10 or higher)
- **Docker Compose** (version 1.29 or higher)
- Available ports: `5800`, `8080`, `8081`

### Verify installation

```bash
docker --version
docker-compose --version
```

## 🚀 Installation

### Option 1: Automatic setup (recommended)

```bash
# Clone or download this repository
cd mitmproxy

# Run installation script
chmod +x scripts/*.sh
./scripts/setup.sh
```

### Option 2: Manual setup

```bash
# Start the containers
docker-compose up -d

# Verify containers are running
docker-compose ps
```

## 🎮 Usage

### Start the scenario

```bash
./scripts/start.sh
```

Or manually:

```bash
docker-compose up -d
```

### Stop the scenario

```bash
./scripts/stop.sh
```

Or manually:

```bash
docker-compose down
```

### Clean captured data

```bash
./scripts/clean.sh
```

## 🌐 Accessing Interfaces

Once containers are started, you can access:

| Service | URL | Description | Credentials |
|---------|-----|-------------|-------------|
| **Firefox (noVNC)** | http://localhost:5800 | Firefox browser with graphical interface | - |
| **Mitmweb** | http://localhost:8081 | Mitmproxy web interface for traffic analysis | Password: `mitm1234` |

### Typical workflow

1. **Access Firefox**: Open http://localhost:5800 in your browser
2. **Browse**: In the containerized Firefox, navigate to any website
3. **Analyze**: Open http://localhost:8081 to see captured traffic in real-time
4. **Export**: Use scripts or mitmweb interface to export flows

## 🔐 CA Certificate Installation

To intercept HTTPS traffic, you need to install mitmproxy's Certificate Authority (CA) certificate in Firefox.

### Automatic method (recommended)

The certificate is automatically downloaded when Firefox starts for the first time and is located at:
```
firefox-config/downloads/mitmproxy-ca-cert.pem
```

### Manual installation in Firefox

1. In the containerized Firefox (http://localhost:5800):
   - Go to `about:preferences#privacy`
   - Scroll to "Certificates" → Click "View Certificates"
   - "Authorities" tab
   - Click "Import"
   
2. Navigate to `/config/downloads/` and select `mitmproxy-ca-cert.pem`

3. Check the options:
   - ✅ Trust this CA to identify websites
   - ✅ Trust this CA to identify email users
   
4. Click "OK"

### Verification

Try accessing `https://example.com` in Firefox. If you can see HTTPS traffic in mitmweb, the certificate is correctly installed.

## 🔧 Automation Scripts

| Script | Description |
|--------|-------------|
| `scripts/setup.sh` | Complete installation and initial configuration |
| `scripts/start.sh` | Starts the scenario and displays access URLs |
| `scripts/stop.sh` | Cleanly stops the scenario |
| `scripts/clean.sh` | Cleans captured data and resets the scenario |
| `scripts/export-flows.sh` | Exports captured flows in different formats |

### Usage examples

```bash
# Export captured flows as HAR
./scripts/export-flows.sh --format har --output captures/

# View mitmproxy logs
docker-compose logs -f mitmproxy
```

## 🎯 Custom Addons

The scenario includes several mitmproxy addons for specific use cases:

### Traffic Logger (`addons/traffic_logger.py`)

Records all traffic in a structured format:

```bash
# Start mitmproxy with the addon
docker-compose exec mitmproxy mitmweb \
  --listen-port 8080 \
  --web-port 8081 \
  --web-host 0.0.0.0 \
  -s /home/mitmproxy/.mitmproxy/addons/traffic_logger.py
```

### Credential Detector (`addons/credential_detector.py`)

Detects and alerts on credentials sent in plaintext (useful for security exercises).

### Response Modifier (`addons/modify_response.py`)

Educational example of how to modify HTTP responses in real-time.

## 📚 Practical Exercises

The `ejercicios/` directory contains a series of guided exercises:

1. **Exercise 1**: Basic HTTP traffic capture
2. **Exercise 2**: HTTPS traffic analysis
3. **Exercise 3**: Plaintext credential detection
4. **Exercise 4**: Traffic modification with addons
5. **Exercise 5**: Flow export and analysis

See [ejercicios/README.md](ejercicios/README.md) for detailed instructions.

## 📁 Project Structure

```
mitmproxy/
├── docker-compose.yml          # Docker services configuration
├── .env.example               # Configurable environment variables
├── .gitignore                 # Files to ignore in git
├── README.md                  # Spanish documentation
├── README_EN.md              # This file
├── scripts/                   # Automation scripts
│   ├── setup.sh
│   ├── start.sh
│   ├── stop.sh
│   ├── clean.sh
│   └── export-flows.sh
├── addons/                    # Custom mitmproxy addons
│   ├── traffic_logger.py
│   ├── credential_detector.py
│   └── modify_response.py
├── ejercicios/               # Practical exercises
│   ├── README.md
│   └── soluciones/
├── mitmproxy-data/           # CA certificates (persistent)
├── firefox-config/           # Firefox configuration (persistent)
└── test-server/             # Test web server (optional)
    ├── index.html
    └── Dockerfile
```

## 🔧 Troubleshooting

### Containers won't start

```bash
# Check logs
docker-compose logs

# Verify ports are not in use
lsof -i :5800
lsof -i :8080
lsof -i :8081
```

### HTTPS traffic not being captured

- Verify the CA certificate is installed in Firefox (see previous section)
- Some sites with HSTS may require additional configuration

### Firefox is slow

Increase shared memory in `docker-compose.yml`:

```yaml
shm_size: "4g"  # Instead of 2g
```

### Cannot access mitmweb

- Verify container is running: `docker-compose ps`
- Default password is: `mitm1234`
- Check logs: `docker-compose logs mitmproxy`

### Completely reset the scenario

```bash
# Stop and remove containers, volumes and network
docker-compose down -v

# Clean data directories
./scripts/clean.sh

# Start from scratch
./scripts/setup.sh
```

## 🔒 Security Considerations

⚠️ **IMPORTANT**: This scenario is for educational and laboratory purposes.

- Do not use this setup in production environments
- The generated CA certificate should be kept private
- The mitmweb password is in `docker-compose.yml` for simplicity - change it in shared environments
- Do not capture third-party traffic without their explicit consent

## 📖 Additional Resources

- [Official mitmproxy documentation](https://docs.mitmproxy.org/)
- [Mitmproxy Addon API](https://docs.mitmproxy.org/stable/addons-overview/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)

## 📝 License

This material is for educational use in the Cybersecurity and Systems Compliance course.

---

**Questions or issues?** Check the [Troubleshooting](#troubleshooting) section or review container logs.
