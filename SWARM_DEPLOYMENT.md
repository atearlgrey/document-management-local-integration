# Hybrid Deployment Guide (Swarm + Compose)

## Overview
This setup uses a hybrid approach:
1.  **Core Services (Docker Swarm)**: `postgres`, `keycloak`, `document-app`
2.  **Utility Services (Docker Compose)**: `keycloak-importer`, `flyway`

Both communicate over a shared **overlay** network named `document-management-net`.

## Prerequisites
- Docker Engine in Swarm Mode (`docker swarm init`)

## Deployment Steps

### 1. Create the Network and Deploy Core Services
The network is defined in `docker-stack.yml` as an `attachable` overlay network.

```bash
docker stack deploy -c docker-stack.yml document-management
```

Wait a few seconds for the network and services to initialize.

### 2. Run Utility Services via Docker Compose
Once the core services (especially Keycloak and Postgres) are starting up, run the utility services:

```bash
docker-compose up
```

These containers will automatically attach to the `document-management-net` network created by the stack.

## Why this setup?
- **Core Services** benefit from Swarm's orchestration, replicas, and health management.
- **Utility Services** (migrations/imports) are often run once or manually, which is easier with `docker-compose` logs and interactive mode.

## Troubleshooting

### "Network document-management-net not found"
If `docker-compose up` fails because the network is missing, ensure you have deployed the stack first:
```bash
docker network ls | grep document-management-net
```

### Communication Issues
The Compose containers can reach Swarm services using their service names (e.g., `http://keycloak:8080`) because they share the same overlay network.

### Logs
- Swarm logs: `docker service logs document-management_keycloak`
- Compose logs: `docker-compose logs -f`
