#!/bin/sh
set -u

BACKUP_DIR="${BACKUP_DIR:-/storage/emmc-backup}"
EXPECTED_SECTORS="${EXPECTED_SECTORS:-15269888}"
IMAGE_FILE="${BACKUP_DIR}/emmc-full.img"

mkdir -p "${BACKUP_DIR}"

if [ ! -b /dev/mmcblk0 ]; then
  echo "ERROR: /dev/mmcblk0 is missing" >&2
  exit 1
fi

actual_sectors="$(cat /sys/class/block/mmcblk0/size)"
if [ "${actual_sectors}" != "${EXPECTED_SECTORS}" ]; then
  echo "ERROR: expected ${EXPECTED_SECTORS} sectors, found ${actual_sectors}" >&2
  exit 1
fi

cat /proc/partitions > "${BACKUP_DIR}/partitions.txt"
blkid > "${BACKUP_DIR}/blkid.txt" 2>&1
dmesg | grep -Ei 'mmc|emmc|sdhci|meson.*mmc' > "${BACKUP_DIR}/mmc-dmesg.txt"

dd if=/dev/mmcblk0 of="${IMAGE_FILE}" bs=4M conv=fsync
dd if=/dev/mmcblk0boot0 of="${BACKUP_DIR}/mmcblk0boot0.img" bs=1M conv=fsync
dd if=/dev/mmcblk0boot1 of="${BACKUP_DIR}/mmcblk0boot1.img" bs=1M conv=fsync

(
  cd "${BACKUP_DIR}" || exit 1
  sha256sum emmc-full.img mmcblk0boot0.img mmcblk0boot1.img > SHA256SUMS
  touch BACKUP-COMPLETE
)
sync
