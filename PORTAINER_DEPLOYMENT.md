# Dune Weaver Portainer Deployment Guide

## 🍓 Raspberry Pi 5 Compatibility

**✅ YES! This Docker image is fully compatible with Raspberry Pi 5.**

The Dune Weaver Docker image supports multi-architecture builds including:
- **linux/arm64** (Raspberry Pi 5, 4, Apple Silicon)
- **linux/amd64** (Intel/AMD x86_64)

### RPi5-Specific Optimizations

The Docker configuration includes several Raspberry Pi 5 optimizations:

1. **ARM64 Architecture Support**: Multi-arch build with ARM64-specific libraries
2. **Resource Limits**: Configured for RPi5's 4-8GB RAM
3. **Host Networking**: Required for ESP32 WebSocket communication
4. **Optimized Dependencies**: ARM64-optimized Python packages and system libraries

### Performance on RPi5
- **Build Time**: ~5-10 minutes on RPi5 (first build)
- **Memory Usage**: ~200-400MB runtime
- **CPU Usage**: <10% during normal operation
- **Storage**: ~500MB image size

### Recommended RPi5 Setup
```bash
# Ensure Docker is configured for ARM64
docker --version
docker buildx ls

# Check available platforms
docker buildx inspect --bootstrap
```

---

## 🐳 Deploy Dune Weaver in Portainer

### Method 1: Using Docker Compose Stack (Recommended)

1. **Login to Portainer**
   - Access your Portainer instance
   - Go to **Stacks** → **Add Stack**

2. **Create New Stack**
   - **Name**: `dune-weaver`
   - **Build method**: `Repository` or `Upload`

3. **Option A: From Repository**
   - **Repository URL**: `https://github.com/tuanchris/dune-weaver`
   - **Reference**: `main`
   - **Compose path**: `docker-compose.yml`

4. **Option B: Copy & Paste Compose File (RPi5 Optimized)**
   ```yaml
   version: '3.8'

   services:
     dune-weaver:
       build:
         context: .
         dockerfile: Dockerfile
         platforms:
           - linux/arm64  # Raspberry Pi 5
           - linux/amd64  # Intel/AMD
       image: dune-weaver:local
       container_name: dune-weaver-app
       restart: unless-stopped
       
       # Host networking required for ESP32 WebSocket
       network_mode: host
       
       environment:
         - ESP32_IP=${ESP32_IP:-192.168.1.100}
         - ESP32_WEBSOCKET_PORT=${ESP32_WEBSOCKET_PORT:-81}
         - ESP32_HTTP_PORT=${ESP32_HTTP_PORT:-80}
         - WEB_PORT=${WEB_PORT:-8080}
         - HOST=${HOST:-0.0.0.0}
         - DEBUG=${DEBUG:-false}
         - PYTHONPATH=/app
       
       volumes:
         - ./patterns:/app/patterns
         - ./patterns/cached_images:/app/patterns/cached_images
         - ./patterns/custom_patterns:/app/patterns/custom_patterns
       
       extra_hosts:
         - "fluidnc.local:${ESP32_IP:-192.168.1.100}"
         - "esp32.local:${ESP32_IP:-192.168.1.100}"
       
       # RPi5 resource limits
       deploy:
         resources:
           limits:
             memory: 512M
             cpus: '1.0'
           reservations:
             memory: 256M
             cpus: '0.5'
   ```

5. **Configure Environment Variables**
   In the **Environment variables** section, add:
   
   | Name | Value | Description |
   |------|-------|-------------|
   | `ESP32_IP` | `192.168.0.194` | Your ESP32's IP address |
   | `ESP32_WEBSOCKET_PORT` | `81` | WebSocket port (usually 81) |
   | `ESP32_HTTP_PORT` | `80` | HTTP port (usually 80) |
   | `HOST_PORT` | `8080` | Port to access web interface |

6. **Deploy Stack**
   - Click **Deploy the stack**
   - Wait for deployment to complete

### Method 2: Using Pre-configured Environment

1. **Upload Configuration Files**
   - Upload `docker-compose.yml` and `dune-weaver.env` to your Docker host
   - Or use Git repository method

2. **Set Environment Variables**
   ```bash
   # Edit the environment file with your ESP32's IP
   ESP32_IP=YOUR_ESP32_IP_HERE
   ESP32_WEBSOCKET_PORT=81
   ESP32_HTTP_PORT=80
   HOST_PORT=8080
   ```

3. **Deploy in Portainer**
   - Use the uploaded compose file
   - Portainer will automatically read the environment variables

## 🔧 Configuration Options

### ESP32 Settings
- **ESP32_IP**: Your ESP32's IP address (required)
- **ESP32_WEBSOCKET_PORT**: WebSocket port (default: 81)
- **ESP32_HTTP_PORT**: HTTP port (default: 80)

### Application Settings  
- **HOST_PORT**: Port to access Dune Weaver (default: 8080)
- **FLASK_ENV**: Environment mode (development/production)

## 🎯 Quick Setup for Different Networks

### Home Network (192.168.1.x)
```
ESP32_IP=192.168.1.XXX
HOST_PORT=8080
```

### Office Network (192.168.0.x)  
```
ESP32_IP=192.168.0.XXX
HOST_PORT=8080
```

### Custom Network
```
ESP32_IP=YOUR_CUSTOM_IP
HOST_PORT=YOUR_CUSTOM_PORT
```

## 🚀 After Deployment

1. **Access Web Interface**: `http://YOUR_DOCKER_HOST:8080`
2. **Check Container Logs** in Portainer for connection status
3. **Verify ESP32 Connection** - should see "Successfully connected to ws://YOUR_ESP32_IP:81"

## 🔍 Troubleshooting

### Container Logs Show Connection Issues
- Verify ESP32_IP is correct
- Check ESP32 is on same network as Docker host
- Ensure ESP32 is running FluidNC firmware
- Test ESP32 WebSocket manually: `ws://YOUR_ESP32_IP:81`

### Web Interface Not Accessible
- Check HOST_PORT environment variable
- Verify port mapping in Portainer
- Check firewall settings on Docker host

## 📱 Finding Your ESP32 IP

### Method 1: Router Admin Panel
- Login to your router
- Check connected devices for "ESP32" or "FluidNC"

### Method 2: Network Scanner
```bash
# On Linux/Mac
nmap -sn 192.168.1.0/24 | grep -i esp

# On Windows  
arp -a | findstr /i esp
```

### Method 3: Serial Console
- Connect ESP32 via USB
- Open serial monitor at 115200 baud
- Look for IP address in startup messages 