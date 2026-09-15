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
version=v1.3.0
versionCode=130
author=ringzero-labs
description=Bare-metal performance suite for SEI800 / Amlogic S905X4 (SC2): 400MHz GPU, 1ms schedutil, RAM LZ4, AFR, Wi-Fi low-latency, Stealth LED control, operator debloat, and permanent Developer Options / ADB unlock.
PROP

# 2. post-fs-data.sh (Early-stage neutralization before Zygote/Framework)
cat << 'POSTFS' > "$BUILD_DIR/post-fs-data.sh"
#!/system/bin/sh
# Runs before Zygote & Framework - Early carrier restriction & overlay neutralizer

# Neutralize vendor RRO overlays restricting Developer Options
for overlay in \
    /vendor/overlay/SeiTvSettings__auto_generated_rro_vendor.apk \
    /system/vendor/overlay/SeiTvSettings__auto_generated_rro_vendor.apk; do
    if [ -f "$overlay" ]; then
        mount -o bind /dev/null "$overlay" 2>/dev/null || true
    fi
done

# Reset carrier lock and anti-debug props before framework services cache them
resetprop persist.sys.forbit_debug false
resetprop persist.sys.nes.ismirada false
resetprop persist.sys.carrier.locked false
resetprop ro.debuggable 1
POSTFS
chmod 755 "$BUILD_DIR/post-fs-data.sh"

# 3. service.sh (Executes at boot via Magisk service.d)
cp "$REPO_ROOT/scripts/nexus-kernel-tweaks.sh" "$BUILD_DIR/service.sh"
chmod 755 "$BUILD_DIR/service.sh"

# 4. System overlay tools
cp "$REPO_ROOT/scripts/sei800-stealth-led.sh" "$BUILD_DIR/system/bin/sei800-led"
chmod 755 "$BUILD_DIR/system/bin/sei800-led"

# 5. Vendor Keylayout Overlay (Bluetooth Remote Control)
mkdir -p "$BUILD_DIR/system/vendor/usr/keylayout"
if [ -f "$REPO_ROOT/configs/Vendor_06e7_Product_8168.kl" ]; then
    cp "$REPO_ROOT/configs/Vendor_06e7_Product_8168.kl" "$BUILD_DIR/system/vendor/usr/keylayout/"
    chmod 644 "$BUILD_DIR/system/vendor/usr/keylayout/Vendor_06e7_Product_8168.kl"
fi

# 6. Unlocked Vendor RRO Overlay (replaces operator developer lock)
mkdir -p "$BUILD_DIR/system/vendor/overlay"
if [ -f "$REPO_ROOT/configs/SeiTvSettings__auto_generated_rro_vendor.apk" ]; then
    cp "$REPO_ROOT/configs/SeiTvSettings__auto_generated_rro_vendor.apk" "$BUILD_DIR/system/vendor/overlay/"
    chmod 644 "$BUILD_DIR/system/vendor/overlay/SeiTvSettings__auto_generated_rro_vendor.apk"
fi

# 7. Standard Magisk installer scripts
cat << 'INSTALL' > "$BUILD_DIR/customize.sh"
ui_print "****************************************"
ui_print "  SEI800 S905X4 Master Suite Installer  "
ui_print "****************************************"
ui_print "- Installing bare-metal kernel tweaks..."
ui_print "- Setting GPU base clock floor to 400 MHz..."
ui_print "- Configuring ZRAM / LZ4 compression..."
ui_print "- Installing /system/bin/sei800-led..."
ui_print "- Injecting Bluetooth Remote keylayout..."
ui_print "- Unlocking Developer Options & ADB permanently..."
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/system/bin/sei800-led" 0 0 0755
set_perm "$MODPATH/system/vendor/usr/keylayout/Vendor_06e7_Product_8168.kl" 0 0 0644
if [ -f "$MODPATH/system/vendor/overlay/SeiTvSettings__auto_generated_rro_vendor.apk" ]; then
    set_perm "$MODPATH/system/vendor/overlay/SeiTvSettings__auto_generated_rro_vendor.apk" 0 0 0644
fi
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
