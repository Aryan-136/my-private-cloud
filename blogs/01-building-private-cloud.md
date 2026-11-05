# Building My Own AWS-Inspired Private Cloud from Scratch
**By Aryan Pandya | Cloud & Infrastructure Engineer**  
*Published on blog.nexoraonesolution.com*

---

### Introduction
Public cloud providers like AWS, GCP, and Azure offer incredible power, but relying completely on them creates vendor lock-in, recurring operational expenses, and opacity regarding where your data actually lives.

As an engineer passionate about systems architecture, cloud security, and networking, I set out to answer one question:  
**Can you build a high-performance, resilient, and secure private cloud on bare-metal hardware that delivers AWS-equivalent core services?**

This case study documents the design, hardware, software-defined networking, container orchestration, and security mechanisms that power my private cloud platform.

---

### Architectural Objectives
1. **High Availability**: Services must sustain component restarts without manual intervention.
2. **True Network Segmentation**: Untrusted hardware and IoT devices must never cross into database or management tiers.
3. **Zero-Trust Access**: No exposed SSH or management ports on the public WAN.
4. **Reproducible Infrastructure**: All services defined as infrastructure-as-code (Docker Compose & Ansible).

---

### Hardware Layer
Rather than bloated, power-hungry rack servers, modern private cloud architectures can achieve extraordinary density using energy-efficient multi-core hardware:
- **Compute**: Intel 8-Core / 16-Thread processor with 64GB DDR4 ECC Memory.
- **Storage Tier 1 (Fast OS & Containers)**: 2x 1TB NVMe in ZFS Mirror.
- **Storage Tier 2 (Mass Data & Media)**: 4x 4TB NAS Drives in RAID-Z configuration.
- **Edge Interconnect**: Dual Gigabit Ethernet with VLAN 802.1Q trunking to managed smart switches.

---

### Software-Defined Networking & Edge Security
Instead of opening port 80/443 on a residential router and hoping for the best, the ingress pipeline implements defense-in-depth:
1. **Cloudflare Edge**: Absorbs Layer 3/4 volumetric DDoS attacks.
2. **WireGuard VPN**: Admin operations require cryptographic peer handshake before any internal IP is reachable.
3. **CrowdSec IPS**: Real-time behavioral log parser that detects port scans and credential brute-forcing, pushing automated IP drops directly to the Linux firewall (`nftables`).

---

### The Outcome
- **100% Data Sovereignty**: All telemetry, files, and backups stay under personal encryption keys.
- **99.9% Uptime**: Monitored continuously via Prometheus & Uptime Kuma.
- **Immediate Portability**: Any service can be migrated to AWS EC2 or an offsite datacenter in minutes via standardized Docker Compose definitions.

Read the full configuration and deploy your own from the [my-private-cloud repository](https://github.com/aryanpandya/my-private-cloud).
