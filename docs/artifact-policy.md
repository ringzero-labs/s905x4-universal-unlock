# Artifact and privacy policy

## Intentionally excluded

- Full eMMC, boot0 and boot1 dumps.
- Stock or modified Android partition images.
- Official OTA archives and captured OTA traffic.
- Proprietary bootloader, DTB and vendor binaries.
- Third-party APK/JAR files.
- ADB keys and temporary trusted boot images containing keys.
- Android TV Remote pairing certificates and private keys.
- Device serial numbers, LAN addresses and owner-specific names.
- Photos and screenshots exposing identifiers or account state.

## Included instead

- Reproducible source and shell commands.
- Expected partition sizes and validation logic.
- Names sufficient to obtain upstream tools independently.
- A source-only HOME bridge with no APK or signing key.

Before committing new files, run:

```sh
scripts/pre-publish-check.sh
```

The check rejects common credentials, private LAN addresses, device serial
patterns, large tracked files and prohibited binary artifact extensions. It is a
last guardrail, not a replacement for reviewing every staged change.
