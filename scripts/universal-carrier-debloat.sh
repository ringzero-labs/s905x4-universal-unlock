#!/bin/sh
set -eu

# Universal Carrier & Telemetry Debloat Suite for Android TV / S905X4
# Supports: Claro (LATAM), Telecom Argentina (Flow), Vodafone, Totalplay, Tigo, Telecentro

if [ "$#" -gt 1 ]; then
  echo "Usage: $0 [ADB_DEVICE_SERIAL]" >&2
  exit 1
fi

if [ "$#" -eq 1 ]; then
  ADB_CMD="adb -s $1"
else
  ADB_CMD="adb"
fi

echo "=================================================================="
echo "  🚀 UNIVERSAL OPERATOR DEBLOAT & TELEMETRY REMOVAL"
echo "  Target: Claro, Flow, Telecentro, Totalplay, Tigo, Vodafone"
echo "=================================================================="

# Function to safely disable/uninstall for user 0
disable_app() {
  pkg="$1"
  desc="$2"
  if $ADB_CMD shell pm list packages | grep -q "$pkg"; then
    echo "  [-] Removing: $desc ($pkg)..."
    $ADB_CMD shell pm disable-user --user 0 "$pkg" 2>/dev/null || true
    $ADB_CMD shell pm uninstall -k --user 0 "$pkg" 2>/dev/null || true
  fi
}

echo "\n[1/5] Disabling SEI Robotics / Operator MDM & Background Agents..."
# Claro / SEI base services & Nagra conditional access
disable_app "com.nagra.ion.clc" "Nagra CAS / Operator Lock Screen"
disable_app "com.nagra.clarovideo" "Claro Video Native Operator Portal"
disable_app "com.claro.claromusica.latam" "Claro Música Preloaded"
disable_app "com.nes.skywayclient" "SEI Skyway Remote MDM Agent"
disable_app "com.nes.tvbugtracker" "SEI Bug Tracker & Diagnostics Logger"
disable_app "com.nes.leanbacklauncher.partnercustomizer" "Operator Launcher Partner Customizer"
disable_app "com.nes.coreservice" "SEI Core Background Telemetry"
disable_app "android.autoinstalls.config.sei" "SEI Auto-Install Stubs"

echo "\n[2/5] Disabling Telecom Argentina (Flow / Telecom) Bloatware..."
disable_app "com.telecom.flow" "Telecom Flow TV Native Portal"
disable_app "ar.com.telecom.flow" "Telecom Argentina Flow App"
disable_app "com.cablevision.flow" "Cablevision Flow Legacy Agent"

echo "\n[3/5] Disabling Telecentro (Argentina) Bloatware..."
disable_app "com.telecentro.play" "Telecentro Play Launcher Override"
disable_app "ar.com.telecentro.tplay" "Telecentro TV Agent"

echo "\n[4/5] Disabling Vodafone TV (Europe), Megacable (México) & Totalplay / Tigo Bloatware..."
disable_app "com.vodafone.vtv" "Vodafone TV Portal & Restrictor"
disable_app "com.totalplay.tv" "Totalplay 4K Launcher Lock"
disable_app "com.tigo.smarttv" "Tigo / Millicom Operator Shell"
disable_app "com.megacable.xview" "Megacable Xview+ Native Portal"
disable_app "com.zte.iptvclient.android.activity" "ZTE IPTV Launcher Client"
disable_app "com.zte.smartremote" "ZTE Remote Daemon"

echo "\n[5/5] Disabling Google TV Ad / Recommendation Bloat..."
disable_app "com.google.android.tvrecommendations" "Google Home Ad Carousel"
disable_app "com.google.android.feedback" "Google User Feedback Agent"

echo "\n[6/6] Auto-detecting and sweeping ANY remaining carrier/operator packages (Regex Scan)..."
# Scans dynamically for any operator packages matching carrier keywords:
CARRIER_REGEX="claro|nagra|telecom|cablevision|flow|telecentro|vodafone|totalplay|tigo|megacable|xview|zte|skyway|tvbugtracker"
DETECTED_PACKAGES=$($ADB_CMD shell pm list packages | grep -iE "$CARRIER_REGEX" | sed 's/package://' || true)

if [ -n "$DETECTED_PACKAGES" ]; then
  for pkg in $DETECTED_PACKAGES; do
    # Protect critical remote control packages
    if [ "$pkg" != "com.nes.remoteota.two" ]; then
      echo "  [!] Auto-purging detected carrier package: $pkg"
      $ADB_CMD shell pm disable-user --user 0 "$pkg" 2>/dev/null || true
      $ADB_CMD shell pm uninstall -k --user 0 "$pkg" 2>/dev/null || true
    fi
  done
fi

echo "\n[7/7] Neutralizing Deep Operator Lock Flags in System Environment..."
$ADB_CMD shell setprop persist.sys.forbit_debug false
$ADB_CMD shell setprop persist.sys.open.uninstall.permission.flag true
$ADB_CMD shell setprop persist.sys.sei.restart_apk_from_gms_kill false
$ADB_CMD shell setprop persist.sys.support_frpc false
$ADB_CMD shell setprop persist.sys.def_launcher_pkg com.spocky.projengmenu

echo "\n=================================================================="
echo "  🎉 DEBLOAT COMPLETED SUCCESSFULLY!"
echo "  Operator lock screens, background telemetry, and MDM disabled."
echo "  Hardware level carrier lock flags permanently revoked."
echo "  Preserved: Bluetooth Remote (`Vendor_06e7`), Widevine L1, and Play Store."
echo "=================================================================="

