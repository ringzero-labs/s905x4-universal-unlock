#!/usr/bin/env python3
"""Generate the SEI800CCOA-specific U-Boot cfgload prerequisite.

This creates a legacy uImage script with CRC32 integrity fields. It is not
signed and is intentionally scoped to the bootloader behavior documented in
../docs/bootloader-forensics.md.
"""

from __future__ import annotations

import argparse
import struct
import time
import zlib
from pathlib import Path


PAYLOAD = (
    b"echo Enabling OEM unlock while retaining locked state\n"
    b"setenv disableunlock 0\n"
    b"update_env_part -p disableunlock\n"
    b"setenv oemlock unlock\n"
    b"update_env_part -p oemlock\n"
    b"setenv lock 10101000\n"
    b"update_env_part -p lock\n"
    b"usb stop\n"
    b"fastboot 0\n"
)


def build_script() -> bytes:
    payload = struct.pack(">II", len(PAYLOAD), 0) + PAYLOAD
    payload += b"\0" * (-len(payload) % 4)
    header = struct.pack(
        ">7I4B32s",
        0x27051956,  # legacy uImage magic
        0,
        int(time.time()),
        len(payload),
        0,
        0,
        zlib.crc32(payload) & 0xFFFFFFFF,
        5,  # Linux OS
        22,  # ARM64 architecture
        6,  # script image
        0,  # uncompressed
        b"Persistent unlock prerequisite".ljust(32, b"\0"),
    )
    header_crc = zlib.crc32(header) & 0xFFFFFFFF
    header = header[:4] + struct.pack(">I", header_crc) + header[8:]
    return header + payload


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=Path("cfgload"))
    args = parser.parse_args()
    args.output.write_bytes(build_script())
    print(f"Wrote {args.output} ({args.output.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
