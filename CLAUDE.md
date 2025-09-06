# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GitOps-based self-hosted Jitsi deployment project using Portainer and Docker Compose. The repository is currently in initial setup phase.

## Project Status

The repository is currently minimal with only a readme.md file. Key components that may be added include:
- Docker Compose configurations for Jitsi services
- Portainer stack definitions
- GitOps deployment configurations
- Environment configuration files
- SSL/TLS certificate management
- Network and firewall configurations

## Expected Technology Stack

- **Deployment**: Docker Compose
- **Management**: Portainer
- **Video Conferencing**: Jitsi Meet
- **Approach**: GitOps methodology

## Development Notes

Since this is a deployment/infrastructure repository rather than a traditional software project:
- Focus on configuration management and infrastructure as code
- Ensure all secrets are externalized and never committed
- Test configurations in isolated environments before production deployment
- Document network requirements and port configurations
- Consider backup and disaster recovery procedures for persistent data