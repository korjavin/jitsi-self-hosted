# Self-Hosted Jitsi Meet with Traefik & GitOps

A production-ready, self-hosted Jitsi Meet deployment using Docker Compose with Traefik reverse proxy and automated GitOps deployment via Portainer webhooks.

## 🚀 Features

- **Complete Jitsi Meet Stack**: All essential services (web, prosody, jicofo, jvb)
- **Traefik Integration**: Automatic SSL certificates and reverse proxy
- **GitOps Deployment**: Automated updates via GitHub Actions and Portainer webhooks
- **Production Ready**: Secure configuration with auto-generated passwords
- **Easy Maintenance**: Comprehensive monitoring and troubleshooting tools
- **Scalable Architecture**: External network integration for multi-service deployments

## 📋 Prerequisites

- Docker and Docker Compose installed
- Traefik running with SSL certificate resolver configured
- External network (`jitsi-network` by default) created and accessible to Traefik
- Domain name pointed to your server
- Portainer (optional, for GitOps deployment)

## 🏗️ Architecture

```
Internet
    ↓
Traefik (SSL termination, routing)
    ↓
Jitsi Web (Frontend)
    ↓
Prosody (XMPP Server) ← Jicofo (Conference Focus)
    ↓
JVB (Video Bridge)
```

### Services Overview

| Service | Purpose | Ports |
|---------|---------|--------|
| **web** | Frontend interface & nginx | Internal (via Traefik) |
| **prosody** | XMPP server for signaling | Internal |
| **jicofo** | Conference focus component | Internal |
| **jvb** | Video bridge for media | 10000/UDP, 4443/TCP |

## 🛠️ Quick Start

### 1. Clone and Configure

```bash
git clone <your-repo-url> jitsi-self-hosted
cd jitsi-self-hosted

# Copy environment template
cp .env.example .env
```

### 2. Configure Environment

Edit `.env` file with your settings:

```bash
# Required: Your domain configuration
JITSI_DOMAIN=yourdomain.com
DOCKER_HOST_ADDRESS=your.server.public.ip

# Network configuration (adjust if needed)
NETWORK_NAME=jitsi-network
NETWORK_EXTERNAL=true

# Optional: Customize ports
JVB_PORT=10000
JVB_TCP_PORT=4443
```

### 3. Generate Secure Passwords

```bash
./gen-passwords.sh
```

This automatically generates strong passwords for all internal services and updates your `.env` file.

### 4. Create External Network

```bash
# Create the network (if it doesn't exist)
docker network create jitsi-network

# Or connect to existing Traefik network
# docker network create --attachable traefik-network
# Then set NETWORK_NAME=traefik-network in .env
```

### 5. Deploy Services

```bash
# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f web
```

### 6. Verify Deployment

- Visit `https://jitsi.yourdomain.com`
- Create a test meeting room
- Check audio/video functionality

## 🔧 Configuration Details

### Traefik Labels

The web service includes automatic Traefik configuration:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.jitsi-web.rule=Host(`jitsi.${JITSI_DOMAIN}`)"
  - "traefik.http.routers.jitsi-web.entrypoints=websecure"
  - "traefik.http.routers.jitsi-web.tls.certresolver=myresolver"
```

### Network Requirements

**Firewall Ports:**
- `10000/UDP`: JVB media traffic (required for video/audio)
- `4443/TCP`: JVB TCP fallback
- `80/443`: Handled by Traefik (HTTP/HTTPS)

**Internal Communication:**
- All services communicate via Docker network
- Prosody acts as XMPP message broker
- No exposed ports except JVB media ports

### Security Features

- Auto-generated secure passwords for internal services
- Secrets stored in `.env` (git-ignored)
- Optional authentication system
- Guest access configurable
- SSL/TLS via Traefik certificate resolver

## 🚀 GitOps Deployment

### Automatic Updates

The repository includes GitHub Actions for automated deployment:

1. **Trigger**: Push to `main` branch or manual dispatch
2. **Action**: Calls Portainer webhook for stack redeployment
3. **Result**: Zero-downtime updates of your Jitsi stack

### Setup GitOps

1. **Add Repository Secret**: `PORTAINER_REDEPLOY_HOOK` with your Portainer webhook URL
2. **Configure Portainer Stack**: Point to this repository's `docker-compose.yml`
3. **Enable Auto-Updates**: Portainer will redeploy on webhook trigger

```bash
# Example webhook URL format:
https://your-portainer.com/api/stacks/webhooks/your-webhook-token
```

## 🔍 Management Commands

### Basic Operations

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart specific service
docker-compose restart web

# Update images
docker-compose pull && docker-compose up -d
```

### Monitoring

```bash
# Check service status
docker-compose ps

# View service logs
docker-compose logs -f web
docker-compose logs -f jvb
docker-compose logs -f prosody

# Monitor resource usage
docker stats

# Check network connectivity
docker-compose exec web ping prosody
```

### Maintenance

```bash
# Clean up unused containers/images
docker system prune

# Backup configuration
tar -czf jitsi-backup-$(date +%Y%m%d).tar.gz ~/.jitsi-meet-cfg

# Update passwords (regenerate)
./gen-passwords.sh
docker-compose restart
```

## 🛠️ Troubleshooting

### Common Issues

**Services won't start:**
```bash
# Check if passwords are generated
cat .env | grep -E "(SECRET|PASSWORD)"

# If empty, run password generation
./gen-passwords.sh
```

**No audio/video in meetings:**
```bash
# Check JVB connectivity
netstat -ulnp | grep 10000
docker-compose logs -f jvb

# Verify DOCKER_HOST_ADDRESS is your public IP
curl ifconfig.me
```

**Can't access web interface:**
```bash
# Check Traefik routing
docker-compose logs -f web

# Verify network connectivity
docker network inspect jitsi-network

# Check domain DNS resolution
nslookup jitsi.yourdomain.com
```

**SSL certificate issues:**
```bash
# Check Traefik certificate resolver
# Verify domain points to your server
# Ensure port 80/443 are accessible for ACME challenge
```

### Debug Mode

Enable detailed logging:

```bash
# Add to .env for verbose logging
LOG_LEVEL=debug

# Restart services
docker-compose restart
```

### Health Checks

```bash
# Service health status
docker-compose ps

# Test XMPP connectivity
docker-compose exec jicofo ping prosody

# Check JVB media ports
nc -u -v your.server.ip 10000
```

## ⚙️ Advanced Configuration

### Authentication Setup

Enable user authentication:

```env
# In .env file
ENABLE_AUTH=1
AUTH_TYPE=internal
```

Then create users via Prosody container:

```bash
docker-compose exec prosody prosodyctl --config /config/prosody.cfg.lua register user meet.jitsi password
```

### Recording Setup

Enable Jibri for meeting recording:

```env
# In .env file
ENABLE_RECORDING=1
```

Add Jibri service to docker-compose.yml (see Jitsi documentation).

### Load Balancing

Scale JVB for high traffic:

```bash
# Scale JVB instances
docker-compose up -d --scale jvb=3
```

Configure JVB_BREWERY_MUC for load balancing.

## 📊 Monitoring & Analytics

### Metrics Collection

Optional integrations:
- **Prometheus**: JVB metrics endpoint
- **Grafana**: Dashboard for meeting analytics
- **ELK Stack**: Centralized logging

### Performance Tuning

Key environment variables:
- `NGINX_WORKER_PROCESSES`: Adjust for CPU cores
- `JVB_STUN_SERVERS`: Configure STUN servers
- `RESOLUTION_MAX`: Limit video quality for bandwidth

## 🔐 Security Best Practices

1. **Regular Updates**: Keep images updated
2. **Network Segmentation**: Use dedicated Docker networks
3. **Access Control**: Implement authentication for production
4. **Monitoring**: Set up alerting for service failures
5. **Backup Strategy**: Regular configuration backups
6. **SSL/TLS**: Ensure certificates are valid and renewed

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request with detailed description

## 📚 Resources

- [Official Jitsi Meet Docker Documentation](https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-docker/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Portainer Documentation](https://docs.portainer.io/)

## 📄 License

This project is open source. Please check the LICENSE file for details.

---

**Need help?** Open an issue or check the troubleshooting section above.