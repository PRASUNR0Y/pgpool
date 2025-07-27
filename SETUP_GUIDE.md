# Setup Guide

## 🎯 **Which Docker Compose File Should You Use?**

This repository provides **two docker-compose setups** to meet different needs:

## 📋 **File Comparison**

| Feature | `docker-compose-simple.yml` | `docker-compose-production.yml` |
|---------|---------------------------|-------------------------------|
| **Purpose** | Development & Testing | Production & HA |
| **Startup Time** | ⚡ Fast (~30 seconds) | 🐌 Slower (~2-3 minutes) |
| **Complexity** | Simple | Complex |
| **PostgreSQL** | Basic instances | Streaming replication |
| **High Availability** | ❌ No | ✅ Yes |
| **Failover** | ❌ No | ✅ Yes |
| **Learning Curve** | Easy | Advanced |

## 🚀 **Quick Start (Recommended for First Time)**

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd pgpool

# 2. Build the pgpool image
docker build -t pgpool .

# 3. Start the simple setup
docker compose -f docker-compose-simple.yml up -d

# 4. Access pgAdmin (optional)
# Open http://localhost:8080
# Email: admin@example.com
# Password: adminpass
```

## 🏭 **Production Setup**

```bash
# 1. Build the pgpool image
docker build -t pgpool .

# 2. Start the production HA cluster
docker compose up -d
```

## 🔧 **What Each Setup Provides**

### **Simple Setup (`docker-compose-simple.yml`)**
- ✅ **3 PostgreSQL instances** (postgres1, postgres2, postgres3)
- ✅ **Custom pgpool** with enhanced backend configuration
- ✅ **Load balancing** with weights (postgres2 gets 2x traffic)
- ✅ **pgAdmin** for database management
- ✅ **Health checks** and monitoring
- ✅ **Perfect for testing** the custom pgpool features

### **Production Setup (`docker-compose.yml`)**
- ✅ **PostgreSQL streaming replication** with repmgr
- ✅ **High availability** cluster (master + 2 slaves)
- ✅ **Automatic failover** capabilities
- ✅ **Custom pgpool** with production configuration
- ✅ **pgAdmin** for database management
- ✅ **Production-ready** for real deployments

## 🎯 **When to Use Each**

### **Use `docker-compose-simple.yml` when:**
- 🧪 **Testing** the custom pgpool features
- 🚀 **Quick validation** of environment variable configuration
- 📚 **Learning** how pgpool works
- 🔧 **Development** and debugging
- ⚡ **Fast setup** needed

### **Use `docker-compose-production.yml` when:**
- 🏭 **Production deployment** needed
- 🔄 **High availability** required
- 📈 **Streaming replication** needed
- 🛡️ **Failover protection** required
- 🎯 **Real-world scenario** testing

## 🔍 **Testing Your Setup**

Both setups can be tested using the same commands:

```bash
# Check load balancing
PGPASSWORD=adminpassword psql -h localhost -p 5432 -U testuser -d testdb -c "SELECT inet_server_addr(), inet_server_port();"

# View logs
docker logs pgpool

# Check container status
docker compose ps
```
