# 🏠 Personal Homelab Infrastructure

## Overview
This repository documents my homelab infrastructure, which serves as a practical demonstration of my DevOps skills and experience. The lab is built around a Beelink Mini PC Sei12 and a Intel NUC, both running Proxmox VE as the hypervisor in a cluster, hosting various virtual machines and containers for different services.

## Hardware Specifications

| Component | Specification |
|-----------|--------------|
| Node | pve1 |
| Model | Beelink Mini PC Sei12 |
| CPU | Intel Core i5-1235U |
| RAM | 16GB DDR4 |
| Storage | 500GB NVMe SSD |
| Network | 1GbE Ethernet |
| Hypervisor | Proxmox VE |
|-----------|--------------|
| Node | pve2 |
| Model | Intel OptiPlex 3080 Micro |
| CPU | Intel Core i5-10500 |
| RAM | 16GB DDR4 |
| Storage | 500GB NVMe SSD and 1TB Sata HD |
| Network | 1GbE Ethernet |
| Hypervisor | Proxmox VE |

## Infrastructure Components

### Virtual Machines and Containers

| Name | Type | IP Address | Description | Node |
|------|------|------------|-------------|------|
| Pihole | LXC Container | Internal | Network-wide DNS and Ad-blocking solution | pve1 |
| Traefik | LXC Container | 192.168.0.100 | Reverse proxy for service routing and SSL termination | pve1 |
| CasaOS | VM | 192.168.0.190 | Personal cloud platform for self-hosted applications | pve1 |
| K3s Master | VM | 192.168.0.230 | Kubernetes cluster master node running K3s and ArgoCD | pve1 |
| K3s Worker 1 | VM | 192.168.0.231 | Kubernetes cluster worker node | pve1 |
| K3s Worker 2 | VM | 192.168.0.232 | Kubernetes cluster worker node | pve1 |
| Boxofmanythings | VM | 192.168.0.80 | Development environment with tools and utilities | pve1 |
| NAS | VM | 192.168.0.50 | Storage for applications and backup | pve2 |

## Kubernetes Cluster Details
The K3s cluster provides a lightweight Kubernetes distribution with the following features:
- Simplified installation and maintenance
- ArgoCD for GitOps deployment
- Automated application deployment and management
- Built-in load balancing

## Installation Procedures

### Proxmox VE Setup
1. Downloaded Proxmox VE ISO
2. Created bootable USB
3. Installed on Beelink Mini PC
4. Configured network settings
5. Set up web interface access

### Proxmox Post Install
```bash
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/misc/post-pve-install.sh)"
```

### Container Deployments

#### Pihole
```bash
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/pihole.sh)"
```

#### Traefik (as Reverse Proxy)
```bash
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/traefik.sh)"
```

### Virtual Machine Deployments
WIP

#### K3s Cluster
WIP

## Monitoring and Maintenance
- Regular backup procedures
- Performance monitoring
- Security updates and patches

## Future Improvements
- [x] Implement cluster monitoring with Prometheus and Grafana
- [ ] Add automated backup solution
- [x] Implement infrastructure as code using Terraform
- [ ] Add network security monitoring

## Contact
gjma.marinho@gmail.com
