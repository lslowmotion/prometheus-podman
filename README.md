# Prometheus Monitoring Stack

This project sets up a Prometheus monitoring stack using Podman with three key services:

- **Prometheus**: Metrics collection and storage
- **Node Exporter**: System and hardware metrics collection
- **NVIDIA GPU Exporter**: GPU metrics collection for NVIDIA GPUs

## Prerequisites

- Podman installed
- Docker-compatible container runtime
- NVIDIA drivers (for GPU monitoring)

## Services Overview

### 1. Prometheus

The core metrics collection service that scrapes targets and stores time-series data.

- **Port**: `9091`
- **Rootful**: Yes - runs as root Podman container

### 2. Node Exporter

Exports system metrics (CPU, memory, disk, network) in Prometheus format.

- **Port**: `9100`
- **Rootful**: Yes - runs as root Podman container with host filesystem access
- **Special Requirements**:
  - Mounts entire host filesystem (`/:/host:ro,rslave`) for metric collection
  - Requires elevated privileges for host filesystem access

### 3. NVIDIA GPU Exporter

Collects GPU metrics from NVIDIA GPUs using the NVIDIA Container Toolkit.

- **Port**: `9835`
- **Rootful**: Yes - runs as root Podman container
- **Special Requirements**:
  - Requires NVIDIA drivers installed
  - Needs device access to NVIDIA GPUs

## Running the Services

### Option 1: Using Podman Compose (Rootful)

```bash
# Run all services as rootful Podman containers
sudo podman-compose -f compose.yml up -d
```

### Option 2: Using Quadlets (Systemd)

This project includes Podman quadlet files for systemd-based deployment. Quadlets allow you to run containers as native systemd services.

#### Prerequisites for Quadlets

- Podman with quadlet support (Podman 4.7+)
- Systemd as the init system
- Root access for deployment

#### Deployment

Run the deployment script to install quadlets:

```bash
sudo ./deploy-quadlets.sh
```

The script will:
1. Copy quadlet files to `/etc/containers/systemd/`
2. Copy Prometheus configuration to `/etc/prometheus/`
3. Reload systemd daemon
4. Start all services

#### Manual Quadlet Management

After deployment, manage services using systemd commands:

```bash
# Start a service
sudo systemctl start prometheus

# Stop a service
sudo systemctl stop prometheus

# View service status
sudo systemctl status prometheus

# Enable service on boot
sudo systemctl enable prometheus
```

#### Available Quadlet Services

- `prometheus` - Prometheus metrics collection
- `node-exporter` - System metrics collection
- `nvidia-gpu-exporter` - NVIDIA GPU metrics collection

**Note**: Quadlets run with `Network=host`, so services are accessible directly on the host network.

## Accessing the Services

After starting the services, you can access them via:

- **Prometheus UI**: http://localhost:9091
- **Node Exporter Metrics**: http://localhost:9100/metrics
- **NVIDIA GPU Exporter Metrics**: http://localhost:9400/metrics

## Stopping the Services

```bash
# Stop all services
sudo podman-compose -f compose.yml down

# Stop individual service
sudo podman-compose -f compose.yml down node-exporter
```

## Removing Containers and Networks

```bash
# Remove all containers and networks
sudo podman-compose -f compose.yml down -v

# Remove individual container
sudo podman rm -f node-exporter
```

## Troubleshooting

### Node Exporter Issues

If node-exporter fails to collect metrics:

1. Verify it's running with `sudo podman-compose up -d`
2. Check logs: `podman logs node-exporter`
3. Ensure the host filesystem mount is working: `podman exec node-exporter ls /host`

### NVIDIA GPU Exporter Issues

If GPU metrics are unavailable:

1. Verify NVIDIA drivers are installed: `nvidia-smi`
2. Check device access: `podman inspect nvidia-gpu-exporter`
3. Ensure NVIDIA Container Toolkit is configured

### Quadlet Deployment Issues

If quadlet services fail to start:

1. Verify Podman quadlet support: `podman --version` (should be 4.7+)
2. Check quadlet files exist: `ls /etc/containers/systemd/*.container`
3. Check service status: `systemctl status prometheus --no-pager`
4. View container logs: `podman logs prometheus`
5. Ensure systemd is running: `systemctl is-system-running`

## Configuration

The Prometheus configuration is stored in [`prometheus.yml`](prometheus.yml). Modify this file to add additional scrape targets or adjust collection intervals.

## License

MIT