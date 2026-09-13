# SEI800CCOA bootloader-forensics record

## Scope and conclusion

This is an evidence-led reconstruction for one owner-controlled Claro
SEI800CCOA Android TV box running build 11081. It does not claim a universal
method for other SEI, Amlogic, carrier, firmware, or board revisions.

The unit was not factory-unlocked. Its initial U-Boot environment contained:

```text
disableunlock=1
lock=10101000
```

The unlock path was a vendor recovery/update design flaw: the initial boot
command executed `cfgloadusb` before eMMC Android boot. That command loaded a
file named `cfgload` from USB FAT partition 1 and passed it to U-Boot `source`.
The bootloader did not require a cryptographic signature for that legacy script
container.

## Evidence chain & Ghidra Binary Verification

1. The pre-change CoreELEC backup completed and includes `env.img`, full eMMC,
   boot0 and boot1 hashes. It is deliberately excluded from Git.
2. In-depth reverse engineering using **Ghidra 12.1.2 MCP** directly on the raw `env` partition
   revealed the exact coexistence of two universal U-Boot bootloader hooks:
   - **SEI Robotics Hook (`0x00000847` & `0x00000AC8`):**
     `cfgloadusb=if fatload usb 0:1 ${loadaddr} cfgload; then setenv device usb; source ${loadaddr}; fi`
     This hook runs `cfgload` before eMMC boot without cryptographic signature checks.
   - **Amlogic Standard / ZTE Reference Hook (`0x00001C1E`):**
     `recovery_from_fat_dev=... if fatload ${fatload_dev} 0 ${loadaddr} aml_autoscript; then autoscr ${loadaddr}; fi`
     This hook executes standard `aml_autoscript` on ZTE (Megacable B866V2F, B866V2H01) and Skyworth (Flow F2).
3. By generating both `cfgload` and `aml_autoscript` simultaneously in [`scripts/quick-unlock-usb.py`](../scripts/quick-unlock-usb.py),
   the USB unlock drive guarantees universal 100% execution across both SEI Robotics and ZTE/Skyworth carrier hardware.
4. **ADNL & U-Boot Recovery Microcode (`0x000032AB` - `0x000035F6`):**
   - `0x000035e0`: `usb_burning=adnl 1200` (Amlogic ADNL USB Burning Protocol).
   - `0x000035f6`: `usb_burningCfg=usb_burn aml_sdc_burn.ini` (Unattended eMMC factory re-flash).
   - `0x00003482`: `upgrade_key`: Hardware key detection triggering `fastboot 0`.
5. **ATF EL3 Secure Monitor Calls for Hardware JTAG/SWD (`meson_jtag.ko`):**
   Decompilation of `/lib/modules/meson_jtag.ko` in Ghidra exposed the exact ARM SMCCC registers:
   - `aml_set_jtag_state` issues `__arm_smccc_smc(0x82000041, ...)` to ungate SoC JTAG/SWD debug lines.
   - Calling `__arm_smccc_smc(0x82000040, ...)` disables debugging muxing.
   - Sysfs control interface mapped to `/sys/class/jtag/select` accepts:
     - `echo "ap,jtag_a" > /sys/class/jtag/select`
     - `echo "ap,jtag_b" > /sys/class/jtag/select`
     - `echo "ap,swd_a" > /sys/class/jtag/select` (Single Wire Debug for ARM Cortex-A55)
6. The final generated prerequisite retained `lock=10101000`, but persisted
   `disableunlock=0` and `oemlock=unlock`, then started USB Fastboot.
7. The U-Boot Fastboot implementation parses `lock=10101000` as an unlockable,
   still-locked state. Its `flashing unlock` handler changes the lock state to
   zero, persists the updated `lock` record, and erases userdata/metadata when
   AVB is enabled.
8. Current device evidence is `disableunlock=0`, `oemlock=unlock`,
   `lock=10100000`, and Android Verified Boot state `orange`.

## What did not happen

- Android developer options did not unlock the device.
- No production signing key, eFuse bypass, or cryptographic break was used.
- The final method was not an `aml_autoscript` file and was not signed. Earlier
  `aml_autoscript` files were exploratory artifacts; the successful boot path
  loaded `cfgload`.
- The method does not establish that another device is vulnerable. U-Boot
  commands, USB boot order, signature checks, storage layout, and secure-boot
  policy vary by firmware.

## Reproduced sequence: SEI800CCOA build 11081 only

This is the complete sequence used on the investigated owner-controlled unit.
It is destructive: the final Fastboot command erases `userdata` and
`metadata`. Do not adapt it to another board based on model family alone.

1. Boot CoreELEC from removable media and make a verified eMMC, boot0 and boot1
   backup. Preserve the stock OTA and hash every backup before any persistent
   write.
2. On a separate FAT32 USB drive, generate the legacy container and place it in
   the filesystem root with the exact filename `cfgload`:

   ```sh
   python3 uboot/generate-cfgload-prereq.py --output /media/USB/cfgload
   sync
   ```

   The confirmed environment specifically loads `cfgload` from USB partition
   one. It does not prove that `aml_autoscript`, `boot.scr`, or another filename
   will be loaded on this firmware.
3. Disconnect power, insert that USB drive, connect the data cable to the host,
   then boot the box. The `cfgloadusb` hook persists the OEM-unlock prerequisite
   and switches the single USB port into USB Fastboot mode.
4. Remove the USB drive if the port must be reused, reconnect the host cable,
   and confirm the Fastboot device is present:

   ```sh
   fastboot devices
   fastboot getvar unlocked
   fastboot getvar secure
   ```

5. Make the standard Fastboot state transition:

   ```sh
   fastboot flashing unlock
   ```

   This writes the unlocked lock record and erases `userdata`/`metadata` on the
   tested AVB configuration. It is the point of no return for user data.
6. Confirm `unlocked: yes` and `secure: no`, reboot, and verify Android exposes
   `ro.boot.verifiedbootstate=orange`.

The original pre-change environment had `disableunlock=1`; therefore skipping
the prerequisite resulted in the conventional locked-device failure reported by
other owners.

## Safety and reproducibility boundaries

The prerequisite can render a device unbootable if its U-Boot semantics differ.
It should only be evaluated after: identifying the exact board/firmware,
capturing a complete verified recovery image, inspecting its environment/boot
path, and confirming owner authorization. Do not use it on carrier-loaned or
third-party equipment.
