# Multi-architecture support for x86_64 and ARM64 (Raspberry Pi 5)
FROM python:3.11-slim-bookworm

# Build arguments for architecture detection
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Environment variables for Python optimization
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONPATH=/app

# Add metadata
LABEL maintainer="Dune Weaver Project" \
      description="Dune Weaver Sand Table Controller" \
      version="1.0" \
      architecture="multi-arch"

WORKDIR /app

# Copy requirements first for better Docker layer caching
COPY requirements.txt ./

# Install system dependencies and Python packages
# Optimized for both x86_64 and ARM64 architectures
RUN apt-get update && apt-get install -y --no-install-recommends \
        # Build dependencies
        gcc \
        g++ \
        libjpeg-dev \
        zlib1g-dev \
        libffi-dev \
        git \
        # Runtime dependencies
        curl \
        # ARM64 specific optimizations for RPi5
        $([ "$TARGETPLATFORM" = "linux/arm64" ] && echo "libblas3 liblapack3") \
    && pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt \
    # Clean up build dependencies to reduce image size
    && apt-get purge -y gcc g++ \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /root/.cache

# Copy application code
COPY . .

# Create non-root user for security
RUN groupadd -r duneweaver && useradd -r -g duneweaver duneweaver \
    && chown -R duneweaver:duneweaver /app
USER duneweaver

# Expose port
EXPOSE 8080

# Use exec form for better signal handling
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080", "--workers", "1"]
