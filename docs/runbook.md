# End-to-end runbook

Read the postmortem before changing this sequence: several valid-looking EROFS
images bootlooped because of host SELinux labels.

## 1. Back up first

Boot CoreELEC from removable media and run the preflight and backup scripts from
this repository. Confirm `/dev/mmcblk0` has the expected sector count before `dd`.

Copy and verify the full eMMC image, boot0, boot1, partition listing, `blkid` and
relevant kernel log. Do not continue without a second backup copy.

## 2. Verify bootloader state

The Amlogic environment accepted a persistent unlock state on the investigated
unit. The readable commands are in [../uboot/README.md](../uboot/README.md).

```sh
fastboot getvar unlocked
fastboot getvar secure
```

The successful unit reported `unlocked: yes` and `secure: no`.

## 3. Preserve known-good partitions

Preserve stock boot, vendor, vbmeta and product from the official OTA or full
backup. Record hashes. Do not publish those artifacts.

The successful approach retained stock boot and vendor. AVB changes were made
only after the original vbmeta was backed up.

## 4. Build `product` safely

Keep the original product tree and make scoped changes only:

```sh
scripts/build-product-erofs.sh extracted-product output/product.img 512389120
scripts/check-image-labels.sh output/product.img
```

The context check must show only:

```text
u:object_r:system_file:s0
```

Never truncate an oversized filesystem. The script refuses to do so.

## 5. Flash only from FastbootD

```sh
adb reboot bootloader
fastboot getvar unlocked
fastboot reboot fastboot
fastboot getvar is-userspace
fastboot flash product output/product.img
fastboot reboot
```

If Android remains at the boot logo and neither USB ADB nor Ethernet returns,
restore the known-good product image through FastbootD.

## 6. Enable Projectivy as an ordinary app

Install Projectivy from its official upstream distribution. Do **not** place the
modern APK directly in `product/priv-app` on this firmware; that caused a boot
hang during package scanning.

```sh
scripts/enable-projectivy-accessibility.sh DEVICE_SERIAL
```

Complete onboarding. In this investigation media access was allowed for
wallpapers, while TV listings, notification access and telemetry were declined.
Test HOME from a normal application, then reboot and test again.

## 7. Disable scoped Claro packages

The firmware blocked ordinary `pm disable-user`, but the Android 12
`IPackageManager.setApplicationEnabledSetting` Binder transaction worked on this
specific build. Review [../scripts/debloat-packages.sh](../scripts/debloat-packages.sh)
and its firmware-specific warning before use.

Remote-control packages were intentionally retained.

## Recovery with one USB port

1. Remove power.
2. Use the owner's prepared Amlogic removable-media script to reach Fastboot.
3. Replace the removable drive with the PC cable.
4. Enter FastbootD.
5. Flash the known-good `product` image only.
6. Reboot and wait for `sys.boot_completed=1`.
