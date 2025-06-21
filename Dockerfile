# Multi-stage build for smaller final image
FROM python:3.11-slim-bookworm as builder

# Build arguments for architecture detection
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        libjpeg-dev \
        zlib1g-dev \
        libffi-dev \
        git \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt ./
RUN pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir --user -r requirements.txt

# Final stage - smaller runtime image
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

# Install only runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        # Runtime dependencies
        curl \
        libjpeg62-turbo \
        zlib1g \
        # ARM64 specific optimizations for RPi5
        $([ "$TARGETPLATFORM" = "linux/arm64" ] && echo "libblas3 liblapack3") \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Copy Python packages from builder stage
COPY --from=builder /root/.local /usr/local

# Create app directory
WORKDIR /app

# Copy application files
COPY app.py ./
COPY modules/ ./modules/
COPY templates/ ./templates/
COPY static/ ./static/
COPY firmware/ ./firmware/
COPY requirements.txt ./

# Copy all patterns (they're part of the application)
COPY patterns/ ./patterns/

# Make sure user's local packages are in PATH
ENV PATH=/usr/local/bin:$PATH

# Expose port
EXPOSE 8080

# Use exec form for better signal handling
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080", "--workers", "1"]
