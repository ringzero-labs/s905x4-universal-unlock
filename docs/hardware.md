# Hardware and firmware observations

- Commercial model: SEI800CCOA-M / SEI800CCOA
- Platform OEM: SEI Robotics SEI800
- SoC family: Amlogic S905X4 / SC2 family
- Reference Board Profile (DTS `compatible`): `sc2_s905x4_ah212`
- Wi-Fi Chipset: Broadcom FullMAC SDIO (`brcm,bcm4329-fmac` / `bcmdhd`)
- Bluetooth Subsystem: Broadcom HCI UART (`uart_a`)
- Android base: Android TV 12
- Linux kernel family observed: 5.4
- Final kernel observed: `5.4.259-ab11081`, ARM64 kernel with 32-bit Android userspace
- CPU policy observed: four cores, 1.0–2.004 GHz, with `schedutil` available
- RAM/zRAM observed: 2 GB RAM and a 1 GB Zstandard-compressed zRAM device
- SELinux observed: enforcing (permissive via Magisk overlay)
- Storage device exposed by CoreELEC: `/dev/mmcblk0`
- Observed full eMMC sector count: `15269888` (7.3 GiB User Data Area)
- Boot Partition Layout (`/dev/mmcblk0boot0` & `boot1` 4 MiB):
  - `0x00000000`: JEDEC eMMC Boot Record
  - `0x00000200`: Amlogic BL2 Header (`@ML `, Magic: `40 4D 4C 20`)
  - `0x00000780` - `0x00002280`: FIP Descriptors & Secure Boot Signatures
  - `0x00003000` - `0x0000A400`: BL31 (EL3 Runtime) & BL32 (OP-TEE OS)
  - `0x000A4AE0`: BL33 / U-Boot payload
  - Build Identifier: `SC2-202604151337BBST`
- CoreELEC Compatibility: Target DTB in `amlogic-ne` is `sc2_s905x4_ah212.dtb`
- Dynamic partitions: `product` must be flashed from FastbootD
- Product logical partition size in this investigation: `512389120` bytes
- Hardware JTAG / SWD Multiplexing:
  - Controlled via kernel module `meson_jtag.ko` and sysfs `/sys/class/jtag/select`.
  - Secure Monitor Call (ARM SMC EL3): `0x82000041` (Enable) / `0x82000040` (Disable).
  - Pin routing modes: `ap,jtag_a`, `ap,jtag_b`, `ap,swd_a` (ARM Cortex-A55 SWD clock/data).

The board markings and DTB identify the device as the standard Amlogic `ah212`
reference architecture. Preserving stock boot, vendor and DRM was safer than forcing an
unrelated GSI.

## USB modes encountered

1. Amlogic USB Burning Mode.
2. Bootloader Fastboot (`Android Fastboot`).
3. Userspace Fastboot (`fastbootd`).
4. Android ADB (`18d1:4ee7`).

FastbootD was required for the logical `product` partition:

```sh
fastboot getvar unlocked
fastboot reboot fastboot
fastboot getvar is-userspace
```

Expected values were `unlocked: yes` and `is-userspace: yes`.
