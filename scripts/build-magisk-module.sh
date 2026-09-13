#!/bin/sh
set -eu

# SEI800 / S905X4 Master Optimization Suite - Magisk Module Packager
# Packages kernel performance tweaks, RAM tuning, stealth LED, and debloat into a flashable ZIP.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$REPO_ROOT/build/magisk_module"
OUTPUT_DIR="$REPO_ROOT/output"
ZIP_NAME="SEI800-Clean-Suite.zip"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/common" "$BUILD_DIR/system/bin" "$OUTPUT_DIR"

echo "==> Building Magisk Module structure..."

# 1. module.prop
cat << 'PROP' > "$BUILD_DIR/module.prop"
id=sei800-clean-suite
name=SEI800 S905X4 Master Optimization Suite
version=v1.2.0
versionCode=120
author=ringzero-labs
description=Bare-metal performance suite for SEI800 / Amlogic S905X4 (SC2): 400MHz GPU, 1ms schedutil, RAM LZ4, AFR, Wi-Fi low-latency, Stealth LED control, and operator debloat.
PROP

# 2. service.sh (Executes at boot via Magisk service.d)
cp "$REPO_ROOT/scripts/nexus-kernel-tweaks.sh" "$BUILD_DIR/service.sh"
chmod 755 "$BUILD_DIR/service.sh"

# 3. System overlay tools
cp "$REPO_ROOT/scripts/sei800-stealth-led.sh" "$BUILD_DIR/system/bin/sei800-led"
chmod 755 "$BUILD_DIR/system/bin/sei800-led"

# 4. Vendor Keylayout Overlay (Bluetooth Remote Control)
mkdir -p "$BUILD_DIR/system/vendor/usr/keylayout"
if [ -f "$REPO_ROOT/configs/Vendor_06e7_Product_8168.kl" ]; then
    cp "$REPO_ROOT/configs/Vendor_06e7_Product_8168.kl" "$BUILD_DIR/system/vendor/usr/keylayout/"
    chmod 644 "$BUILD_DIR/system/vendor/usr/keylayout/Vendor_06e7_Product_8168.kl"
fi

# 5. Standard Magisk installer scripts
cat << 'INSTALL' > "$BUILD_DIR/customize.sh"
ui_print "****************************************"
ui_print "  SEI800 S905X4 Master Suite Installer  "
ui_print "****************************************"
ui_print "- Installing bare-metal kernel tweaks..."
ui_print "- Setting GPU base clock floor to 400 MHz..."
ui_print "- Configuring ZRAM / LZ4 compression..."
ui_print "- Installing /system/bin/sei800-led..."
ui_print "- Injecting Bluetooth Remote keylayout..."
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/system/bin/sei800-led" 0 0 0755
set_perm "$MODPATH/system/vendor/usr/keylayout/Vendor_06e7_Product_8168.kl" 0 0 0644
ui_print "- Optimization suite installed successfully!"
INSTALL

# Create empty placeholder for system files
touch "$BUILD_DIR/system/placeholder"

echo "==> Creating flashable archive: $OUTPUT_DIR/$ZIP_NAME"
(
    cd "$BUILD_DIR"
    zip -q -r "$OUTPUT_DIR/$ZIP_NAME" .
)

echo "==> SUCCESS: $OUTPUT_DIR/$ZIP_NAME is ready to flash via Magisk Manager!"
