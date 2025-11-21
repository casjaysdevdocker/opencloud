#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - -
# OpenCloud environment configuration
# - - - - - - - - - - - - - - - - - - - - - - - - -

# OpenCloud Core Settings
export OC_CONFIG_DIR="${OC_CONFIG_DIR:-/config/opencloud}"
export OC_DATA_DIR="${OC_DATA_DIR:-/data/opencloud}"
export OC_LOG_LEVEL="${OC_LOG_LEVEL:-info}"
export OC_LOG_PRETTY="${OC_LOG_PRETTY:-true}"

# Network Settings
# OC_URL: The publicly reachable URL for OpenCloud
export OC_URL="${OC_URL:-}"
# OC_DOMAIN: Domain name (used if OC_URL not set) - defaults to DOMAIN or HOSTNAME
export OC_DOMAIN="${OC_DOMAIN:-${DOMAIN:-$HOSTNAME}}"
# OC_INSECURE: Set to true when behind reverse proxy handling SSL
export OC_INSECURE="${OC_INSECURE:-true}"
# PROXY_HTTP_ADDR: Address and port for the proxy service
export PROXY_HTTP_ADDR="${PROXY_HTTP_ADDR:-0.0.0.0:9200}"
# PROXY_TLS: Disable TLS when running behind reverse proxy
export PROXY_TLS="${PROXY_TLS:-false}"

# Collabora server name (for WOPI) - uses subdomain
export COLLABORA_SERVER_NAME="${COLLABORA_SERVER_NAME:-collabora.${DOMAIN:-$HOSTNAME}}"

# Admin Settings
# ADMIN_PASSWORD: Admin password for first start (will be generated if not set)
export ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"

# Demo Users
# IDM_CREATE_DEMO_USERS: Create demo users (true/false)
export IDM_CREATE_DEMO_USERS="${IDM_CREATE_DEMO_USERS:-false}"

# Collaboration Service (Collabora) - Local instance
# COLLABORATION_WOPI_SRC: External URL for WOPI (Collabora uses this to reach OpenCloud)
export COLLABORATION_WOPI_SRC="${COLLABORATION_WOPI_SRC:-http://collabora.${DOMAIN:-$HOSTNAME}}"
# COLLABORATION_APP_ADDR: Internal Collabora address (for OpenCloud to reach Collabora)
export COLLABORATION_APP_ADDR="${COLLABORATION_APP_ADDR:-http://127.0.0.1:9980}"
# COLLABORATION_APP_INSECURE: Allow self-signed certificates
export COLLABORATION_APP_INSECURE="${COLLABORATION_APP_INSECURE:-true}"

# Search Service (Apache Tika) - Local instance
# SEARCH_EXTRACTOR_TYPE: basic or tika
export SEARCH_EXTRACTOR_TYPE="${SEARCH_EXTRACTOR_TYPE:-tika}"
# SEARCH_EXTRACTOR_TIKA_TIKA_URL: Tika server URL
export SEARCH_EXTRACTOR_TIKA_TIKA_URL="${SEARCH_EXTRACTOR_TIKA_TIKA_URL:-http://localhost:9998}"

# Antivirus Service (ClamAV) - Local instance
# ANTIVIRUS_SCANNER_TYPE: clamav or icap
export ANTIVIRUS_SCANNER_TYPE="${ANTIVIRUS_SCANNER_TYPE:-clamav}"
# ANTIVIRUS_CLAMAV_SOCKET: ClamAV socket path
export ANTIVIRUS_CLAMAV_SOCKET="${ANTIVIRUS_CLAMAV_SOCKET:-/run/clamav/clamd.sock}"

# Radicale CalDAV/CardDAV - Local instance
export RADICALE_PORT="${RADICALE_PORT:-5232}"

# Notifications (SMTP)
export NOTIFICATIONS_SMTP_HOST="${NOTIFICATIONS_SMTP_HOST:-}"
export NOTIFICATIONS_SMTP_PORT="${NOTIFICATIONS_SMTP_PORT:-25}"
export NOTIFICATIONS_SMTP_SENDER="${NOTIFICATIONS_SMTP_SENDER:-}"
export NOTIFICATIONS_SMTP_USERNAME="${NOTIFICATIONS_SMTP_USERNAME:-}"
export NOTIFICATIONS_SMTP_PASSWORD="${NOTIFICATIONS_SMTP_PASSWORD:-}"

# - - - - - - - - - - - - - - - - - - - - - - - - -
# ex: ts=2 sw=2 et filetype=sh
