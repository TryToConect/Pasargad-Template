#!/usr/bin/env bash
# Installs index.html as your PasarGuard panel's custom subscription page.
#
# What this script DOES automatically (safe, reversible):
#   - copies index.html into PasarGuard's custom templates directory
#   - backs up any file it would overwrite there first
#   - offers to restart the panel service once you confirm
#
# What this script NEVER does automatically:
#   - it will not blindly rewrite your live .env. If the two required
#     keys are missing it offers to append them (append-only); if they
#     already exist with different values, it just shows you what to
#     change and leaves the file alone. Editing a running panel's config
#     unattended is exactly the kind of thing that should ask first.
#
# Usage:
#   sudo bash install.sh                       # interactive, uses defaults below
#   sudo bash install.sh --yes                  # same, skips confirmations
#   sudo bash install.sh --source ./index.html --target-dir /var/lib/pasarguard/templates --env-file /opt/pasarguard/.env
#
set -euo pipefail

SOURCE_FILE="$(dirname "$0")/index.html"
TARGET_DIR="/var/lib/pasarguard/templates"
ENV_FILE="/opt/pasarguard/.env"
ASSUME_YES=0

while [ $# -gt 0 ]; do
  case "$1" in
    --source) SOURCE_FILE="$2"; shift 2 ;;
    --target-dir) TARGET_DIR="$2"; shift 2 ;;
    --env-file) ENV_FILE="$2"; shift 2 ;;
    --yes|-y) ASSUME_YES=1; shift ;;
    --help|-h)
      sed -n '2,25p' "$0"
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [ -t 1 ]; then
  C_OK="\033[32m"; C_WARN="\033[33m"; C_ERR="\033[31m"; C_RESET="\033[0m"
else
  C_OK=""; C_WARN=""; C_ERR=""; C_RESET=""
fi
log_ok()   { printf "%b[OK]%b   %s\n" "$C_OK" "$C_RESET" "$1"; }
log_warn() { printf "%b[WARN]%b %s\n" "$C_WARN" "$C_RESET" "$1"; }
log_err()  { printf "%b[ERROR]%b %s\n" "$C_ERR" "$C_RESET" "$1"; }
confirm() {
  [ "$ASSUME_YES" = "1" ] && return 0
  read -r -p "$1 [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

if [ "$(id -u)" != "0" ]; then
  log_err "Run this with sudo — it needs to write under $TARGET_DIR and (optionally) restart the panel."
  exit 1
fi

if [ ! -f "$SOURCE_FILE" ]; then
  log_err "Can't find $SOURCE_FILE — pass --source /path/to/index.html"
  exit 1
fi

DEST="$TARGET_DIR/subscription/index.html"
mkdir -p "$(dirname "$DEST")"

if [ -f "$DEST" ]; then
  BACKUP="$DEST.bak.$(date +%Y%m%d%H%M%S)"
  cp "$DEST" "$BACKUP"
  log_warn "An existing template was found and backed up to $BACKUP"
fi

cp "$SOURCE_FILE" "$DEST"
log_ok "Copied to $DEST"

# ---- .env: append-only, never overwrite an existing value ----
NEEDED_DIR_LINE="CUSTOM_TEMPLATES_DIRECTORY=\"$TARGET_DIR/\""
NEEDED_TPL_LINE="SUBSCRIPTION_PAGE_TEMPLATE=\"subscription/index.html\""

if [ ! -f "$ENV_FILE" ]; then
  log_warn "$ENV_FILE not found. Add these two lines to your panel's .env yourself:"
  echo "    $NEEDED_DIR_LINE"
  echo "    $NEEDED_TPL_LINE"
else
  if grep -q '^CUSTOM_TEMPLATES_DIRECTORY=' "$ENV_FILE"; then
    CURRENT=$(grep '^CUSTOM_TEMPLATES_DIRECTORY=' "$ENV_FILE" | head -1)
    if [ "$CURRENT" != "$NEEDED_DIR_LINE" ]; then
      log_warn "CUSTOM_TEMPLATES_DIRECTORY is already set to something else in $ENV_FILE:"
      echo "    current: $CURRENT"
      echo "    needed:  $NEEDED_DIR_LINE"
      echo "    Update it by hand if that directory doesn't already match $TARGET_DIR/"
    else
      log_ok "CUSTOM_TEMPLATES_DIRECTORY already set correctly"
    fi
  else
    if confirm "Append CUSTOM_TEMPLATES_DIRECTORY to $ENV_FILE?"; then
      cp "$ENV_FILE" "$ENV_FILE.bak.$(date +%Y%m%d%H%M%S)"
      echo "$NEEDED_DIR_LINE" >> "$ENV_FILE"
      log_ok "Appended CUSTOM_TEMPLATES_DIRECTORY"
    else
      log_warn "Skipped. Add this line yourself: $NEEDED_DIR_LINE"
    fi
  fi

  if grep -q '^SUBSCRIPTION_PAGE_TEMPLATE=' "$ENV_FILE"; then
    CURRENT=$(grep '^SUBSCRIPTION_PAGE_TEMPLATE=' "$ENV_FILE" | head -1)
    if [ "$CURRENT" != "$NEEDED_TPL_LINE" ]; then
      log_warn "SUBSCRIPTION_PAGE_TEMPLATE is already set to something else in $ENV_FILE:"
      echo "    current: $CURRENT"
      echo "    needed:  $NEEDED_TPL_LINE"
    else
      log_ok "SUBSCRIPTION_PAGE_TEMPLATE already set correctly"
    fi
  else
    if confirm "Append SUBSCRIPTION_PAGE_TEMPLATE to $ENV_FILE?"; then
      cp "$ENV_FILE" "$ENV_FILE.bak.$(date +%Y%m%d%H%M%S)"
      echo "$NEEDED_TPL_LINE" >> "$ENV_FILE"
      log_ok "Appended SUBSCRIPTION_PAGE_TEMPLATE"
    else
      log_warn "Skipped. Add this line yourself: $NEEDED_TPL_LINE"
    fi
  fi
fi

echo
if confirm "Restart the PasarGuard panel now to apply changes?"; then
  if command -v pasarguard >/dev/null 2>&1; then
    pasarguard restart
    log_ok "Panel restarted"
  else
    log_warn "Couldn't find the 'pasarguard' CLI on PATH — restart the panel yourself (e.g. your usual docker/systemd command)."
  fi
else
  log_warn "Not restarted. Your changes won't take effect until you restart the panel."
fi

echo
log_ok "Done. Open any subscription link in a browser to see the new template."
