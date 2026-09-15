# SEI Robotics Developer Options Restriction & Universal Bypass

This document details the reverse engineering discovery, root cause analysis, and permanent bypass for the hidden Developer Options restriction implemented in SEI Robotics Android TV devices (`SEI800`, `SEI810`, `SEI830` on Claro, Telecom Flow, Tigo, Vodafone, etc.).

---

## 1. Problem Statement

When attempting to enable Android Developer Options by tapping 7 times on **Settings -> Device Preferences -> About -> Build number**, the device displays an operator warning Toast instead of unlocking the menu:

> *"Esta opción no se encuentra habilitada. Contacte al centro de atención al cliente para más información"* (`show_dev_disabled`)

---

## 2. Reverse Engineering Findings

Decompilation of `/system/priv-app/SeiTvSettings/SeiTvSettings.apk` reveals the gatekeeper logic in `com.android.tv.settings.about.AboutFragment`:

### A. The Hidden Combination Check (`AboutFragment.smali`)
In method `onPreferenceTreeClick` (handling key `"build_number"`, label `:pswitch_6`):

```smali
:cond_a
    invoke-virtual {p0}, Lcom/android/tv/settings/about/AboutFragment;->getContext()Landroid/content/Context;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;
    move-result-object v0
    const v8, 0x7f05002e    # config_key_combination_open_developer
    invoke-virtual {v0, v8}, Landroid/content/res/Resources;->getBoolean(I)Z
    move-result v0
    if-eqz v0, :cond_14
```

1. When `config_key_combination_open_developer` (`0x7f05002e`) is `true`:
   * Normal clicks on "Build number" are intercepted.
   * Key events from the remote control are captured in `onKeyDown` and buffered into a `StringBuilder` (`developerCommand`).
   * The code expects a specific key code sequence matching `developer_keys` (`0x7f03005c`):
     ```
     21, 21, 22, 22, OK, 21, 22, OK
     ```
     Corresponding to Android keycodes:
     * `21` = `KEYCODE_DPAD_LEFT` (⬅️)
     * `22` = `KEYCODE_DPAD_RIGHT` (➡️)
     * `OK` = `KEYCODE_DPAD_CENTER` (Center / OK)
     
     **Universal Remote Sequence:**
     $$\text{LEFT} \rightarrow \text{LEFT} \rightarrow \text{RIGHT} \rightarrow \text{RIGHT} \rightarrow \text{OK} \rightarrow \text{LEFT} \rightarrow \text{RIGHT} \rightarrow \text{OK}$$

2. If the user clicks 7 times without entering the secret sequence, `mDevHitCountdown` reaches 0 and displays Toast `0x7f1006bf` (`show_dev_disabled`).

3. When `config_key_combination_open_developer` is `false` (jumping to `:cond_14`):
   * Standard AOSP countdown executes (7, 6, 5... clicks).
   * Reaching 0 calls `DevelopmentSettingsEnabler.setDevelopmentSettingsEnabled(context, true)`.
   * Displays the standard Toast `0x7f1006c0`: *"¡Ahora eres un desarrollador!"*.

---

## 3. The Root Cause: Vendor Runtime Resource Overlay (RRO)

Inspection of the stock firmware reveals:
* In the base `SeiTvSettings.apk`, `config_key_combination_open_developer` defaults to **`false`**:
  ```xml
  <bool name="config_key_combination_open_developer">false</bool>
  ```
* The restriction is imposed **solely** by the static vendor overlay:
  `/vendor/overlay/SeiTvSettings__auto_generated_rro_vendor.apk`
  which overrides:
  ```xml
  <bool name="config_key_combination_open_developer">true</bool>
  ```

---

## 4. The Global Permanent Solution

### Why modifying `SeiTvSettings.apk` directly is dangerous:
`SeiTvSettings.apk` declares `android:sharedUserId="android.uid.system"`. On Android 12, all apps sharing `android.uid.system` must be signed by the OEM release key (`sei@seirobotics.com`). If replaced with a testkey-signed APK, `PackageManagerService` will reject the package at boot, causing Settings to vanish completely.

### The Clean Systemless Solution (Integrated in `SEI800-Clean-Suite.zip`):

Our master Magisk module neutralizes the lock cleanly at three levels:

1. **`post-fs-data.sh` (Pre-Zygote Phase):**
   Neutralizes the vendor overlay by bind-mounting `/dev/null` over `/vendor/overlay/SeiTvSettings__auto_generated_rro_vendor.apk`. Android's `idmap2` skips the overlay, returning `config_key_combination_open_developer` to its native `false`.
   ```sh
   for overlay in \
       /vendor/overlay/SeiTvSettings__auto_generated_rro_vendor.apk \
       /system/vendor/overlay/SeiTvSettings__auto_generated_rro_vendor.apk; do
       [ -f "$overlay" ] && mount -o bind /dev/null "$overlay" 2>/dev/null || true
   done
   ```

2. **Carrier Property Neutralization:**
   Clears operator flags before system services start:
   ```sh
   resetprop persist.sys.forbit_debug false
   resetprop persist.sys.nes.ismirada false
   resetprop persist.sys.carrier.locked false
   resetprop ro.debuggable 1
   ```

3. **`service.sh` (Post-Boot Database Initialization):**
   Ensures Developer Options and ADB are permanently enabled in Android's global settings database on every boot:
   ```sh
   settings put global development_settings_enabled 1
   settings put secure restricted_settings 1
   settings put global adb_enabled 1
   settings put global nes_development_pin_done 1
   ```

4. **Neutral Overlay (`system/vendor/overlay/SeiTvSettings__auto_generated_rro_vendor.apk`):**
   The module also packages a clean recompiled overlay with `config_key_combination_open_developer=false` while keeping UEI remote setup active.

---

## 5. Summary of Unlock Methods

| Scenario | Recommended Method |
| :--- | :--- |
| **Stock / Unrooted TV Box** | Enter remote combo: **`⬅️ ⬅️ ➡️ ➡️ OK ⬅️ ➡️ OK`** on *Build number*. |
| **Rooted with Magisk** | Flash `output/SEI800-Clean-Suite.zip` via Magisk Manager (permanent, zero-touch). |
| **Live ADB Root Shell** | Run `./scripts/god-mode-tweak.sh` (activates settings and props immediately). |
