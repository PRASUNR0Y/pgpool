#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

echo "==> Starting Custom Pgpool-II Configuration..."

echo "==> Processing custom environment configuration..."

# Default configuration file paths
PGPOOL_CONF_FILE="/opt/bitnami/pgpool/conf/pgpool.conf"
PGPOOL_TEMPLATE_FILE="/opt/bitnami/pgpool/conf/pgpool.conf.template"

#ANCHOR: Function to process PGPOOL_BACKEND_NODES with optional weight support
process_backend_nodes() {
    if [[ -n "${PGPOOL_BACKEND_NODES:-}" ]]; then
        echo "==> Processing PGPOOL_BACKEND_NODES with weight support..."
        
        # Clear existing backend configuration
        IFS=',' read -ra NODES <<< "$PGPOOL_BACKEND_NODES"
        
        # Reset backend node configuration in template
        sed -i '/^backend_hostname[0-9]/d' "$PGPOOL_CONF_FILE"
        sed -i '/^backend_port[0-9]/d' "$PGPOOL_CONF_FILE"
        sed -i '/^backend_weight[0-9]/d' "$PGPOOL_CONF_FILE"
        sed -i '/^backend_data_directory[0-9]/d' "$PGPOOL_CONF_FILE"
        sed -i '/^backend_flag[0-9]/d' "$PGPOOL_CONF_FILE"
        
        for node in "${NODES[@]}"; do
            IFS=':' read -ra NODE_PARTS <<< "$node"
            
            if [[ ${#NODE_PARTS[@]} -lt 3 ]]; then
                echo "ERROR: Invalid PGPOOL_BACKEND_NODES format. Expected: index:hostname:port[:weight]"
                exit 1
            fi
            
            index=${NODE_PARTS[0]}
            hostname=${NODE_PARTS[1]}
            port=${NODE_PARTS[2]}
            weight=${NODE_PARTS[3]:-1}  # Default weight to 1 if not specified
            
            echo "==> Configuring backend node $index: $hostname:$port (weight: $weight)"
            
            # Add backend configuration to pgpool.conf
            cat >> "$PGPOOL_CONF_FILE" << EOF
                # Backend node $index configuration
backend_hostname$index = '$hostname'
backend_port$index = $port
backend_weight$index = $weight
backend_data_directory$index = '/data'
backend_flag$index = 'ALLOW_TO_FAILOVER'
EOF
        done
    fi
}

#ANCHOR: Function to generate pgpool.conf from template and environment variables
generate_pgpool_conf() {
    echo "==> Generating pgpool.conf from template..."
    
    # Use template if it exists, otherwise create from current config
    if [[ -f "$PGPOOL_TEMPLATE_FILE" ]]; then
        cp "$PGPOOL_TEMPLATE_FILE" "$PGPOOL_CONF_FILE"
    fi
    
    # Configure basic settings from environment variables
    if [[ -n "${PGPOOL_LISTEN_ADDRESSES:-}" ]]; then
        sed -i "s|listen_addresses = '.*'|listen_addresses = '${PGPOOL_LISTEN_ADDRESSES}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_PORT_NUMBER:-}" ]]; then
        sed -i "s|port = '.*'|port = '${PGPOOL_PORT_NUMBER}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_LOAD_BALANCE_MODE:-}" ]]; then
        sed -i "s|load_balance_mode = '.*'|load_balance_mode = '${PGPOOL_LOAD_BALANCE_MODE}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_SR_CHECK_PERIOD:-}" ]]; then
        sed -i "s|sr_check_period = '.*'|sr_check_period = '${PGPOOL_SR_CHECK_PERIOD}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_SR_CHECK_USER:-}" ]]; then
        sed -i "s|sr_check_user = '.*'|sr_check_user = '${PGPOOL_SR_CHECK_USER}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_SR_CHECK_PASSWORD:-}" ]]; then
        sed -i "s|sr_check_password = '.*'|sr_check_password = '${PGPOOL_SR_CHECK_PASSWORD}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_SR_CHECK_DATABASE:-}" ]]; then
        sed -i "s|sr_check_database = '.*'|sr_check_database = '${PGPOOL_SR_CHECK_DATABASE}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_HEALTH_CHECK_PERIOD:-}" ]]; then
        sed -i "s|health_check_period = '.*'|health_check_period = '${PGPOOL_HEALTH_CHECK_PERIOD}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_HEALTH_CHECK_TIMEOUT:-}" ]]; then
        sed -i "s|health_check_timeout = '.*'|health_check_timeout = '${PGPOOL_HEALTH_CHECK_TIMEOUT}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_HEALTH_CHECK_USER:-}" ]]; then
        sed -i "s|health_check_user = '.*'|health_check_user = '${PGPOOL_HEALTH_CHECK_USER}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_HEALTH_CHECK_PASSWORD:-}" ]]; then
        sed -i "s|health_check_password = '.*'|health_check_password = '${PGPOOL_HEALTH_CHECK_PASSWORD}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_HEALTH_CHECK_MAX_RETRIES:-}" ]]; then
        sed -i "s|health_check_max_retries = '.*'|health_check_max_retries = '${PGPOOL_HEALTH_CHECK_MAX_RETRIES}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_HEALTH_CHECK_RETRY_DELAY:-}" ]]; then
        sed -i "s|health_check_retry_delay = '.*'|health_check_retry_delay = '${PGPOOL_HEALTH_CHECK_RETRY_DELAY}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_CONNECT_TIMEOUT:-}" ]]; then
        sed -i "s|connect_timeout = '.*'|connect_timeout = '${PGPOOL_CONNECT_TIMEOUT}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_MAX_POOL:-}" ]]; then
        sed -i "s|max_pool = '.*'|max_pool = '${PGPOOL_MAX_POOL}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_CHILD_LIFE_TIME:-}" ]]; then
        sed -i "s|child_life_time = '.*'|child_life_time = '${PGPOOL_CHILD_LIFE_TIME}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_CONNECTION_LIFE_TIME:-}" ]]; then
        sed -i "s|connection_life_time = '.*'|connection_life_time = '${PGPOOL_CONNECTION_LIFE_TIME}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_CLIENT_IDLE_LIMIT:-}" ]]; then
        sed -i "s|client_idle_limit = '.*'|client_idle_limit = '${PGPOOL_CLIENT_IDLE_LIMIT}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_LOG_CONNECTIONS:-}" ]]; then
        sed -i "s|log_connections = '.*'|log_connections = '${PGPOOL_LOG_CONNECTIONS}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_LOG_HOSTNAME:-}" ]]; then
        sed -i "s|log_hostname = '.*'|log_hostname = '${PGPOOL_LOG_HOSTNAME}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_LOG_PER_NODE_STATEMENT:-}" ]]; then
        sed -i "s|log_per_node_statement = '.*'|log_per_node_statement = '${PGPOOL_LOG_PER_NODE_STATEMENT}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_FAILOVER_COMMAND:-}" ]]; then
        sed -i "s|failover_command = '.*'|failover_command = '${PGPOOL_FAILOVER_COMMAND}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_FAILOVER_ON_BACKEND_ERROR:-}" ]]; then
        sed -i "s|failover_on_backend_error = '.*'|failover_on_backend_error = '${PGPOOL_FAILOVER_ON_BACKEND_ERROR}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_FAILOVER_ON_BACKEND_SHUTDOWN:-}" ]]; then
        sed -i "s|failover_on_backend_shutdown = '.*'|failover_on_backend_shutdown = '${PGPOOL_FAILOVER_ON_BACKEND_SHUTDOWN}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_SEARCH_PRIMARY_NODE_TIMEOUT:-}" ]]; then
        sed -i "s|search_primary_node_timeout = '.*'|search_primary_node_timeout = '${PGPOOL_SEARCH_PRIMARY_NODE_TIMEOUT}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_DISABLE_LOAD_BALANCE_ON_WRITE:-}" ]]; then
        sed -i "s|disable_load_balance_on_write = '.*'|disable_load_balance_on_write = '${PGPOOL_DISABLE_LOAD_BALANCE_ON_WRITE}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    if [[ -n "${PGPOOL_STATEMENT_LEVEL_LOAD_BALANCE:-}" ]]; then
        sed -i "s|statement_level_load_balance = '.*'|statement_level_load_balance = '${PGPOOL_STATEMENT_LEVEL_LOAD_BALANCE}'|g" "$PGPOOL_CONF_FILE"
    fi
    
    # SSL/TLS Configuration
    if [[ -n "${PGPOOL_ENABLE_TLS:-}" ]] && [[ "${PGPOOL_ENABLE_TLS}" == "yes" ]]; then
        sed -i "s|#ssl = off|ssl = on|g" "$PGPOOL_CONF_FILE"
        
        if [[ -n "${PGPOOL_TLS_CERT_FILE:-}" ]]; then
            sed -i "s|#ssl_cert = '.*'|ssl_cert = '${PGPOOL_TLS_CERT_FILE}'|g" "$PGPOOL_CONF_FILE"
        fi
        
        if [[ -n "${PGPOOL_TLS_KEY_FILE:-}" ]]; then
            sed -i "s|#ssl_key = '.*'|ssl_key = '${PGPOOL_TLS_KEY_FILE}'|g" "$PGPOOL_CONF_FILE"
        fi
        
        if [[ -n "${PGPOOL_TLS_CA_FILE:-}" ]]; then
            sed -i "s|#ssl_ca_cert = '.*'|ssl_ca_cert = '${PGPOOL_TLS_CA_FILE}'|g" "$PGPOOL_CONF_FILE"
        fi
    fi
    
    # Process backend nodes with weight support
    process_backend_nodes
    
    echo "==> Configuration file generated successfully"
}

#ANCHOR: Function to handle custom configuration file
handle_custom_config() {
    if [[ -n "${PGPOOL_USER_CONF_FILE:-}" ]] && [[ -f "${PGPOOL_USER_CONF_FILE}" ]]; then
        echo "==> Appending custom configuration from ${PGPOOL_USER_CONF_FILE}..."
        cat "${PGPOOL_USER_CONF_FILE}" >> "$PGPOOL_CONF_FILE"
    fi
}

main() {
    echo "==> Starting custom pgpool configuration..."
    
    # Generate configuration from environment variables
    generate_pgpool_conf
    
    # Handle custom configuration file if provided
    handle_custom_config
    
    echo "==> Custom configuration completed"
    echo "==> Starting original Bitnami entrypoint..."
    
    # Execute the original Bitnami entrypoint
    exec "$@"
}

main "$@" 