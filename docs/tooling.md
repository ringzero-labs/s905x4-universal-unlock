# Upstream tooling

No third-party binaries are vendored in this repository. Obtain tools from their
official projects and verify their releases independently:

- [Android SDK Platform Tools](https://developer.android.com/tools/releases/platform-tools)
  for ADB and Fastboot.
- [CoreELEC](https://coreelec.org/) for removable-media Linux access.
- [erofs-utils](https://git.kernel.org/pub/scm/linux/kernel/git/xiang/erofs-utils.git/)
  for EROFS extraction, construction and verification.
- [Projectivy Launcher](https://github.com/spocky/miproja1) for the replacement
  television interface.
- [Apktool](https://apktool.org/) for building the source-only experimental HOME
  bridge.
- [androidtvremote2](https://github.com/tronikos/androidtvremote2) for optional
  remote-control pairing from Linux.

The successful EROFS rebuild used erofs-utils 1.9.4 and the experimental bridge
was verified with Apktool 3.0.3. These versions document the tested environment;
they are not bundled downloads.
