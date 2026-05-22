# =========================================================================
# Init
# =========================================================================
# ARGs (can be passed to Build/Final) <BEGIN>
ARG SaM_REPO=${SaM_REPO:-ghcr.io/kristianstad/secure_and_minimal}
ARG ALPINE_VERSION=${ALPINE_VERSION:-3.23}
ARG APP_VERSION=${APP_VERSION:-4.22.8}
ARG IMAGETYPE="application"
ARG RUNDEPS="samba-server samba-common-tools libsmbclient"
ARG MAKEFILES="/var/lib/samba/private/secrets.tdb"
ARG MAKEDIRS="/run/samba"
ARG STARTUPEXECUTABLES="/usr/bin/smbpasswd /usr/sbin/nmbd /usr/sbin/smbd"
ARG REMOVEFILES="/etc/samba/*"
ARG GID0WRITABLES="/run/samba"
# ARGs (can be passed to Build/Final) </END>

# Generic template (don't edit) <BEGIN>
FROM ${CONTENTIMAGE1:-scratch} AS content1
FROM ${CONTENTIMAGE2:-scratch} AS content2
FROM ${CONTENTIMAGE3:-scratch} AS content3
FROM ${CONTENTIMAGE4:-scratch} AS content4
FROM ${CONTENTIMAGE5:-scratch} AS content5
FROM ${BASEIMAGE:-$SaM_REPO:base-${ALPINE_VERSION}} AS base
FROM ${INITIMAGE:-scratch} AS init
# Generic template (don't edit) </END>

# =========================================================================
# Build
# =========================================================================
# Generic template (don't edit) <BEGIN>
FROM ${BUILDIMAGE:-$SaM_REPO:build-${ALPINE_VERSION}} AS build
FROM ${BASEIMAGE:-$SaM_REPO:base-${ALPINE_VERSION}} AS final
COPY --from=build /finalfs /
# Generic template (don't edit) </END>

# =========================================================================
# Final
# =========================================================================
# Re-declare ARGs
ARG ALPINE_VERSION
ARG APP_VERSION

ARG CONFIG_DIR="/etc/samba"

ENV VAR_LINUX_USER="samba" \
    VAR_INIT_CAPS="cap_chown" \
    VAR_KEEP_CAPS="cap_net_bind_service,cap_net_admin,cap_net_raw" \
    VAR_CONFIG_FILE="$CONFIG_DIR/smb.conf" \
    VAR_DEBUGLEVEL="1" \
    VAR_SHARES_DIR="/shares" \
    VAR_SHARE_USERS="shareuser" \
    VAR_NMBD_PORT="4450" \
    VAR_SMBD_PORTS="4450" \
    VAR_FINAL_COMMAND="nmbd --daemon -p \$VAR_NMBD_PORT --debuglevel=\$VAR_DEBUGLEVEL --configfile=\$VAR_CONFIG_FILE --no-process-group && smbd -p \$VAR_SMBD_PORTS --foreground --debug-stdout --debuglevel=\$VAR_DEBUGLEVEL --configfile=\$VAR_CONFIG_FILE --no-process-group" \
    VAR_global_smb_passwd_file="$CONFIG_DIR/smbpasswd" \
    VAR_global_dns_proxy="no" \
    VAR_global_username_map="$CONFIG_DIR/usermap.txt" \
    VAR_global_log_file="/var/log/samba/log.%m" \
    VAR_global_max_log_size="0" \
    VAR_global_panic_action="killall nmbd smbd" \
    VAR_global_server_role="standalone" \
    VAR_global_map_to_guest="bad user" \
    VAR_global_load_printers="no" \
    VAR_global_printing="bsd" \
    VAR_global_printcap_name="/dev/null" \
    VAR_global_disable_spoolss="yes" \
    VAR_global_disable_netbios="yes" \
    VAR_global_smb_encrypt="desired"

# Generic template (don't edit) <BEGIN>
USER starter
ONBUILD USER root
# Generic template (don't edit) </END>

LABEL org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.title="samba" \
      org.opencontainers.image.description="Samba ${APP_VERSION} file share based on secure_and_minimal ${ALPINE_VERSION}"
