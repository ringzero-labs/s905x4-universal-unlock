# Investigation postmortem

## FLauncher launched but crashed

FLauncher was initially placed in `/product/app/FLauncher` without extracted
native libraries. Flutter failed with `libflutter.so not found`. Installing the
same signed APK as a user update caused Package Manager to extract its ARMv7
libraries under `/data/app`, after which it launched normally.

## HOME role rejected third-party launchers

FLauncher and Projectivy declared HOME intent filters, but this customized ROM did
not return them as HOME candidates. Binder preferences could be written, yet the
resolver still chose `com.android.tv.settings/.system.FallbackHome`.

Moving Projectivy into `product/priv-app` did not solve the role issue and caused
a boot hang. A tiny privileged HOME bridge also failed to qualify from `product`.
The practical working solution was Projectivy's accessibility service.

## EROFS passed fsck but still bootlooped

Files rebuilt from the Linux home directory inherited this host context:

```text
unconfined_u:object_r:user_home_t:s0
```

The known-good Android image contained:

```text
u:object_r:system_file:s0
```

EROFS integrity does not prove Android SELinux correctness. Explicit file
contexts fixed the boot hang:

```text
/ u:object_r:system_file:s0
/.* u:object_r:system_file:s0
```

Checking the embedded label strings before flashing was decisive.

## Oversized EROFS images

Plain LZ4 rebuilds exceeded the product partition after small changes. LZ4HC
produces the same runtime LZ4 format with better build-time compression. The
filesystem must be smaller than the target before zero-padding. Truncating an
oversized filesystem creates corruption.

## Claro shell policy

The firmware rejected several ordinary shell mutations as illegal commands.
Direct Android Binder calls remained available. Transaction numbers are
firmware-specific and were recovered from that build's `IPackageManager` stub.

## Final working combination

1. Known-good product image with Android SELinux labels.
2. Projectivy installed as an ordinary application.
3. Projectivy accessibility service enabled in `Settings.Secure`.
4. Onboarding completed and repeated prompts permanently declined.
5. Scoped Claro packages disabled through the verified Binder transaction.
6. Reboot and HOME behavior tested repeatedly.
