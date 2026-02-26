#!/bin/bash

# Deployment script for Prometheus quadlets
# This script copies quadlet files to the systemd directory and enables them

set -e

QUADLETS_DIR="./quadlets"
SYSTEMD_DIR="/etc/containers/systemd"
PROMETHEUS_CONFIG_DIR="/etc/prometheus"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# Create systemd directory if it doesn't exist
mkdir -p "$SYSTEMD_DIR"

# Copy quadlet files
echo "Copying quadlet files to $SYSTEMD_DIR..."
cp -rf "$QUADLETS_DIR"/*.container "$SYSTEMD_DIR/"

# Create directory and put prometheus config
mkdir -p ${PROMETHEUS_CONFIG_DIR}
cp -rf prometheus.yml "$PROMETHEUS_CONFIG_DIR/"

# Reload systemd daemon
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Restart services
echo "Starting services..."
systemctl restart prometheus
systemctl restart node-exporter
systemctl restart nvidia-gpu-exporter

echo "Quadlets deployed successfully!"
echo ""
echo "Services status:"
systemctl status prometheus --no-pager
systemctl status node-exporter --no-pager
systemctl status nvidia-gpu-exporter --no-pager