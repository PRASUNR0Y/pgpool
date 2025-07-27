# Enhanced Pgpool-II Docker Image

[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![PostgreSQL](https://img.shields.io/badge/postgresql-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)

An enhanced Docker image based on `bitnami/pgpool:latest` that provides advanced configuration through environment variables, eliminating the need to mount configuration files for common use cases.

## 🚀 Features

- **🔧 Full Environment Variable Configuration**: Configure pgpool entirely through environment variables
- **⚖️ Enhanced Backend Node Support**: Support for load balancing weights in backend node configuration
- **🔄 Backward Compatibility**: Fully compatible with existing Bitnami pgpool environment variables
- **📦 Ready-to-Deploy**: No configuration files needed for standard deployments
- **🔐 SSL/TLS Support**: Complete SSL/TLS configuration through environment variables
- **🏥 Health Check Configuration**: Comprehensive health check settings
- **📊 Load Balancing**: Advanced load balancing configuration options

## 📋 Quick Start

### Basic Usage

```bash
docker run -d \
  --name pgpool \
  -p 5432:5432 \
  -e PGPOOL_BACKEND_NODES="0:postgres-master:5432:1,1:postgres-slave1:5432:2,2:postgres-slave2:5432:1" \
  -e PGPOOL_SR_CHECK_USER=postgres \
  -e PGPOOL_SR_CHECK_PASSWORD=password \
  -e PGPOOL_POSTGRES_USERNAME=postgres \
  -e PGPOOL_POSTGRES_PASSWORD=password \
  -e PGPOOL_ADMIN_USERNAME=admin \
  -e PGPOOL_ADMIN_PASSWORD=adminpass \
  royprasun/pgpool:latest
```

### With SSL/TLS

```bash
docker run -d \
  --name pgpool-ssl \
  -p 5432:5432 \
  -v /path/to/certs:/opt/bitnami/pgpool/certs \
  -e PGPOOL_BACKEND_NODES="0:postgres-master:5432,1:postgres-slave:5432" \
  -e PGPOOL_ENABLE_TLS=yes \
  -e PGPOOL_TLS_CERT_FILE=/opt/bitnami/pgpool/certs/postgres.crt \
  -e PGPOOL_TLS_KEY_FILE=/opt/bitnami/pgpool/certs/postgres.key \
  -e PGPOOL_SR_CHECK_USER=postgres \
  -e PGPOOL_SR_CHECK_PASSWORD=password \
  royprasun/pgpool:latest
```

## 🔧 Environment Variables

### Enhanced Backend Configuration

#### `PGPOOL_BACKEND_NODES` (Enhanced)

Configure backend PostgreSQL nodes with optional load balancing weights.

**Format**: `index:hostname:port[:weight][,index:hostname:port[:weight]]...`

**Examples**:
```bash
# Basic configuration (weight defaults to 1)
PGPOOL_BACKEND_NODES="0:postgres-master:5432,1:postgres-slave:5432"

# With custom weights (slave gets 2x more read traffic)
PGPOOL_BACKEND_NODES="0:postgres-master:5432:1,1:postgres-slave:5432:2"

# Multiple backends with different weights
PGPOOL_BACKEND_NODES="0:master:5432:1,1:slave1:5432:3,2:slave2:5432:2,3:slave3:5432:1"
```

### Connection Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `PGPOOL_LISTEN_ADDRESSES` | IP addresses to listen on | `*` |
| `PGPOOL_PORT_NUMBER` | Pgpool port number | `5432` |
| `PGPOOL_MAX_POOL` | Max connection pool size per child | `15` |
| `PGPOOL_CHILD_LIFE_TIME` | Child process lifetime (seconds) | `300` |
| `PGPOOL_CONNECTION_LIFE_TIME` | Backend connection lifetime (seconds) | `0` |
| `PGPOOL_CLIENT_IDLE_LIMIT` | Client idle timeout (seconds) | `0` |

### Streaming Replication

| Variable | Description | Default |
|----------|-------------|---------|
| `PGPOOL_SR_CHECK_PERIOD` | Streaming replication check interval | `30` |
| `PGPOOL_SR_CHECK_USER` | User for SR checks | - |
| `PGPOOL_SR_CHECK_PASSWORD` | Password for SR checks | - |
| `PGPOOL_SR_CHECK_DATABASE` | Database for SR checks | `postgres` |

### Health Check Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `PGPOOL_HEALTH_CHECK_PERIOD` | Health check interval (seconds) | `30` |
| `PGPOOL_HEALTH_CHECK_TIMEOUT` | Health check timeout (seconds) | `10` |
| `PGPOOL_HEALTH_CHECK_USER` | Health check user | - |
| `PGPOOL_HEALTH_CHECK_PASSWORD` | Health check password | - |
| `PGPOOL_HEALTH_CHECK_MAX_RETRIES` | Max retry attempts | `5` |
| `PGPOOL_HEALTH_CHECK_RETRY_DELAY` | Retry delay (seconds) | `5` |
| `PGPOOL_CONNECT_TIMEOUT` | Connection timeout (milliseconds) | `10000` |

### Load Balancing

| Variable | Description | Default |
|----------|-------------|---------|
| `PGPOOL_LOAD_BALANCE_MODE` | Enable load balancing | `on` |
| `PGPOOL_DISABLE_LOAD_BALANCE_ON_WRITE` | Load balance behavior after writes | `transaction` |
| `PGPOOL_STATEMENT_LEVEL_LOAD_BALANCE` | Statement-level load balancing | `off` |

### Failover Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `PGPOOL_FAILOVER_COMMAND` | Command to execute on failover | `echo ">>> Failover..."` |
| `PGPOOL_FAILOVER_ON_BACKEND_ERROR` | Failover on backend errors | `off` |
| `PGPOOL_FAILOVER_ON_BACKEND_SHUTDOWN` | Failover on backend shutdown | `on` |
| `PGPOOL_SEARCH_PRIMARY_NODE_TIMEOUT` | Primary search timeout | `0` |

### SSL/TLS Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `PGPOOL_ENABLE_TLS` | Enable SSL/TLS | `no` |
| `PGPOOL_TLS_CERT_FILE` | Path to certificate file | - |
| `PGPOOL_TLS_KEY_FILE` | Path to private key file | - |
| `PGPOOL_TLS_CA_FILE` | Path to CA certificate file | - |

### Logging

| Variable | Description | Default |
|----------|-------------|---------|
| `PGPOOL_LOG_CONNECTIONS` | Log client connections | `off` |
| `PGPOOL_LOG_HOSTNAME` | Log hostnames instead of IPs | `off` |
| `PGPOOL_LOG_PER_NODE_STATEMENT` | Log statements per node | `off` |

### Authentication

| Variable | Description | Default |
|----------|-------------|---------|
| `PGPOOL_POSTGRES_USERNAME` | PostgreSQL admin username | - |
| `PGPOOL_POSTGRES_PASSWORD` | PostgreSQL admin password | - |
| `PGPOOL_ADMIN_USERNAME` | Pgpool admin username | - |
| `PGPOOL_ADMIN_PASSWORD` | Pgpool admin password | - |

### Bitnami Compatibility

All existing Bitnami pgpool environment variables are supported:

- `PGPOOL_ENABLE_LDAP`
- `PGPOOL_ENABLE_LOAD_BALANCING`
- `PGPOOL_ENABLE_STATEMENT_LOAD_BALANCING`
- `PGPOOL_ENABLE_POOL_HBA`
- `PGPOOL_ENABLE_POOL_PASSWD`
- `PGPOOL_NUM_INIT_CHILDREN`
- `PGPOOL_RESERVED_CONNECTIONS`
- `PGPOOL_POSTGRES_CUSTOM_USERS`
- `PGPOOL_POSTGRES_CUSTOM_PASSWORDS`
- And many more...

## 📋 Docker Compose Examples

### Quick Start (Simple Setup)
For development, testing, or learning:

```bash
# Start simple setup with basic PostgreSQL instances
docker compose -f docker-compose-simple.yml up -d
```

### Production Setup (HA Cluster)
For production deployments with streaming replication:

```bash
# Start production HA cluster
docker compose -f docker-compose-production.yml up -d
```

### Simple Setup (docker-compose-simple.yml)
Perfect for development and testing. Uses basic PostgreSQL instances for quick validation of pgpool features.

### Production Setup (docker-compose-production.yml)
Full production-ready setup with PostgreSQL streaming replication using bitnami/postgresql:16 for high availability and reliability.

<!-- ## 🔍 Advanced Configuration

### Custom Configuration Files

You can still use custom configuration files if needed:

```bash
docker run -d \
  --name pgpool-custom-config \
  -v /path/to/custom.conf:/config/custom.conf \
  -e PGPOOL_USER_CONF_FILE=/config/custom.conf \
  -e PGPOOL_BACKEND_NODES="0:postgres:5432" \
  royprasun/pgpool:latest
```

### Init Scripts

Place initialization scripts in `/docker-entrypoint-initdb.d/`:

```bash
docker run -d \
  --name pgpool-with-init \
  -v /path/to/init-scripts:/docker-entrypoint-initdb.d \
  -e PGPOOL_BACKEND_NODES="0:postgres:5432" \
  royprasun/pgpool:latest
```

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pgpool
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pgpool
  template:
    metadata:
      labels:
        app: pgpool
    spec:
      containers:
      - name: pgpool
        image: royprasun/pgpool:latest
        ports:
        - containerPort: 5432
        env:
        - name: PGPOOL_BACKEND_NODES
          value: "0:postgres-master:5432:1,1:postgres-slave:5432:2"
        - name: PGPOOL_SR_CHECK_USER
          valueFrom:
            secretKeyRef:
              name: postgres-credentials
              key: username
        - name: PGPOOL_SR_CHECK_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-credentials
              key: password
        livenessProbe:
          exec:
            command:
            - /opt/bitnami/scripts/pgpool/healthcheck.sh
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - /opt/bitnami/scripts/pgpool/healthcheck.sh
          initialDelaySeconds: 5
          periodSeconds: 5
``` -->

## 🐛 Troubleshooting

### Common Issues

1. **Backend nodes not connecting**
   - Check the `PGPOOL_BACKEND_NODES` format
   - Verify network connectivity between pgpool and PostgreSQL instances
   - Check PostgreSQL credentials and permissions

2. **Health checks failing**
   - Verify `PGPOOL_HEALTH_CHECK_USER` has proper permissions
   - Check health check timeout values
   - Review PostgreSQL logs for connection issues

3. **Load balancing not working**
   - Ensure `PGPOOL_LOAD_BALANCE_MODE=on`
   - Check backend weights are properly configured
   - Verify streaming replication is working

### Checking Configuration

View the generated configuration:

```bash
# Access the container
docker exec -it pgpool-debug bash

# View the generated pgpool.conf
cat /opt/bitnami/pgpool/conf/pgpool.conf

# Check pgpool status
pgpool -f /opt/bitnami/pgpool/conf/pgpool.conf -F /opt/bitnami/pgpool/conf/pcp.conf -n
```

## 📊 Monitoring

### Health Checks

The image includes built-in health checks:

```bash
# Manual health check
docker exec pgpool /opt/bitnami/scripts/pgpool/healthcheck.sh
```

### Monitoring Endpoints

Connect to pgpool and run monitoring queries:

```sql
-- Show pool nodes status
SHOW POOL_NODES;

-- Show pool processes
SHOW POOL_PROCESSES;

-- Show pool version
SHOW POOL_VERSION;
```

## 🙏 Acknowledgments

- [Bitnami](https://bitnami.com/) for the excellent base pgpool image
- [PostgreSQL](https://www.postgresql.org/) community

## 📞 Support

- 📧 Email: prasunroy212@gmail.com

## 🚧 Roadmap & Maintenance Notes

This project is under active development and is being improved step-by-step. Key focus areas include:

- 🔐 Adding stronger security defaults and TLS hardening
- 📦 Regular patching and base image updates
- 🧪 Testing with multiple PostgreSQL setups and edge cases
- 📖 Improving documentation and usage examples

As I continue learning and applying best practices, expect improvements to roll out incrementally. Contributions and feedback are welcome!
