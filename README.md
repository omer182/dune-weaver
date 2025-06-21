# Dune Weaver

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoffee.com/tuanchris)

![Dune Weaver Gif](./static/IMG_7404.gif)

Dune Weaver is a project for a mesmerizing, motorized sand table that draws intricate patterns in sand using a steel ball moved by a magnet. This project combines hardware and software, leveraging an Arduino for hardware control and a Python/Flask-based web interface for interaction. 

### **Check out the wiki [here](https://github.com/tuanchris/dune-weaver/wiki/Wiring) for more details.**

---

The Dune Weaver comes in two versions:

1. **Small Version (Mini Dune Weaver)**:
   - Uses two **28BYJ-48 DC 5V stepper motors**.
   - Controlled via **ULN2003 motor drivers**.
   - Powered by an **ESP32**.

2. **Larger Version (Dune Weaver)**:
   - Uses two **NEMA 17 or NEMA 23 stepper motors**.
   - Controlled via **TMC2209 or DRV8825 motor drivers**.
   - Powered by an **Arduino UNO with a CNC shield**.

Each version operates similarly but differs in power, precision, and construction cost.

The sand table consists of two main bases:
1. **Lower Base**: Houses all the electronic components, including motor drivers, and power connections.
2. **Upper Base**: Contains the sand and the marble, which is moved by a magnet beneath.

Both versions of the table use two stepper motors:

- **Radial Axis Motor**: Controls the in-and-out movement of the arm.
- **Angular Axis Motor**: Controls the rotational movement of the arm.

The small version uses **28BYJ-48 motors** driven by **ULN2003 drivers**, while the larger version uses **NEMA 17 or NEMA 23 motors** with **TMC2209 or DRV8825 drivers**.: Controls the in-and-out movement of the arm.
- **Angular Axis Motor**: Controls the rotational movement of the arm.

Each motor is connected to a motor driver that dictates step and direction. The motor drivers are, in turn, connected to the ESP32 board, which serves as the system's main controller. The entire table is powered by a single USB cable attached to the ESP32.

---

## 🍓 Raspberry Pi 5 + Portainer Deployment

Dune Weaver includes Docker support for easy deployment on Raspberry Pi 5 using Portainer. This setup allows you to run the web interface on your Pi while communicating with your ESP32-powered sand table over your local network.

### ⚡ Quick Start
1. **Find your ESP32 IP**: Check your router or use `nmap -sn 192.168.0.0/24`
2. **Deploy in Portainer**: Use the docker-compose.yml below
3. **Update ESP32_IP**: Change `192.168.0.194` to your ESP32's IP
4. **Access**: Open `http://your-rpi-ip:8383` in your browser

### Prerequisites
- Raspberry Pi 5 with Docker and Portainer installed
- ESP32 with FluidNC firmware configured for WiFi
- Both RPi5 and ESP32 connected to the same network

### Quick Deployment Steps

1. **Copy Files to Your RPi5**:
   ```bash
   # Clone the repository to your RPi5
   git clone https://github.com/omer182/dune-weaver.git
   cd dune-weaver
   ```

2. **Configure Your ESP32 IP**:
   Edit the `docker-compose.yml` file and change this line:
   ```yaml
   # Update ESP32 IP configuration
   - ESP32_IP=192.168.0.194  # Change to your ESP32's IP address
   ```

**Note**: The docker-compose.yml uses a pre-built image from GitHub Container Registry. This means faster deployment with no build time on your RPi5!

### 🏗️ **Automatic Image Building**

This repository includes GitHub Actions that automatically build and publish Docker images to GitHub Container Registry when you push code:

- **Multi-architecture support**: Builds for both ARM64 (RPi5) and AMD64 (Intel/AMD)
- **Automatic versioning**: Tags images with `latest` for main branch and version tags
- **Fast deployment**: No build time on your RPi5, just pull and run
- **Registry location**: `ghcr.io/omer182/dune-weaver:latest`

The workflow triggers on:
- Push to `main` branch → builds `latest` tag
- Git tags (e.g., `v1.0.0`) → builds version-specific tags
- Pull requests → builds test images

**Available image tags:**
- `ghcr.io/omer182/dune-weaver:latest` - Latest stable version (recommended)
- `ghcr.io/omer182/dune-weaver:v1.0.0` - Specific version tags

3. **Deploy via Portainer**:
   - Open Portainer web interface
   - Go to **Stacks** → **Add Stack**
   - Name: `dune-weaver`
   - Upload or paste the `docker-compose.yml` content
   - Add environment file or set environment variables
   - Deploy the stack

### Docker Compose Configuration

```yaml
version: '3.8'

services:
  dune-weaver:
    # Use pre-built multi-arch image from GitHub Container Registry
    image: ghcr.io/omer182/dune-weaver:latest
    container_name: dune-weaver-app
    restart: unless-stopped
    
    # Port mapping to avoid conflicts with other apps
    ports:
      - "8383:8080"  # Access via http://your-rpi-ip:8383
    
    # Platform specification for Raspberry Pi 5
    platform: linux/arm64
    
    environment:
      # ESP32 Configuration - CHANGE THIS FOR YOUR SETUP
      - ESP32_IP=192.168.0.194  # Change to your ESP32's IP address
```

### Network Configuration

#### Finding Your ESP32 IP Address
```bash
# Method 1: mDNS discovery (if ESP32 hostname is configured)
nslookup fluidnc.local

# Method 2: Network scan
nmap -sn 192.168.0.0/24 | grep -B2 -A2 "ESP32"

# Method 3: Check your router's DHCP client list
```

### 🔧 Troubleshooting

#### ESP32 Configuration Issues
If you see logs like `"Failed to get all machine parameters"` or `"Using default steps_per_mm values"`, this means:

1. **WebSocket connection is working** ✅
2. **ESP32 is not responding to GRBL configuration queries** ⚠️
3. **Application uses safe defaults** ✅ (prevents crashes)

**Common causes:**
- FluidNC firmware may not respond to `$$` commands like traditional GRBL
- ESP32 might need a restart after WiFi configuration
- Check ESP32 serial console for FluidNC startup messages

**Solutions:**
- Restart the ESP32 and check serial output
- Verify FluidNC configuration includes proper motor settings
- The application will work with default values, but calibration may be needed

#### Port Conflicts
- **Web Interface**: Access via `http://your-rpi-ip:8383` (not 8080)
- **ESP32 WebSocket**: Automatically connects to `ws://ESP32_IP:81`
- Change the port mapping in docker-compose.yml if needed: `"8484:8080"`

## Coordinate System
Unlike traditional CNC machines that use an **X-Y coordinate system**, the sand table operates on a **theta-rho (θ, ρ) coordinate system**:
- **Theta (θ)**: Represents the angular position of the arm, with **2π radians (360 degrees) for one full revolution**.
- **Rho (ρ)**: Represents the radial distance of the marble from the center, with **0 at the center and 1 at the perimeter**.

This system allows the table to create intricate radial designs that differ significantly from traditional Cartesian-based CNC machines.

---

## Homing and Position Tracking
Unlike conventional CNC machines, the sand table **does not have a limit switch** for homing. Instead, it uses a **crash-homing method**:
1. Upon power-on, the radial axis moves inward to its physical limit, ensuring the marble is positioned at the center.
2. The software then assumes this as the **home position (0,0 in polar coordinates)**.
3. The system continuously tracks all executed coordinates to maintain an accurate record of the marble's position.

---

## Mechanical Constraints and Software Adjustments
### Coupled Angular and Radial Motion
Due to the **hardware design choice**, the angular axis **does not move independently**. This means that when the angular motor moves one full revolution, the radial axis **also moves slightly**—either inwards or outwards, depending on the rotation direction.

To counteract this behavior, the software:
- Monitors how many revolutions the angular axis has moved.
- Applies an offset to the radial axis to compensate for unintended movements.

This correction ensures that the table accurately follows the intended path without accumulating errors over time.

---

Each pattern file consists of lines with theta and rho values (in degrees and normalized units, respectively), separated by a space. Comments start with #.

Example:

```
# Example pattern
0 0.5
90 0.7
180 0.5
270 0.7
```

## API Endpoints

The project exposes RESTful APIs for various actions. Here are some key endpoints:
 • List Serial Ports: /list_serial_ports (GET)
 • Connect to Serial: /connect (POST)
 • Upload Pattern: /upload_theta_rho (POST)
 • Run Pattern: /run_theta_rho (POST)
 • Stop Execution: /stop_execution (POST)

## Project Structure

```
dune-weaver/
├── app.py                    # FastAPI app and core logic
├── modules/                  # Core application modules
│   ├── connection/           # ESP32/Serial connection management
│   ├── core/                 # Pattern, playlist, and state management
│   ├── led/                  # LED controller (if applicable)
│   ├── mqtt/                 # MQTT communication
│   └── update/               # Update management
├── patterns/                 # Directory for .thr pattern files
│   ├── cached_images/        # Generated pattern preview images
│   └── custom_patterns/      # User-uploaded patterns
├── firmware/                 # FluidNC configuration files
│   ├── dune_weaver/          # Standard version configs  
│   ├── dune_weaver_mini/     # Mini version configs
│   └── dune_weaver_pro/      # Pro version configs
├── static/                   # Static files (CSS, JS, images)
├── templates/                # HTML templates for web interface
├── docker-compose.yml        # Docker Compose for Portainer deployment
├── docker-compose.dev.yml    # Development Docker Compose (local build)
├── Dockerfile                # Docker container definition
├── PORTAINER_DEPLOYMENT.md  # Detailed Portainer setup guide
├── README.md                # Project documentation
├── requirements.txt         # Python dependencies
└── steps_calibration/       # Arduino calibration tools
```

## 🔄 Recent Updates

### v1.1 (Latest)
- ✅ **Fixed division by zero crash** when ESP32 doesn't respond to configuration queries
- ✅ **Docker optimization** with multi-stage builds and ARM64 support
- ✅ **Simplified configuration** - only ESP32_IP required as environment variable
- ✅ **Port mapping support** to avoid conflicts with other applications
- ✅ **Automatic image builds** via GitHub Actions for faster deployment
- ✅ **Enhanced error handling** with default values for missing ESP32 parameters

### Key Improvements
- **Stability**: Patterns execute without crashes even when ESP32 configuration is incomplete
- **Deployment**: One-click Portainer deployment with pre-built images
- **Compatibility**: Works with FluidNC firmware and various ESP32 configurations
- **Performance**: Optimized Docker images (~200-300MB vs 473MB)

---

**Happy sand drawing with Dune Weaver! 🌟**

