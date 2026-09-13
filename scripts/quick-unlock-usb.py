#!/usr/bin/env python3
"""
Quick USB Unlock Builder for Amlogic S905X4 / SEI Robotics TV Boxes
Generates the legacy U-Boot 'cfgload' container with valid CRC32 to enable Fastboot OEM unlock.
Target: SEI800 / SEI800CCOA and compatible Amlogic SC2 operator STBs.
"""

import sys
import os
import struct
import time
import zlib
from pathlib import Path

def build_payload():
    """Constructs the universal U-Boot command script for SEI and generic Amlogic boxes."""
    payload_text = (
        b"echo [!] Universal Amlogic / SEI Robotics OEM Unlock Trigger...\n"
        b"# 1. Unset lock protections\n"
        b"setenv disableunlock 0\n"
        b"setenv oemlock unlock\n"
        b"setenv lock 10101000\n"
        b"# 2. Persist to SEI dedicated eMMC env partition\n"
        b"update_env_part -p disableunlock\n"
        b"update_env_part -p oemlock\n"
        b"update_env_part -p lock\n"
        b"# 3. Persist to generic Amlogic U-Boot storage\n"
        b"saveenv\n"
        b"# 4. Drop into Fastboot via USB gadget\n"
        b"usb stop\n"
        b"echo [!] Dropping into Fastboot Mode...\n"
        b"fastboot 0\n"
        b"fastboot\n"
        b"run fastboot\n"
    )

    script = struct.pack(">II", len(payload_text), 0) + payload_text
    while len(script) % 4:
        script += b"\0"

    name = b"Universal unlock prerequisite"
    header = struct.pack(
        ">7I4B32s",
        0x27051956,       # U-Boot Legacy Image Magic
        0,                # Header CRC placeholder
        int(time.time()), # Timestamp
        len(script),      # Data Size
        0,                # Load Address
        0,                # Entry Point
        zlib.crc32(script) & 0xFFFFFFFF, # Data CRC
        5,                # OS: Linux
        22,               # Arch: AArch64
        6,                # Type: Script
        0,                # Compression: None
        name.ljust(32, b"\0"),
    )
    header_crc = zlib.crc32(header) & 0xFFFFFFFF
    header = header[:4] + struct.pack(">I", header_crc) + header[8:]

    return header + script, payload_text

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 quick-unlock-usb.py <path_to_fat32_usb_mount_or_output_dir>")
        print("Example: python3 quick-unlock-usb.py /media/USB_DRIVE")
        sys.exit(1)

    dest = Path(sys.argv[1])
    dest.mkdir(parents=True, exist_ok=True)

    container, raw_script = build_payload()

    # Generate all known Amlogic & SEI boot script fallback filenames:
    # 1. cfgload          -> SEI Robotics (SEI800, SEI700, SEI500, SEI900, Claro, Telecentro)
    # 2. aml_autoscript   -> Amlogic Standard Reference (Skyworth, ZTE, SDMC, Kaonmedia, Flow)
    # 3. boot.scr         -> Mainline U-Boot / CoreELEC fallback
    # 4. s905_autoscript  -> Legacy Amlogic S905 series
    # 5. uEnv.txt         -> Plain text environment fallback
    filenames = ["cfgload", "aml_autoscript", "boot.scr", "s905_autoscript"]

    for name in filenames:
        out_path = dest / name
        out_path.write_bytes(container)
        print(f"  ✔ Created U-Boot container: {out_path.name} ({len(container)} bytes)")

    # Plain text uEnv.txt
    uenv_content = (
        "disableunlock=0\n"
        "oemlock=unlock\n"
        "lock=10101000\n"
        "bootcmd=echo [!] uEnv OEM Unlock; saveenv; fastboot 0\n"
    )
    (dest / "uEnv.txt").write_text(uenv_content)
    print("  ✔ Created plain-text config: uEnv.txt")

    print("\n==================================================================")
    print("  🎉 UNIVERSAL MULTI-DEVICE UNLOCK DRIVE READY!")
    print(f"  📁 Destination: {dest.resolve()}")
    print("  🌍 Compatible with: SEI Robotics, Skyworth, ZTE, SDMC, Telecentro, Flow, Claro")
    print("==================================================================")
    print("\nNext Steps on Any Amlogic TV Box:")
    print(" 1. Disconnect power from the TV Box.")
    print(" 2. Insert this USB drive into the USB port.")
    print(" 3. Connect a male-to-male USB data cable from the TV Box to your PC.")
    print(" 4. Connect power to the TV Box.")
    print("    -> U-Boot executes the matching script, persists unlock registers, and enters Fastboot.")
    print(" 5. On your PC terminal, run:")
    print("       fastboot devices")
    print("       fastboot flashing unlock")
    print("    -> Permanent unlock achieved (verifiedbootstate=orange)!\n")

if __name__ == "__main__":
    main()
