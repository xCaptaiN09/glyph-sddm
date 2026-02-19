#!/bin/bash
# Installer for Glyph SDDM Theme

THEME_NAME="glyph-sddm"
THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"

echo "Installing $THEME_NAME..."

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

if [ -d "$THEME_DIR" ]; then
    echo "Updating existing installation..."
    rm -rf "$THEME_DIR"
fi

mkdir -p "$THEME_DIR"
cp -r ./* "$THEME_DIR"

echo "Theme installed to $THEME_DIR"
echo "To enable, edit /etc/sddm.conf:"
echo "-----------------------------------"
echo "[Theme]"
echo "Current=$THEME_NAME"
echo "-----------------------------------"
