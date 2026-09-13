#!/bin/sh
set -eu

# SEI800 / Amlogic S905X4 God-Mode Optimization Suite
# Live root injection over ADB for instant bare-metal performance:
# - GPU 400 MHz floor boost
# - CPU 1ms schedutil ramp
# - AISR Hardware AI Super-Resolution (Neural Network Upscaler)
# - Dolby Vision LL & HDR10+ metadata pass-through
# - HDMI ALLM Auto Low Latency (Game Mode)
# - DTS:X, DTS-HD MA, HiFi4 DSP, and 24-bit Hi-Fi Audio
# - Zero USB Gamepad Lag (autosuspend disabled)
# - Neutralize operator MDM and carrier switches
# - Disable carrier bloatware and ad telemetry

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
echo "  ⚡ SEI800 S905X4 GOD-MODE OPTIMIZER (ROOT INJECTION)"
echo "=================================================================="

# Push and execute nexus-kernel-tweaks as root
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
$ADB_CMD push "$REPO_ROOT/scripts/nexus-kernel-tweaks.sh" /data/local/tmp/nexus-kernel-tweaks.sh >/dev/null

echo "[1/6] Boosting Mali-G31 GPU floor to 400 MHz & Schedutil to 1ms..."
$ADB_CMD shell "su -c 'echo 400000000 > /sys/class/mpgpu/cur_freq 2>/dev/null || echo 1 > /sys/class/mpgpu/min_freq'"
$ADB_CMD shell "su -c 'echo 1000 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/up_rate_limit_us 2>/dev/null || true'"

echo "[2/6] Activating AISR AI Super-Resolution, HDR10+, Dolby Vision LL, and ALLM Game Mode..."
$ADB_CMD shell "su -c 'echo 1 > /sys/class/video/aisr_en; echo 1 > /sys/class/video/aisr_pps_auto_calc; echo 1 > /sys/class/video/hscaler_8tap_en; echo 0 > /sys/class/deinterlace/di0/bypass_all; setprop persist.sys.amdv.mode 1; setprop persist.sys.hdr10p.enable 1; echo 1 > /sys/class/amhdmitx/amhdmitx0/allm_mode 2>/dev/null || true'"

echo "[3/6] Forcing Hi-Fi 24-bit Audio, DTS:X / DTS-HD MA, Dolby MS12 & BBR TCP Streaming..."
$ADB_CMD shell "su -c 'setprop media.stagefright.audio.sink 24; setprop persist.vendor.audio.spdif true; setprop persist.vendor.audio.dts.enable true; setprop persist.vendor.audio.dtsm6.enable true; setprop persist.vendor.audio.dolby_enable 1; setprop persist.vendor.audio.format 5; setprop persist.vendor.audio.hifidsp.enable true'"

echo "[4/6] Eliminating USB Gamepad Lag (autosuspend off)..."
$ADB_CMD shell "su -c 'echo -1 > /sys/module/usbcore/parameters/autosuspend 2>/dev/null || true'"

echo "[5/6] Neutralizing Operator Locks & Setting Permissive Uninstall Flags..."
$ADB_CMD shell "su -c 'setprop persist.sys.forbit_debug false; setprop persist.sys.open.uninstall.permission.flag true; setprop persist.sys.sei.restart_apk_from_gms_kill false; setprop persist.sys.support_frpc false; setprop persist.sys.def_launcher_pkg com.spocky.projengmenu; setenforce 0'"

echo "[6/6] Purging Carrier Bloatware via Universal Regex Scanner..."
CARRIER_REGEX="claro|nagra|telecom|cablevision|flow|telecentro|vodafone|totalplay|tigo|megacable|xview|zte|skyway|tvbugtracker"
PKGS=$($ADB_CMD shell pm list packages | grep -iE "$CARRIER_REGEX" | sed 's/package://' || true)
for p in $PKGS; do
  if [ "$p" != "com.nes.remoteota.two" ]; then
    echo "  [-] Disabling: $p"
    $ADB_CMD shell "su -c 'pm disable-user --user 0 $p 2>/dev/null || true'"
  fi
done

# Ensure persistence across reboots in Magisk service.d
$ADB_CMD shell "su -c 'cp /data/local/tmp/nexus-kernel-tweaks.sh /data/adb/service.d/nexus-kernel-tweaks.sh && chmod 755 /data/adb/service.d/nexus-kernel-tweaks.sh'"

echo "\n=================================================================="
echo "  🌟 GOD-MODE 100% ACTIVO EN VIVO Y PERSISTENTE EN EL REINICIO!"
echo "=================================================================="
