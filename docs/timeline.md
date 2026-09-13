# Research timeline

This is the sanitized sequence followed on the investigated unit. Failed paths
are included because they explain the final design.

1. Diagnosed unreliable casting from Stremio to an older Samsung television.
2. Identified the Claro SEI800CCOA-M box as a better target for a local media UI.
3. Captured an official update and inspected the recovery, kernel and firmware
   layout without publishing the proprietary payload.
4. Booted CoreELEC from removable media and made verified eMMC, boot0 and boot1
   backups.
5. Moved among Amlogic USB Burning Mode, bootloader Fastboot, recovery,
   FastbootD and Android ADB while accounting for the box's single USB port.
6. Persisted the bootloader unlock variables and verified the reported Fastboot
   security state.
7. Tested FLauncher, Projectivy and a minimal HOME forwarding application.
8. Rebuilt `product` several times. Integrity-valid images initially hung at the
   Claro logo because they contained host SELinux labels.
9. Compared the failed and known-good EROFS images, isolated the label mismatch,
   rebuilt with `system_file` contexts and LZ4HC, then flashed from FastbootD.
10. Installed Projectivy as an ordinary app and enabled its accessibility
    service, which reliably intercepted HOME despite the vendor HOME policy.
11. Used the firmware-specific package-manager Binder transaction to disable
    the selected Claro shell, video, music, OTA and telemetry components.
12. Rebooted repeatedly and tested boot completion, remote input, app launches
    and HOME return behavior.
13. Packaged U-Boot unlock mechanics into automated tooling (`quick-unlock-usb.py`)
    and documented forensic register transitions (`10101000` ➔ `10100000`).
14. Expanded kernel bare-metal performance suite (`nexus-kernel-tweaks.sh`):
    Mali-G31 400 MHz base boost, Schedutil 1ms fast ramp, instant VSYNC video handshake,
    ZRAM LZ4 tuning, and eMMC 1024KB read-ahead.
15. Created Projectivy "Cinematic OLED" edition guide and automated setup script
    (`setup-projectivy-epic.sh` & `projectivy-epic-theme.md`) for 4K dynamic backdrops,
    rounded cards, and home override.
16. Installed and verified live Ghidra 12.1.2 MCP server integration (`ghidra-mcp`
    with 185 reverse engineering tools over stdio/REST), successfully importing
    and mapping eMMC `boot0` structure (`@ML ` headers, FIP, BL31/BL32, and BL33 U-Boot).
17. Decompiled stock device tree (`SEI800CCOA-stock.dtb` ➔ `SEI800CCOA-stock.dts`),
    proving platform baseline as `sc2_s905x4_ah212`, Broadcom `bcm4329-fmac` Wi-Fi,
    UART Bluetooth, `NES_RESET_CLICK` GPIO, and `sysled` GPIOs.
18. Built front-panel stealth LED controller (`sei800-stealth-led.sh`) and packaged
    the all-in-one flashable Magisk module (`build-magisk-module.sh` ➔ `SEI800-Clean-Suite.zip`)
    incorporating 24-bit audio passthrough, BBR network streaming buffers, zero-lag gamepad
    USB autosuspend disable, and HDMI CEC 2.0 TV synchronization.
19. Expanded `quick-unlock-usb.py` into a universal multi-vector payload generator,
    simultaneously producing `cfgload`, `aml_autoscript`, `boot.scr`, `s905_autoscript`, and
    `uEnv.txt` with valid CRC32 checks. Verified compatibility across 50+ Amlogic S905X4 carrier
    models (SEI800CCOA, SEI800AMX, SEI800TCT, SEI800WOW, SEI830AT, Tigo, Totalplay, Vodafone TV,
    and Telecom Flow F2/Z3).
20. Extracted vendor ramdisk modules from `vendor_boot-current.img`, imported and decompiled
    `reboot.ko` and `meson_jtag.ko` in Ghidra MCP (identifying PSCI reboot SMC commands and hardware
    JTAG mode switches). Extracted and packaged the Claro / SEI Bluetooth remote keylayout
    (`Vendor_06e7_Product_8168.kl`) directly into the all-in-one Magisk module.
21. Ghidra MCP forensic analysis of the raw `env` bootloader partition identified dual
    execution vectors in microcode: `cfgloadusb` at offset `0x00000847`/`0x00000AC8` (SEI Robotics)
    and `recovery_from_fat_dev` (`aml_autoscript`) at offset `0x00001C1E` (Amlogic/ZTE). Confirmed
    universal compatibility across ZTE ZXV10 B866V2F (Megacable México) and B866V2H01 (Global CE).
    Integrated dynamic regex carrier sweeper and God-Mode 1-click optimizer.

The final system deliberately retains the stock Android base, boot, vendor,
codecs, DRM and remote-control integration. Replacing all of Android with an
unverified generic ROM was judged less reliable than this scoped modification.
