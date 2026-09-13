#!/bin/sh
set -eu

# Setup Projectivy Launcher - Epic Cinematic Edition
# Configures default home, accessibility hooks, and silky-smooth UI animations.

if [ "$#" -gt 1 ]; then
  echo "usage: $0 [ADB_DEVICE_SERIAL]" >&2
  exit 2
fi

if [ "$#" -eq 1 ]; then
  set -- -s "$1"
else
  set --
fi

echo "==> Configuring Projectivy Launcher..."

# 1. Enable Accessibility Service (Required for HOME key interception & instant focus)
adb "$@" shell settings put secure enabled_accessibility_services \
  com.spocky.projengmenu/com.spocky.projengmenu.services.ProjectivyAccessibilityService
adb "$@" shell settings put secure accessibility_enabled 1

# 2. Set Projectivy as the default Home Activity
adb "$@" shell cmd package set-home-activity com.spocky.projengmenu/.LauncherActivity || true

# 3. Supercharged UI Animation Speeds (Buttery 60fps response)
adb "$@" shell settings put global window_animation_scale 0.75
adb "$@" shell settings put global transition_animation_scale 0.75
adb "$@" shell settings put global animator_duration_scale 0.75

# 4. Hide status clutter and optimize screen density
adb "$@" shell settings put secure sysui_banner_enabled 0 2>/dev/null || true

chmod +x "$0" 2>/dev/null || true

echo "==> Projectivy Accessibility & Home Activity configured successfully!"
echo "==> Open Projectivy Launcher and apply the 'Cinematic OLED' visual preset (see docs/projectivy-epic-theme.md)."
