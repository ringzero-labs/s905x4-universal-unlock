#!/system/bin/sh
# Nexus TV (SEI800 / S905X4) - Master Bare-Metal Kernel & Performance Suite
# Place in /data/adb/service.d/ for persistent boot execution via Magisk.

until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

# 1. CPU Schedutil Fast Ramp-up (1ms rate limit & 1.0 GHz floor)
for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
    [ -f "$cpu/scaling_min_freq" ] && echo 1000000 > "$cpu/scaling_min_freq"
done
[ -f /sys/devices/system/cpu/cpufreq/policy0/schedutil/rate_limit_us ] && echo 1000 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/rate_limit_us
[ -f /sys/devices/system/cpu/cpufreq/policy0/schedutil/up_rate_limit_us ] && echo 500 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/up_rate_limit_us
[ -f /sys/devices/system/cpu/cpufreq/policy0/schedutil/down_rate_limit_us ] && echo 2000 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/down_rate_limit_us

# 2. GPU Mali-G31 Base Clock Boost to 400 MHz (Level 1)
# Eliminates frame drops and UI micro-stutters during 4K navigation
[ -f /sys/class/mpgpu/min_freq ] && echo 1 > /sys/class/mpgpu/min_freq

# 3. Video Engine & Amlogic Display Pipeline
# Instant Video Render (Zero Delay VSYNC Handshake)
[ -f /sys/class/video/show_first_frame_nosync ] && echo 1 > /sys/class/video/show_first_frame_nosync
[ -f /sys/class/video/show_first_picture ] && echo 1 > /sys/class/video/show_first_picture
# Hardware AI Super Resolution (AISR / NN Upscaling) & 8-tap Polyphase Horizontal Scaler
[ -f /sys/class/video/aisr_en ] && echo 1 > /sys/class/video/aisr_en
[ -f /sys/class/video/aisr_pps_auto_calc ] && echo 1 > /sys/class/video/aisr_pps_auto_calc
[ -f /sys/class/video/hscaler_8tap_en ] && echo 1 > /sys/class/video/hscaler_8tap_en
# Amlogic Motion Adaptive Deinterlacing (DI) & Noise Filter
[ -f /sys/class/deinterlace/di0/bypass_all ] && echo 0 > /sys/class/deinterlace/di0/bypass_all

# Auto Frame Rate (AFR) & Amlogic VPU High Clock
[ -f /sys/class/tv/policy_fr_auto ] && echo 1 > /sys/class/tv/policy_fr_auto
[ -f /sys/class/amhdmitx/amhdmitx0/frac_rate_policy ] && echo 1 > /sys/class/amhdmitx/amhdmitx0/frac_rate_policy
[ -f /sys/class/vdec/poweron_clock_level ] && echo 0 > /sys/class/vdec/poweron_clock_level
[ -f /sys/class/amvecm/hdr_policy ] && echo 0 > /sys/class/amvecm/hdr_policy

# 4. Storage I/O Optimization for Flash eMMC
[ -f /sys/block/mmcblk0/queue/scheduler ] && echo none > /sys/block/mmcblk0/queue/scheduler
[ -f /sys/block/mmcblk0/queue/read_ahead_kb ] && echo 1024 > /sys/block/mmcblk0/queue/read_ahead_kb
vdc fstrim dotrim >/dev/null 2>&1 &

# 5. Virtual Memory & ZRAM Tuning (Optimized for 2GB RAM Set-Top Box)
# Switch zRAM to ultra-fast LZ4 if available
if [ -f /sys/block/zram0/comp_algorithm ]; then
    grep -q lz4 /sys/block/zram0/comp_algorithm && echo lz4 > /sys/block/zram0/comp_algorithm
fi
echo 100 > /proc/sys/vm/swappiness
echo 50 > /proc/sys/vm/vfs_cache_pressure
echo 5 > /proc/sys/vm/dirty_background_ratio
echo 15 > /proc/sys/vm/dirty_ratio
echo 500 > /proc/sys/vm/dirty_writeback_centisecs

# 6. Ultra-High Bitrate Network Stack (BBR & 16MB Buffers for 4K Remux / P2P Streaming)
echo 16777216 > /proc/sys/net/core/rmem_max
echo 16777216 > /proc/sys/net/core/wmem_max
echo "4096 87380 16777216" > /proc/sys/net/ipv4/tcp_rmem
echo "4096 65536 16777216" > /proc/sys/net/ipv4/tcp_wmem
echo 1 > /proc/sys/net/ipv4/tcp_window_scaling
echo 3 > /proc/sys/net/ipv4/tcp_fastopen
echo 0 > /proc/sys/net/ipv4/tcp_slow_start_after_idle
echo 5000 > /proc/sys/net/core/netdev_max_backlog
echo 4096 > /proc/sys/net/core/somaxconn

# Enable BBR congestion control if compiled in kernel, otherwise fallback to cubic
if grep -q bbr /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null; then
    echo bbr > /proc/sys/net/ipv4/tcp_congestion_control
elif grep -q cubic /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null; then
    echo cubic > /proc/sys/net/ipv4/tcp_congestion_control
fi

# Wi-Fi Power-Save OFF (Eliminates ping spikes and drops in GeForce NOW / Moonlight)
which iw >/dev/null 2>&1 && iw dev wlan0 set power_save off >/dev/null 2>&1

# Bluetooth Sniff/Sleep Minimizer (Reduces Remote Control wake-up latency)
[ -f /sys/module/bcmdhd/parameters/dhd_slp_enable ] && echo 0 > /sys/module/bcmdhd/parameters/dhd_slp_enable 2>/dev/null

# 7. Low-Latency Gamepads & Emulation (RetroArch / Moonlight)
# Disable USB autosuspend to eliminate input lag on USB/2.4G controllers
[ -f /sys/module/usbcore/parameters/autosuspend ] && echo -1 > /sys/module/usbcore/parameters/autosuspend 2>/dev/null

# 8. High-Fidelity Audio Passthrough & Video Quality Engine
# Force 24-bit Direct Audio Output, DTS:X / DTS-HD Master Audio & Dolby Atmos MS12 Passthrough
setprop media.stagefright.audio.sink 24
setprop persist.vendor.audio.spdif true
setprop ro.vendor.media.amlogic.dolby.ms12.support true
setprop media.amplayer.fastforward 1
setprop persist.vendor.audio.dts.enable true
setprop persist.vendor.audio.dtsm6.enable true
setprop persist.vendor.audio.dolby_enable 1
setprop persist.vendor.audio.format 5
setprop ro.vendor.audio.sdk.fluencetype none
setprop persist.vendor.audio.hifidsp.enable true

# Amlogic Color Management 2 (CM2) & Dynamic Noise Reduction (DNR)
[ -f /sys/class/amvecm/cm2_en ] && echo 1 > /sys/class/amvecm/cm2_en
[ -f /sys/class/amvecm/dnr_en ] && echo 1 > /sys/class/amvecm/dnr_en

# Hardware HDR10+ / Dolby Vision Low-Latency (LL 422) & ALLM Engine
# Automatically synchronizes HDR metadata bypass and activates HDMI Game Content Mode
setprop persist.sys.amdv.mode 1
setprop persist.sys.hdr10p.enable 1
setprop ro.vendor.media.amlogic.hdr.force_source true
[ -f /sys/class/amhdmitx/amhdmitx0/allm_mode ] && echo 1 > /sys/class/amhdmitx/amhdmitx0/allm_mode 2>/dev/null

# 9. HDMI CEC 2.0 Integration (One-Touch TV Power Sync)
setprop persist.sys.hdmi.keep_awake 0
setprop ro.hdmi.device_type 4

# 10. SurfaceFlinger & HWUI SkiaGL Acceleration
setprop sys.use_fifo_ui 1
setprop debug.sf.latch_unsignaled 1
setprop persist.sys.purgeable_assets 1
setprop debug.hwui.renderer skiagl
setprop renderthread.skia.reduceopstasksplitting true
setprop debug.sf.enable_hwc_vds 0

# Disable Mobile Battery & Doze restrictions (AC-powered TV Box)
setprop persist.sys.app_standby_enabled 0
setprop persist.sys.battery_saver 0
dumpsys deviceidle disable >/dev/null 2>&1 &

# 11. Overhead & Tracer Reduction (Saves CPU cycles for rendering)
[ -f /sys/kernel/debug/tracing/tracing_on ] && echo 0 > /sys/kernel/debug/tracing/tracing_on
echo "1 4 1 7" > /proc/sys/kernel/printk

# 12. Universal Hardware & Carrier Lock Flags Neutralizer
# Permanently strips operator MDM re-spawns and enables universal app uninstalls
setprop persist.sys.forbit_debug false
setprop persist.sys.open.uninstall.permission.flag true
setprop persist.sys.sei.restart_apk_from_gms_kill false
setprop persist.sys.support_frpc false
setprop persist.sys.def_launcher_pkg com.spocky.projengmenu

# 13. SELinux: Permissive
setenforce 0

# 14. Universal Developer Options & ADB Activation (SEI Bypass)
# Permanently keeps developer options, ADB, and restricted settings unlocked
settings put global development_settings_enabled 1
settings put secure restricted_settings 1
settings put global adb_enabled 1
settings put global nes_development_pin_done 1

