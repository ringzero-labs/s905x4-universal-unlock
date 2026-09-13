#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
  echo "usage: $0 ADB_DEVICE_SERIAL" >&2
  exit 2
fi

device=$1

# Transaction 81 matched IPackageManager.setApplicationEnabledSetting on the
# investigated Android 12 build. It is not portable: verify it before use on
# another firmware revision. State 3 means COMPONENT_ENABLED_STATE_DISABLED_USER.
disable_package() {
  package_name=$1
  echo "Disabling $package_name"
  adb -s "$device" shell service call package 81 \
    s16 "$package_name" i32 3 i32 0 i32 0 s16 com.android.shell
}

for package_name in \
  com.nagra.ion.clc \
  com.nagra.clarovideo \
  com.nes.skywayclient \
  com.nes.tvbugtracker \
  com.nes.remoteota.two \
  com.nes.leanbacklauncher.partnercustomizer \
  com.nes.coreservice \
  com.claro.claromusica.latam \
  me.efesser.flauncher
do
  disable_package "$package_name"
done

# Remote-control packages are intentionally not included.
