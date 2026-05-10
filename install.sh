#!/bin/bash

# Glyph SDDM Theme Installer
# Author: xCaptaiN09

set -e

THEME_NAME="glyph"
THEME_DIR="/usr/share/sddm/themes/${THEME_NAME}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}==>${NC} Installing ${GREEN}${THEME_NAME}${NC} SDDM theme..."

# 1. NIXOS CHECK
if [ -f /etc/NIXOS ]; then
    echo -e "${RED}Warning:${NC} NixOS detected. Manual file copying will not work on NixOS."
    echo -e "Please use the declarative method in your ${BLUE}configuration.nix${NC}."
    echo -e "See the ${GREEN}README.md${NC} for the NixOS configuration snippet."
    exit 1
fi

# 2. ROOT CHECK
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error:${NC} Please run as root (use sudo)."
    exit 1
fi

# 3. INSTALLATION
BACKUP_DIR=$(mktemp -d)

if [ -d "${THEME_DIR}" ]; then
    echo -e "${BLUE}==>${NC} Backing up user configurations..."
    # Backup custom config and assets if they exist
    [ -f "${THEME_DIR}/theme.conf" ] && cp "${THEME_DIR}/theme.conf" "${BACKUP_DIR}/"
    [ -f "${THEME_DIR}/assets/images/background.jpg" ] && cp "${THEME_DIR}/assets/images/background.jpg" "${BACKUP_DIR}/"
    [ -f "${THEME_DIR}/assets/images/avatar.jpg" ] && cp "${THEME_DIR}/assets/images/avatar.jpg" "${BACKUP_DIR}/"

    echo -e "${BLUE}==>${NC} Cleaning old version..."
    rm -rf "${THEME_DIR}"
fi

echo -e "${BLUE}==>${NC} Installing Glyph to ${THEME_DIR}..."
mkdir -p "${THEME_DIR}"
cp -r assets components Main.qml metadata.desktop theme.conf LICENSE "${THEME_DIR}/"
chmod -R 755 "${THEME_DIR}"

# Restore user configurations if they were backed up
if [ -f "${BACKUP_DIR}/theme.conf" ]; then
    echo -e "${BLUE}==>${NC} Restoring user configurations..."
    cp "${BACKUP_DIR}/theme.conf" "${THEME_DIR}/theme.conf"
    [ -f "${BACKUP_DIR}/background.jpg" ] && cp "${BACKUP_DIR}/background.jpg" "${THEME_DIR}/assets/images/background.jpg"
    [ -f "${BACKUP_DIR}/avatar.jpg" ] && cp "${BACKUP_DIR}/avatar.jpg" "${THEME_DIR}/assets/images/avatar.jpg"
fi

rm -rf "${BACKUP_DIR}"

echo -e "${GREEN}Done!${NC} Theme installed to ${THEME_DIR}"
echo -e ""

# 4. CONFIGURATION
read -p "Would you like to set Glyph as your active SDDM theme? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}==>${NC} Applying theme configuration..."
    mkdir -p /etc/sddm.conf.d
    echo -e "[Theme]\nCurrent=${THEME_NAME}" | tee /etc/sddm.conf.d/theme.conf > /dev/null
    echo -e "${GREEN}Theme applied successfully!${NC}"
else
    echo -e "To apply the theme manually:"
    echo -e "1. Edit ${BLUE}/etc/sddm.conf${NC} or ${BLUE}/etc/sddm.conf.d/theme.conf${NC}"
    echo -e "2. Set ${GREEN}Current=${THEME_NAME}${NC} under the ${GREEN}[Theme]${NC} section."
fi

echo -e ""
echo -e "You can test the theme without logging out using:"
echo -e "${BLUE}sddm-greeter --test-mode --theme ${THEME_DIR}${NC}"
echo -e "🚀 Enjoy your Nothing Phone aesthetic!"
