#!/bin/bash
# -------------------------------------------------------------------------
# Glyph SDDM - Automatic Installer
# Author: xCaptaiN09
# -------------------------------------------------------------------------

THEME_NAME="glyph-sddm"
THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"

echo "✨ Installing $THEME_NAME..."

# Check for root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Error: Please run as root (use sudo)."
    exit 1
fi

# Create theme directory if it doesn't exist
if [ -d "$THEME_DIR" ]; then
    echo "📦 Updating existing installation..."
    rm -rf "$THEME_DIR"
fi

mkdir -p "$THEME_DIR"

# Copy files excluding git and screenshots
echo "Files being copied..."
cp -r ./* "$THEME_DIR"
rm -rf "$THEME_DIR/.git"
rm -rf "$THEME_DIR/screenshots"
rm -f "$THEME_DIR/README.md"
rm -f "$THEME_DIR/install.sh"

echo "✅ Theme successfully installed to $THEME_DIR"

# Provide instructions
echo ""
echo "🛠 To enable Glyph SDDM:"
echo "1. Open /etc/sddm.conf (or /etc/sddm.conf.d/theme.conf.user)"
echo "2. Set the 'Current' theme under [Theme]:"
echo "-----------------------------------"
echo "[Theme]"
echo "Current=$THEME_NAME"
echo "-----------------------------------"
echo "🚀 Enjoy your Nothing Phone aesthetic!"
