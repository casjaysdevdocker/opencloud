#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202511211036-git
# @@Author           :  CasjaysDev
# @@Contact          :  CasjaysDev <docker-admin@casjaysdev.pro>
# @@License          :  MIT
# @@Copyright        :  Copyright 2025 CasjaysDev
# @@Created          :  Fri Nov 21 10:36:03 AM EST 2025
# @@File             :  03-files.sh
# @@Description      :  script to run files
# @@Changelog        :  newScript
# @@TODO             :  Refactor code
# @@Other            :  N/A
# @@Resource         :  N/A
# @@Terminal App     :  yes
# @@sudo/root        :  yes
# @@Template         :  templates/dockerfiles/init_scripts/03-files.sh
# - - - - - - - - - - - - - - - - - - - - - - - - -
# shellcheck disable=SC1001,SC1003,SC2001,SC2003,SC2016,SC2031,SC2120,SC2155,SC2199,SC2317,SC2329
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
set -o pipefail
[ "$DEBUGGER" = "on" ] && echo "Enabling debugging" && set -x$DEBUGGER_OPTIONS
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Set env variables
exitCode=0

# - - - - - - - - - - - - - - - - - - - - - - - - -
# Predefined actions
if [ -d "/tmp/bin" ]; then
  mkdir -p "/usr/local/bin"
  for bin in "/tmp/bin"/*; do
    name="$(basename -- "$bin")"
    echo "Installing $name to /usr/local/bin/$name"
    copy "$bin" "/usr/local/bin/$name"
    chmod -f +x "/usr/local/bin/$name"
  done
fi
unset bin
if [ -d "/tmp/var" ]; then
  for var in "/tmp/var"/*; do
    name="$(basename -- "$var")"
    echo "Installing $var to /var/$name"
    if [ -d "$var" ]; then
      mkdir -p "/var/$name"
      copy "$var/." "/var/$name/"
    else
      copy "$var" "/var/$name"
    fi
  done
fi
unset var
if [ -d "/tmp/etc" ]; then
  for config in "/tmp/etc"/*; do
    name="$(basename -- "$config")"
    echo "Installing $config to /etc/$name"
    if [ -d "$config" ]; then
      mkdir -p "/etc/$name"
      copy "$config/." "/etc/$name/"
      mkdir -p "/usr/local/share/template-files/config/$name"
      copy "$config/." "/usr/local/share/template-files/config/$name/"
    else
      copy "$config" "/etc/$name"
      copy "$config" "/usr/local/share/template-files/config/$name"
    fi
  done
fi
unset config
if [ -d "/tmp/data" ]; then
  for data in "/tmp/data"/*; do
    name="$(basename -- "$data")"
    echo "Installing $data to /usr/local/share/template-files/data"
    if [ -d "$data" ]; then
      mkdir -p "/usr/local/share/template-files/data/$name"
      copy "$data/." "/usr/local/share/template-files/data/$name/"
    else
      copy "$data" "/usr/local/share/template-files/data/$name"
    fi
  done
fi
unset data
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Main script

# Install Collabora CODE
echo "Adding Collabora CODE repository"
mkdir -p /etc/apt/keyrings
curl -fsSL https://collaboraoffice.com/downloads/gpg/collaboraonline-release-keyring.gpg -o /etc/apt/keyrings/collaboraonline-release-keyring.gpg

cat > /etc/apt/sources.list.d/collaboraonline.sources << 'EOF'
Types: deb
URIs: https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-deb
Suites: ./
Signed-By: /etc/apt/keyrings/collaboraonline-release-keyring.gpg
EOF

pkmgr update
echo "Installing Collabora CODE"
pkmgr install coolwsd code-brand || exitCode=1

# Install Radicale via pip
echo "Installing Radicale"
pip3 install --break-system-packages radicale || exitCode=1

# Detect architecture
case "$(uname -m)" in
  x86_64)  ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  armv7l)  ARCH="arm" ;;
  *)       echo "Unsupported architecture: $(uname -m)" && exit 1 ;;
esac

# Get latest version from GitHub API if not specified
if [ -z "${OPENCLOUD_VERSION}" ]; then
  echo "Fetching latest OpenCloud version..."
  OPENCLOUD_VERSION=$(curl -fsSL https://api.github.com/repos/opencloud-eu/opencloud/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  if [ -z "${OPENCLOUD_VERSION}" ]; then
    echo "Failed to fetch latest version, falling back to 3.7.0"
    OPENCLOUD_VERSION="3.7.0"
  fi
fi

OPENCLOUD_BASE_URL="https://github.com/opencloud-eu/opencloud/releases/download/v${OPENCLOUD_VERSION}"
OPENCLOUD_BINARY="opencloud-${OPENCLOUD_VERSION}-linux-${ARCH}"
OPENCLOUD_URL="${OPENCLOUD_BASE_URL}/${OPENCLOUD_BINARY}"

echo "Downloading OpenCloud ${OPENCLOUD_VERSION} for ${ARCH}"

# Download OpenCloud binary
curl -fsSL -o /usr/local/bin/opencloud "${OPENCLOUD_URL}" || {
  echo "Failed to download OpenCloud binary"
  exitCode=1
}

# Make binary executable
chmod +x /usr/local/bin/opencloud

# Create required directories
mkdir -p /data/opencloud /config/opencloud /data/logs

# Verify installation
if [ -x /usr/local/bin/opencloud ]; then
  echo "OpenCloud installed successfully"
  /usr/local/bin/opencloud version || true
else
  echo "OpenCloud installation failed"
  exitCode=1
fi

# Download Apache Tika Server
TIKA_VERSION="${TIKA_VERSION:-2.9.1}"
TIKA_URL="https://archive.apache.org/dist/tika/${TIKA_VERSION}/tika-server-standard-${TIKA_VERSION}.jar"
echo "Downloading Apache Tika ${TIKA_VERSION}"
mkdir -p /opt/tika
curl -fsSL -o /opt/tika/tika-server.jar "${TIKA_URL}" || {
  echo "Failed to download Apache Tika"
  exitCode=1
}

# Create directories for all services
mkdir -p /data/opencloud /config/opencloud /data/logs
mkdir -p /data/radicale /config/radicale
mkdir -p /data/collabora /config/collabora
mkdir -p /data/clamav /config/clamav
mkdir -p /run/clamav

# Download ClamAV virus definitions
echo "Downloading ClamAV virus definitions"
mkdir -p /var/lib/clamav
freshclam --quiet || {
  echo "Failed to download ClamAV definitions"
  exitCode=1
}

# - - - - - - - - - - - - - - - - - - - - - - - - -
# Set the exit code
#exitCode=$?
# - - - - - - - - - - - - - - - - - - - - - - - - -
exit $exitCode
# - - - - - - - - - - - - - - - - - - - - - - - - -
# ex: ts=2 sw=2 et filetype=sh
# - - - - - - - - - - - - - - - - - - - - - - - - -
