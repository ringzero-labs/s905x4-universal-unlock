# Amlogic U-Boot unlock notes

This directory documents one owner-controlled **SEI800CCOA** unit only. It is
not evidence that another Amlogic device accepts these variables or the same
USB boot path.

The original environment was locked (`disableunlock=1`, `lock=10101000`). Its
`bootfromusb` command nevertheless executed a USB FAT partition file named
`cfgload` using U-Boot's `source` command before falling back to eMMC.

The successful prerequisite changed only the Fastboot gate variables, retained
the locked record, and entered USB Fastboot:

```text
setenv disableunlock 0
update_env_part -p disableunlock
setenv oemlock unlock
update_env_part -p oemlock
usb stop
fastboot 0
```

The subsequent standard Fastboot unlock transition wrote `lock=10100000` and
the current Android state reports `verifiedbootstate=orange`.

`generate-cfgload-prereq.py` creates the small legacy U-Boot script container
used for this specific prerequisite. It has a CRC32 integrity header, **not a
cryptographic signature**. Do not run it against a device without first proving
that its own bootloader loads `cfgload`, supports these environment variables,
and has a verified recovery image.
