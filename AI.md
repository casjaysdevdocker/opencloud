# OpenCloud All-in-One Docker Container

## Overview

This is a comprehensive all-in-one Docker container for OpenCloud, a Go-based file sync and share platform (successor to ownCloud). The container includes all integrated services required for a full-featured deployment.

## Included Services

| Service | Port | Purpose |
|---------|------|---------|
| ClamAV | Socket | Antivirus scanning for uploaded files |
| Apache Tika | 9998 | Full-text search and document extraction |
| Radicale | 5232 | CalDAV/CardDAV for Calendar and Contacts |
| Collabora CODE | 9980 | Document collaboration (LibreOffice Online) |
| OpenCloud | 9200 | Core file sync/share platform |
| Nginx | 80 | Reverse proxy (external-facing) |

## Architecture

```
                    +------------------+
                    |      Nginx       |
                    |     (Port 80)    |
                    +--------+---------+
                             |
        +--------------------+--------------------+
        |          |         |         |          |
   +----v----+ +---v---+ +---v---+ +---v---+ +---v---+
   |OpenCloud| |Collabora| |Radicale| | Tika | |ClamAV |
   | (9200)  | | (9980)  | | (5232) | |(9998)| |(sock) |
   +---------+ +---------+ +--------+ +------+ +-------+
```

## Service Startup Order

Services start in this order to ensure dependencies are available:

1. **01-clamav.sh** - Antivirus daemon (other services depend on scanning)
2. **02-tika.sh** - Search indexing service
3. **03-radicale.sh** - Calendar/Contacts (CalDAV/CardDAV)
4. **04-collabora.sh** - Document collaboration
5. **05-opencloud.sh** - Main OpenCloud server
6. **06-nginx.sh** - Reverse proxy (last, needs all backends)

## Environment Variables

### Domain Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `DOMAIN` | `$HOSTNAME` | Primary domain for all services |
| `OC_DOMAIN` | `${DOMAIN:-$HOSTNAME}` | OpenCloud domain (for URL generation) |
| `COLLABORA_SERVER_NAME` | `collabora.${DOMAIN:-$HOSTNAME}` | Collabora server identifier for WOPI |

### URL Structure

Services are accessed via subdomains:
- `${DOMAIN}` → OpenCloud (main application)
- `collabora.${DOMAIN}` → Collabora CODE (document editing)
- `radicale.${DOMAIN}` → Radicale (CalDAV/CardDAV)

### OpenCloud Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `ADMIN_PASSWORD` | (auto-generated) | Admin user password |
| `OC_CONFIG_DIR` | `/config/opencloud` | Configuration directory |
| `OC_DATA_DIR` | `/data/opencloud` | Data storage directory |
| `OC_LOG_LEVEL` | `info` | Logging verbosity |
| `OC_INSECURE` | `true` | Allow insecure connections |
| `PROXY_HTTP_ADDR` | `0.0.0.0:9200` | HTTP listen address |
| `PROXY_TLS` | `false` | Disable TLS (behind reverse proxy) |

### Service Integration

| Variable | Default | Description |
|----------|---------|-------------|
| `COLLABORATION_WOPI_SRC` | `http://localhost:9980` | Collabora WOPI endpoint |
| `COLLABORATION_APP_ADDR` | `http://localhost:9980` | Collabora app address |
| `SEARCH_EXTRACTOR_TYPE` | `tika` | Search extraction engine |
| `SEARCH_EXTRACTOR_TIKA_TIKA_URL` | `http://localhost:9998` | Tika server URL |
| `ANTIVIRUS_SCANNER_TYPE` | `clamav` | Antivirus scanner type |
| `ANTIVIRUS_CLAMAV_SOCKET` | `/run/clamav/clamd.sock` | ClamAV socket path |

### User Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENCLOUD_USER` | `opencloud` | System user for OpenCloud |
| `OPENCLOUD_UID` | `1000` | User ID |
| `OPENCLOUD_GID` | `1000` | Group ID |

## Directory Structure

```
/config/
├── opencloud/          # OpenCloud configuration
├── radicale/           # Radicale CalDAV/CardDAV config
├── clamav/             # ClamAV configuration
├── collabora/          # Collabora configuration
└── nginx/              # Nginx reverse proxy config

/data/
├── opencloud/          # User files and data
├── radicale/           # Calendar/Contact collections
├── clamav/             # ClamAV data
├── collabora/          # Collabora data
└── logs/               # All service logs
    ├── opencloud/
    ├── radicale/
    ├── clamav/
    ├── tika/
    ├── collabora/
    └── nginx/
```

## Usage

### Basic Run

```bash
docker run -d \
  --name opencloud \
  -p 80:80 \
  -v opencloud-config:/config \
  -v opencloud-data:/data \
  casjaysdevdocker/opencloud:latest start
```

### With Custom Admin Password

```bash
docker run -d \
  --name opencloud \
  -p 80:80 \
  -e ADMIN_PASSWORD=mysecurepassword \
  -v opencloud-config:/config \
  -v opencloud-data:/data \
  casjaysdevdocker/opencloud:latest start
```

### Docker Compose

```yaml
version: '3.8'

services:
  opencloud:
    image: casjaysdevdocker/opencloud:latest
    container_name: opencloud
    command: start
    ports:
      - "80:80"
    environment:
      - ADMIN_PASSWORD=changeme
      - OC_LOG_LEVEL=info
    volumes:
      - opencloud-config:/config
      - opencloud-data:/data
    restart: unless-stopped

volumes:
  opencloud-config:
  opencloud-data:
```

## Nginx Proxy Configuration

The built-in Nginx proxies requests to all services:

- `/` → OpenCloud (port 9200)
- `/cool/` → Collabora WebSocket
- `/hosting/discovery` → Collabora discovery
- `/hosting/capabilities` → Collabora capabilities
- `/radicale/` → Radicale CalDAV/CardDAV

## Building

```bash
# Generate Dockerfile from template
gen-dockerfile

# Build for current platform
buildx

# Build for specific platform
buildx --platform linux/amd64
```

## Technical Notes

### Base Image

Uses Debian-based image (not Alpine) because Collabora CODE requires glibc.

### SSL/TLS

SSL is disabled by default (`PROXY_TLS=false`) as the container is designed to run behind a reverse proxy that handles TLS termination.

### ClamAV Virus Definitions

Virus definitions are downloaded during image build to reduce container startup time. Updates can be performed by restarting the container or running `freshclam` manually.

### Collabora User

Collabora CODE must run as the `cool` user (not root) for security reasons.

### Admin Password

If `ADMIN_PASSWORD` is not set, a random 16-character password is generated and saved to `/config/secure/auth/root/opencloud_admin_pass`.

## Troubleshooting

### Check Service Status

```bash
docker logs opencloud-test 2>&1 | grep -E "completed|Error|Starting"
```

### Access Container Shell

```bash
docker exec -it opencloud /bin/bash
```

### Check Running Processes

```bash
docker exec opencloud ps aux
```

### View Service Logs

```bash
# OpenCloud
docker exec opencloud cat /data/logs/opencloud/opencloud.log

# Nginx
docker exec opencloud cat /data/logs/nginx/access.log

# Collabora
docker exec opencloud cat /data/logs/collabora/collabora.log
```

## Files Structure

### Setup Scripts (`/root/docker/setup/`)

- `02-packages.sh` - Base package installation info (actual packages in ENV_PACKAGES)
- `03-files.sh` - Downloads OpenCloud binary, Tika JAR, ClamAV definitions
- `04-users.sh` - Creates opencloud user and group

### Init Scripts (`/usr/local/etc/docker/init.d/`)

- `01-clamav.sh` - ClamAV antivirus daemon
- `02-tika.sh` - Apache Tika search service
- `03-radicale.sh` - Radicale CalDAV/CardDAV
- `04-collabora.sh` - Collabora CODE
- `05-opencloud.sh` - OpenCloud server
- `06-nginx.sh` - Nginx reverse proxy

### Configuration Templates

- `/usr/local/share/template-files/config/` - Default configurations
- `/etc/radicale/config` - Radicale default config

## Package List

Packages installed via `ENV_PACKAGES`:

- Core: ca-certificates, curl, wget, bash, tini, gnupg, apt-transport-https, tzdata, procps, netcat-openbsd, nginx
- Java: default-jre-headless (for Tika)
- Python: python3, python3-pip, python3-venv (for Radicale)
- Antivirus: clamav, clamav-daemon, clamav-freshclam

Additional packages installed in `03-files.sh`:
- Collabora: coolwsd, code-brand (from Collabora repository)
- Radicale: installed via pip

## Version Information

- OpenCloud: Latest from GitHub releases (auto-detected)
- Apache Tika: 2.9.1
- Radicale: Latest from pip
- Collabora CODE: Latest from official repository

## Known Limitations

1. Single container deployment - not suitable for high-availability setups
2. ClamAV definitions are from build time - consider periodic updates
3. No built-in SSL - requires external reverse proxy for HTTPS
4. Memory intensive due to Java (Tika) and Collabora
5. Collabora CODE may require additional configuration for production use - check `/usr/bin/discovery.xml`

## Current Service Status

- **ClamAV**: Working
- **Apache Tika**: Working
- **Radicale**: Working
- **Collabora CODE**: Requires additional configuration (may fail on first run)
- **OpenCloud**: Dependent on Collabora for document editing features
- **Nginx**: Working (serves as reverse proxy)

## Related Links

- [OpenCloud GitHub](https://github.com/opencloud-eu/opencloud)
- [Collabora CODE](https://www.collaboraoffice.com/code/)
- [Apache Tika](https://tika.apache.org/)
- [Radicale](https://radicale.org/)
- [ClamAV](https://www.clamav.net/)
