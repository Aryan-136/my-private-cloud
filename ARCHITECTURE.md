# ðŸ›ï¸ Architecture Specifications: My Private Cloud

This document details the engineering specifications, network segregation, security boundaries, and disaster recovery strategies implemented in this private cloud deployment.

---

## 1. Network Subnet & VLAN Allocation

| VLAN ID | Subnet CIDR | Network Purpose | Firewall Rules |
| :--- | :--- | :--- | :--- |
| **VLAN 10** | `10.10.10.0/24` | Core Gateway & Reverse Proxy | Inbound 80/443 (from Cloudflare only), WireGuard UDP 51820 |
| **VLAN 20** | `10.10.20.0/24` | Application Services Tier | Internal only; reachable only through Reverse Proxy |
| **VLAN 30** | `10.10.30.0/24` | Observability & Telemetry | Accessible only by Admin VPN IPs; scrapes VLAN 10/20 |
| **VLAN 40** | `10.10.40.0/24` | IoT Hardware & Sensor Devices | Blocked from Internet; isolated to MQTT broker (Port 1883) |

---

## 2. Security Perimeter Specifications

### SSH Host Hardening
All Linux nodes enforce strict SSH configuration (`/etc/ssh/sshd_config`):
```text
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
```

### Edge Traffic Pipeline
1. **Cloudflare Edge**: Enforces TLS 1.3, DDoS mitigation, and Web Application Firewall (WAF) challenge rules.
2. **WireGuard / Cloudflare Tunnel**: Encrypted point-to-point tunnel to private gateway.
3. **Nginx Proxy Manager**: Handles SSL termination and sets strict security headers:
   - `Strict-Transport-Security: max-age=63072000; includeSubDomains; preload`
   - `X-Frame-Options: SAMEORIGIN`
   - `X-Content-Type-Options: nosniff`
   - `Referrer-Policy: strict-origin-when-cross-origin`
4. **CrowdSec L7 Bouncer**: Analyzes real-time access logs and drops malicious scrapers and brute-force actors at the firewall table (`nftables`).

---

## 3. Storage Hierarchy & Disaster Recovery

```text
Bare Metal Storage
  â””â”€â”€ ZFS zpool (2x NVMe Mirror / 2x HDD RAID-Z)
        â”œâ”€â”€ /zpool/data/nextcloud    (LZ4, recordsize=1M)
        â”œâ”€â”€ /zpool/data/databases    (LZ4, recordsize=16k)
        â”œâ”€â”€ /zpool/media/jellyfin    (recordsize=1M)
        â””â”€â”€ /zpool/backups/daily     (ZFS auto-snapshots)
```

- **RPO (Recovery Point Objective)**: Max 24 hours for daily backups; max 1 hour for database transactions (WAL archiving).
- **RTO (Recovery Time Objective)**: Sub-30 minutes for service restoration via Docker Compose and ZFS snapshot rollbacks.
