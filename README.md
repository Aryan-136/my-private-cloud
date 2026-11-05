# â˜ï¸ My Private Cloud: AWS-Inspired Self-Hosted Infrastructure

[![Architecture](https://img.shields.io/badge/Architecture-Multi--Tier%20Hybrid%20Cloud-blue?style=flat-square&logo=diagramsdotnet)](./ARCHITECTURE.md)
[![Security](https://img.shields.io/badge/Security-Zero%20Trust%20%2B%20CrowdSec-red?style=flat-square&logo=shield)](./docs/security-architecture.md)
[![Disaster Recovery](https://img.shields.io/badge/Backup-3--2--1%20Strategy-success?style=flat-square&logo=files)](./docs/disaster-recovery.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

A production-grade, self-hosted private cloud infrastructure modeled after AWS cloud architecture. Built with enterprise principles: hardware virtualization, software-defined networking, isolated VLANs, zero-trust security perimeters, automated observability, and multi-tier disaster recovery.

---

## ðŸ›ï¸ High-Level System Architecture

```mermaid
flowchart TB
    subgraph Internet ["ðŸŒ External & Remote Access"]
        Users["Remote Engineers & Devices"]
        CF["Cloudflare Zero Trust Access & CDN"]
    end

    subgraph EdgePerimeter ["ðŸ›¡ï¸ Edge Security & Gateway (VLAN 10)"]
        WG["WireGuard VPN Gateway (UDP 51820)"]
        NPM["Nginx Reverse Proxy & Automated SSL"]
        CrowdSec["CrowdSec Intrusion Prevention System"]
    end

    subgraph ServiceMesh ["ðŸš€ Compute & Container Workloads (VLAN 20)"]
        direction TB
        CloudStorage["Private Cloud Storage (Nextcloud + Redis + Postgres)"]
        Media["Media Streaming Platform (Jellyfin + GPU Transcode)"]
        Email["Enterprise Mail Infrastructure (Mailcow / Postfix / Dovecot)"]
        IoT["IoT & Smart Device Controller (Home Assistant + Mosquitto)"]
        SecVault["Secrets Vault (Vaultwarden Bitwarden-compatible)"]
    end

    subgraph ManagementOps ["ðŸ“Š Telemetry, Monitoring & Management (VLAN 30)"]
        Prometheus["Prometheus Metrics Collector"]
        Grafana["Grafana Real-time Observability"]
        Kuma["Uptime Kuma Health Check & SLA Alerts"]
        Portainer["Portainer Container Fleet Orchestrator"]
    end

    subgraph StorageTier ["ðŸ’¾ Resilient Storage & Disaster Recovery (ZFS)"]
        ZFS["ZFS Zpool (RAID-Z / Mirror Arrays)"]
        Restic["Automated Daily Encrypted Snapshots (Restic / Offsite)"]
    end

    Users --> CF --> WG --> NPM
    NPM --> CrowdSec
    NPM --> ServiceMesh
    ManagementOps -.->|Scrapes Metrics| ServiceMesh
    ManagementOps -.->|Scrapes Node Metrics| EdgePerimeter
    ServiceMesh -->|NFS / Bind Mounts| StorageTier
    StorageTier --> Restic
```

---

## ðŸ“‚ Repository Layout

```text
my-private-cloud/
â”œâ”€â”€ README.md                          # Central project overview
â”œâ”€â”€ ARCHITECTURE.md                    # In-depth architectural blueprint & specifications
â”œâ”€â”€ ROADMAP.md                         # Milestones and future roadmap
â”œâ”€â”€ docs/
â”‚   â”œâ”€â”€ infrastructure-overview.md     # Server hardware inventory, Proxmox virtualization
â”‚   â”œâ”€â”€ network-topology.md            # Subnets, VLAN configuration, routing tables
â”‚   â”œâ”€â”€ security-architecture.md       # Zero trust, SSH hardening, SSL, CrowdSec
â”‚   â””â”€â”€ disaster-recovery.md           # 3-2-1 backup policies, RPO/RTO metrics, test recovery
â”œâ”€â”€ deployment/
â”‚   â”œâ”€â”€ docker-compose.yml             # Unified services orchestration
â”‚   â””â”€â”€ .env.example                   # Environment variable template
â”œâ”€â”€ automation/
â”‚   â””â”€â”€ backup.sh                      # Automated backup script with Slack/Telegram webhook
â”œâ”€â”€ monitoring/
â”‚   â””â”€â”€ prometheus.yml                 # Prometheus scrape targets configuration
â””â”€â”€ blogs/
    â”œâ”€â”€ 01-building-private-cloud.md   # Comprehensive architectural case study
    â””â”€â”€ 02-zero-trust-security.md      # Security hardening deep dive
```

---

## âš™ï¸ Core Infrastructure Tiers

### 1. Compute & Virtualization
- **Hypervisor**: Proxmox VE (Kernel-based Virtual Machine / KVM) on multi-core bare-metal hardware.
- **Containerization**: Docker Engine & Docker Compose with resource pinning (CPU & RAM limits) and isolated overlay networks.
- **Node Management**: Remote SSH access with Ed25519 key authentication only (Password authentication permanently disabled).

### 2. Software-Defined Networking
- **VLAN 10 (Management & Gateway)**: Proxmox GUI, router, edge reverse proxy.
- **VLAN 20 (Production Workloads)**: Isolated application containers with strict egress filtering.
- **VLAN 30 (Monitoring & Telemetry)**: Prometheus, Grafana, cAdvisor.
- **VLAN 40 (IoT & Hardware)**: Untrusted IoT sensor segment, blocked from internet access.

### 3. Edge Security & Zero Trust
- **No Raw Port Forwarding**: Direct HTTP/SSH ports are never exposed to the public Internet.
- **Inbound Access**: Secured via WireGuard VPN tunnels and Cloudflare Tunnel with multi-factor authentication (MFA).
- **Automated IPS**: CrowdSec parses reverse proxy logs in real time, auto-banning malicious IPs across global threat intelligence feeds.

### 4. Storage & Disaster Recovery (3-2-1 Policy)
- **Primary Storage**: ZFS pool with LZ4 compression, automated hourly snapshots, and scrub routines.
- **Backup Rule**: 
  - **3** copies of data (Live ZFS, Local NAS Backup, Encrypted Offsite).
  - **2** different storage media types.
  - **1** offsite encrypted replica via Restic.

---

## ðŸš€ Quick Start Deployment

1. **Clone the repository**:
   ```bash
   git clone https://github.com/aryanpandya/my-private-cloud.git
   cd my-private-cloud
   ```

2. **Configure Environment Variables**:
   ```bash
   cp deployment/.env.example deployment/.env
   # Edit .env with your domain names and credentials
   ```

3. **Launch the Core Gateway Stack**:
   ```bash
   cd deployment
   docker compose up -d
   ```

4. **Verify Health**:
   Check Grafana dashboards at `http://<your-host-ip>:3000` or Uptime Kuma at `http://<your-host-ip>:3001`.

---

## ðŸ‘¨â€ðŸ’» Author & Maintainer
**Aryan Pandya**  
- Email: [aryan@nexoraonesolution.com](mailto:aryan@nexoraonesolution.com)  
- LinkedIn: [linkedin.com/in/aryanpandya](https://linkedin.com/in/aryanpandya)  
- Engineering Blog: [blog.nexoraonesolution.com](https://blog.nexoraonesolution.com)
