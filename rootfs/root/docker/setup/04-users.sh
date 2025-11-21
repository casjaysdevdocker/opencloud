#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202511211036-git
# @@Author           :  CasjaysDev
# @@Contact          :  CasjaysDev <docker-admin@casjaysdev.pro>
# @@License          :  MIT
# @@Copyright        :  Copyright 2025 CasjaysDev
# @@Created          :  Fri Nov 21 10:36:03 AM EST 2025
# @@File             :  04-users.sh
# @@Description      :  script to run users
# @@Changelog        :  newScript
# @@TODO             :  Refactor code
# @@Other            :  N/A
# @@Resource         :  N/A
# @@Terminal App     :  yes
# @@sudo/root        :  yes
# @@Template         :  templates/dockerfiles/init_scripts/04-users.sh
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

# - - - - - - - - - - - - - - - - - - - - - - - - -
# Main script

# Create opencloud user and group
OPENCLOUD_USER="${OPENCLOUD_USER:-opencloud}"
OPENCLOUD_UID="${OPENCLOUD_UID:-1000}"
OPENCLOUD_GID="${OPENCLOUD_GID:-1000}"

echo "Creating opencloud user and group"

# Create group if it doesn't exist
if ! getent group "${OPENCLOUD_USER}" >/dev/null 2>&1; then
  groupadd --gid "${OPENCLOUD_GID}" "${OPENCLOUD_USER}" || exitCode=1
fi

# Create user if it doesn't exist
if ! getent passwd "${OPENCLOUD_USER}" >/dev/null 2>&1; then
  useradd --uid "${OPENCLOUD_UID}" --gid "${OPENCLOUD_USER}" --home-dir /data/opencloud --shell /sbin/nologin --no-create-home "${OPENCLOUD_USER}" || exitCode=1
fi

# Set ownership of OpenCloud directories
chown -R "${OPENCLOUD_USER}:${OPENCLOUD_USER}" /data/opencloud /config/opencloud /data/logs 2>/dev/null || true

# - - - - - - - - - - - - - - - - - - - - - - - - -
# Set the exit code
#exitCode=$?
# - - - - - - - - - - - - - - - - - - - - - - - - -
exit $exitCode
# - - - - - - - - - - - - - - - - - - - - - - - - -
# ex: ts=2 sw=2 et filetype=sh
# - - - - - - - - - - - - - - - - - - - - - - - - -
