#!/bin/sh
set -eu

if [ "$#" -ne 3 ]; then
  echo "usage: $0 EXTRACTED_PRODUCT OUTPUT_IMAGE TARGET_BYTES" >&2
  exit 2
fi

source_dir=$1
output_image=$2
target_bytes=$3
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
contexts="$script_dir/../selinux/product-system-file-contexts"
mkfs_erofs=${MKFS_EROFS:-mkfs.erofs}
fsck_erofs=${FSCK_EROFS:-fsck.erofs}

case "$target_bytes" in
  ''|*[!0-9]*)
    echo "TARGET_BYTES must be a positive integer" >&2
    exit 2
    ;;
esac

if [ ! -d "$source_dir" ]; then
  echo "not a directory: $source_dir" >&2
  exit 1
fi

if [ ! -f "$contexts" ]; then
  echo "missing SELinux contexts file: $contexts" >&2
  exit 1
fi

mkdir -p "$(dirname -- "$output_image")"
rm -f -- "$output_image"

"$mkfs_erofs" \
  -zlz4hc,12 \
  -T 1230768000 \
  --all-root \
  --file-contexts="$contexts" \
  "$output_image" "$source_dir"

"$fsck_erofs" "$output_image"
image_bytes=$(stat -c %s "$output_image")

if [ "$image_bytes" -gt "$target_bytes" ]; then
  echo "REFUSING to truncate oversized filesystem: $image_bytes > $target_bytes" >&2
  exit 1
fi

truncate -s "$target_bytes" "$output_image"
"$fsck_erofs" "$output_image"
sha256sum "$output_image"
