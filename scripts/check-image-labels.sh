#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
  echo "usage: $0 PRODUCT_IMAGE" >&2
  exit 2
fi

image=$1
if [ ! -f "$image" ]; then
  echo "not a file: $image" >&2
  exit 1
fi

labels=$(
  strings "$image" \
    | grep -Eo '(unconfined_)?u:object_r:[A-Za-z0-9_]+:s0' \
    | sort -u \
    || true
)

printf '%s\n' "$labels"

if [ "$labels" != 'u:object_r:system_file:s0' ]; then
  echo "unexpected or missing SELinux labels; do not flash this image" >&2
  exit 1
fi

echo "SELinux label check passed"
