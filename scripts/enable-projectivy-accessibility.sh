#!/bin/sh
set -eu

if [ "$#" -gt 1 ]; then
  echo "usage: $0 [ADB_DEVICE_SERIAL]" >&2
  exit 2
fi

if [ "$#" -eq 1 ]; then
  set -- -s "$1"
else
  set --
fi

adb "$@" shell settings put secure enabled_accessibility_services \
  com.spocky.projengmenu/com.spocky.projengmenu.services.ProjectivyAccessibilityService
adb "$@" shell settings put secure accessibility_enabled 1
adb "$@" shell settings get secure enabled_accessibility_services
