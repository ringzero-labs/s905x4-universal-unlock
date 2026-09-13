#!/bin/sh
set -u

OUT_DIR="${1:-/storage/backup-preflight}"
mkdir -p "${OUT_DIR}"

{
  echo "CoreELEC eMMC backup preflight"
  date
  uname -a
  cat /proc/partitions
  lsblk -o NAME,PATH,SIZE,TYPE,FSTYPE,LABEL,MOUNTPOINTS,MODEL 2>&1
  blkid 2>&1
  ls -la /dev/mmc* /dev/block/by-name 2>&1
  dmesg | grep -Ei 'mmc|emmc|sdhci|meson.*mmc' | tail -n 400
} > "${OUT_DIR}/storage-check.txt"

sync
