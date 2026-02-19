#!/bin/bash

# Glyph SDDM Theme Installer
# Author: xCaptaiN09

set -e

THEME_NAME="glyph"
THEME_DIR="/usr/share/sddm/themes/${THEME_NAME}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}==>${NC} Installing ${GREEN}${THEME_NAME}${NC} SDDM theme..."

# Check for NixOS
if [ -f /etc/NIXOS ]; then
    echo -e "${RED}Warning:${NC} NixOS detected. Manual file copying will not work on NixOS."
    echo -e "Please use the declarative method in your ${BLUE}configuration.nix${NC}."
    echo -e "See the ${GREEN}README.md${NC} for the NixOS configuration snippet."
    exit 1
fi

# Check for root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error:${NC} Please run as root (use sudo)."
    exit 1
fi

# Create theme directory
if [ -d "${THEME_DIR}" ]; then
    echo -e "${BLUE}==>${NC} Existing theme found. Cleaning up..."
    rm -rf "${THEME_DIR}"
fi

echo -e "${BLUE}==>${NC} Creating directory: ${THEME_DIR}"
mkdir -p "${THEME_DIR}"

# Copy files excluding git and screenshots
echo -e "${BLUE}==>${NC} Copying files..."
cp -r ./* "${THEME_DIR}/"
rm -rf "${THEME_DIR}/.git"
rm -rf "${THEME_DIR}/screenshots"
rm -f "${THEME_DIR}/README.md"
rm -f "${THEME_DIR}/install.sh"

# Set permissions
echo -e "${BLUE}==>${NC} Setting permissions..."
chmod -R 755 "${THEME_DIR}"

echo -e "${GREEN}Done!${NC} Theme installed to ${THEME_DIR}"
echo -e ""

# Interactive configuration
read -p "Would you like to set Glyph as your active SDDM theme? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}==>${NC} Applying theme configuration..."
    # Create config dir if it doesn't exist
    sudo mkdir -p /etc/sddm.conf.d
    # Check if we should use a .user file (cleaner)
    echo -e "[Theme]\nCurrent=${THEME_NAME}" | sudo tee /etc/sddm.conf.d/theme.conf.user > /dev/null
    echo -e "${GREEN}Theme applied successfully!${NC}"
else
    echo -e "To apply the theme manually:"
    echo -e "1. Edit ${BLUE}/etc/sddm.conf${NC} or ${BLUE}/etc/sddm.conf.d/theme.conf.user${NC}"
    echo -e "2. Set ${GREEN}Current=${THEME_NAME}${NC} under the ${GREEN}[Theme]${NC} section."
fi

echo -e ""
echo -e "You can test the theme without logging out using:"
echo -e "${BLUE}sddm-greeter --test-mode --theme ${THEME_DIR}${NC}"
echo -e "🚀 Enjoy your Nothing Phone aesthetic!"
