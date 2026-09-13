#!/bin/sh
set -eu

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "run this script inside the initialized repository" >&2
  exit 2
fi

# Split sensitive signatures so this source file does not match its own scan.
private_key_pattern='BEGIN .*PRIVATE'' KEY'
adb_key_pattern='adb''key'
github_token_pattern='g''ho_[A-Za-z0-9_]+'
device_serial_pattern='G''Z[0-9]{8,}'
lan_pattern='192''\.168\.[0-9]+\.[0-9]+'
author_leak_pattern='dan''iel|castri''llon|daniel''cadev'
secret_pattern="$private_key_pattern|$adb_key_pattern|$github_token_pattern|$device_serial_pattern|$lan_pattern|$author_leak_pattern"

if git grep -nEI "$secret_pattern" -- . \
  ':(exclude).gitignore' \
  ':(exclude)scripts/pre-publish-check.sh' \
  ':(exclude)docs/artifact-policy.md'
then
  echo "possible sensitive material found" >&2
  exit 1
fi

if git ls-files | grep -Ei '\.(img|bin|rom|zip|apk|jar|pcap|dtb|heic|png|jpe?g|pem|key|crt|p12|keystore|idsig)$'
then
  echo "prohibited binary or credential artifact is tracked" >&2
  exit 1
fi

large_files=$(git ls-files | while IFS= read -r tracked_file; do
  if [ -f "$tracked_file" ] && [ "$(stat -c %s "$tracked_file")" -gt 5242880 ]; then
    echo "$tracked_file"
  fi
done)

if [ -n "$large_files" ]; then
  printf 'tracked file exceeds 5 MiB: %s\n' "$large_files" >&2
  exit 1
fi

echo "pre-publish checks passed"
