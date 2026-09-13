# SEI800 / Amlogic S905X4 Clean Android TV & Bootloader Unlock

[![Hardware: Amlogic S905X4](https://img.shields.io/badge/SoC-Amlogic%20S905X4%20%28SC2%29-blue.svg)](docs/hardware.md)
[![Platform: SEI Robotics SEI800](https://img.shields.io/badge/Platform-SEI%20Robotics%20SEI800-green.svg)](docs/hardware.md)
[![Bootloader: Confirmed Unlocked](https://img.shields.io/badge/Bootloader-Unlocked%20%28orange%29-orange.svg)](docs/bootloader-forensics.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

Reproducible research, forensic documentation, and automated tooling to restore owner control over **SEI Robotics SEI800 / Amlogic S905X4** operator set-top boxes (such as the Claro Box TV SEI800CCOA, Telecom Argentina Flow Box, and compatible devices) while preserving hardware acceleration, Widevine L1 DRM, remote control, and audio/video codecs.

---

## 🇪🇸 GUÍA PASO A PASO EN ESPAÑOL (MÉTODO FÁCIL Y DEFINITIVO)

> **¿Qué hace este método?**  
> Elimina de forma permanente el bloqueo de tu operadora (Claro, Megacable, Flow, etc.), desbloquea el Bootloader de la caja por hardware y la convierte en un **Android TV libre de alta velocidad** con Google Play Store, Widevine L1 (Netflix/Prime en 4K) y control remoto original funcionando al 100%.

---

### 🧰 Materiales necesarios:
1. **1 Memoria USB (Pendrive):** Formateada en **FAT32**.
2. **1 Cable USB Macho a Macho (USB-A a USB-A):** Para conectar la caja a tu PC.
3. **1 Palillo de madera, clip o aguja:** Para presionar el **botón oculto de RESET**.
4. **Una PC (Windows, Linux o Mac):** Con las herramientas de `fastboot` y `adb` ([Descargar Android Platform Tools oficial](https://developer.android.com/tools/releases/platform-tools)).

---

### 📋 PASO 1: Preparar la Memoria USB (10 segundos)

1. Conecta tu memoria USB a la computadora y asegúrate de que esté en formato **FAT32**.
2. Corre el script generador apuntando a la letra o ruta de tu USB:
   ```bash
   python3 scripts/quick-unlock-usb.py /media/TU_USB
   ```
   *(Si estás en Windows, puedes poner `E:\` o la letra de tu pendrive).*
3. Esto creará automáticamente los 5 archivos de arranque universal (`cfgload`, `aml_autoscript`, `boot.scr`, `s905_autoscript`, `uEnv.txt`) con sus firmas y sumas CRC32 en la raíz de la USB.

---

### 🔌 PASO 2: El truco del Botón RESET y la conexión

Este es el paso más importante para que la TV Box lea la USB antes de arrancar Android:

1. **Desconecta el cable de corriente (alimentación)** del TV Box. Debe estar completamente apagada.
2. Inserta la **memoria USB** preparada en el puerto USB del TV Box.
3. Conecta el **cable USB Macho a Macho** entre el TV Box y un puerto USB de tu PC.
4. **Localiza el botón oculto de RESET:**
   * En la **Claro Box (SEI800)** y en las cajas **ZTE / Flow**, el botón de RESET está **oculto al fondo del orificio de audio que dice "AV"** (o en un pequeño agujero debajo de la caja).
   * Introduce el palillo con cuidado hasta sentir el "clic" del pulsador físico.
5. **Enciende manteniendo presionado el botón:**
   * **Mantén presionado el botón de RESET con el palillo** firmemente.
   * **Sin soltarlo**, conecta el cable de corriente eléctrica a la TV Box.
   * Cuenta **6 a 8 segundos** manteniendo el botón presionado y luego suéltalo.
6. La caja detectará la memoria USB inmediatamente, ejecutará el microcódigo de desbloqueo en U-Boot y entrará automáticamente en modo **Fastboot**. Tu computadora emitirá el sonido de dispositivo conectado.

---

### 💻 PASO 3: Desbloquear el Bootloader desde la PC

1. En tu computadora, abre la terminal (o CMD / PowerShell en Windows) y verifica que la PC detecte la caja:
   ```bash
   fastboot devices
   ```
   *(Debe aparecer el número de serie de tu caja).*

2. Ejecuta el comando de liberación permanente:
   ```bash
   fastboot flashing unlock
   ```
   > ⚠️ **Aviso:** Este comando borra los datos de fábrica de la operadora y deja la caja en estado `orange` (libre de fábrica).

3. Reinicia la caja:
   ```bash
   fastboot reboot
   ```

---

### 🚀 PASO 4: Limpieza Automática (Eliminar Operador y Activar Modo Dios)

Una vez la caja prenda y hagas la configuración inicial de Wi-Fi:
1. Activa la *Depuración por USB* en *Ajustes de desarrollador* (o conecta por cable USB).
2. Ejecuta en tu terminal el optimizador automático:
   ```bash
   ./scripts/god-mode-tweak.sh
   ```
3. **¡Listo!** El script se encarga de:
   * Desinstalar y congelar todo el software espía y de bloqueo de Claro / ZTE / Flow / Megacable.
   * Acelerar los gráficos Mali GPU a 400 MHz (cero lag en la interfaz).
   * Activar reescalado inteligente por IA (AISR) y HDR10+ / Dolby Vision.
   * Configurar **Projectivy Launcher** como el menú principal limpio y rápido.

---

### ❓ Preguntas Frecuentes y Solución de Problemas

* **¿`fastboot devices` no muestra nada en Windows?**
  * Asegúrate de tener instalados los drivers de Google USB Driver o ejecuta *Windows Update > Actualizaciones opcionales* con la caja conectada.
  * Verifica que usaste un cable USB macho-a-macho que transmita datos y no solo carga.
* **¿La caja se prende normal y entra al logo de Claro/Operador?**
  * No mantuviste presionado el botón RESET el tiempo suficiente mientras conectabas la corriente. Repite el Paso 2 asegurándote de presionar bien el botón al fondo del puerto AV hasta escuchar el clic.
* **¿Se pierde el control remoto original?**
  * No. El control Bluetooth (`Vendor 06e7`) se mantiene 100% funcional con los botones de volumen, flechas y encendido.

---

## ⚡ Quick Start: 3-Step Bootloader Unlock (English Technical Summary)

---

## 🌍 Confirmed Hardware & Cross-Device Compatibility

| Device / Operator | OEM Model | SoC & Board Profile | Compatibility Status |
| :--- | :--- | :--- | :--- |
| **Claro Box TV (Colombia / LATAM)** | SEI800CCOA / SEI800CCOA-M | Amlogic S905X4 (`ah212`) | **Tested & Confirmed ✔** |
| **Claro TV Box (México / Sudamérica)** | SEI800AMX | Amlogic S905X4 (`ah212`) | 100% Identical Platform |
| **Telecentro Play Deco 4K (Argentina)** | SEI800TCT | Amlogic S905X4 (`ah212`) | 100% Identical Platform |
| **WOW! TV Pro (USA / Carrier)** | SEI800WOW | Amlogic S905X4 (`ah212`) | 100% Identical Platform |
| **OneComm TV+ (Caribe / Bermuda)** | SEI830AT | Amlogic S905X4 (`ah212`) | 100% Identical Platform |
| **Tigo / Millicom Smart TV Box** | SEI Robotics SEI800 | Amlogic S905X4 (`ah212`) | 100% Identical Platform |
| **Totalplay 4K Box** | SEI Robotics SEI800 / S905X4 | Amlogic S905X4 (`ah212`) | 100% Identical Platform |
| **Vodafone TV 4K Box (Europe / VTV)** | SEI Robotics SEI800VDF | Amlogic S905X4 (`ah212`) | 100% Identical Platform |
| **Claro TV+ Smart Speaker** | SEI810CCOA / SEI810CPR | Amlogic S905X4 (`ah212`) | Identical SoC & Kernel Base |
| **Telecom Argentina Flow (FlowBox Z3)** | ZTE B866V2F / B866V2 | Amlogic S905X4 | Architecture Equivalent (`aml_autoscript`) |
| **Megacable Xview+ (México)** | ZTE ZXV10 B866V2F / B866V2H01 | Amlogic S905X4 | Architecture Equivalent (`aml_autoscript`) |
| **Global Operator OTT (Europe/Asia)** | ZTE ZXV10 B866V2H01 (CE) | Amlogic S905X4 | Architecture Equivalent (`aml_autoscript`) |
| **SDMC DV8919 / Kaon KSTB6168** | SDMC / Kaonmedia | Amlogic S905X4 | Architecture Equivalent (`boot.scr`) |

> [!NOTE]
> `quick-unlock-usb.py` automatically generates **all 5 bootloader trigger vectors** (`cfgload`, `aml_autoscript`, `boot.scr`, `s905_autoscript`, and `uEnv.txt`) on the USB drive, ensuring zero-configuration unlock across SEI Robotics, Skyworth, ZTE, SDMC, and reference Amlogic hardware!

### 🔬 Forensic Discovery: Why This Method is Universally Compatible
Using **Ghidra 12.1.2 MCP** to analyze the raw `env` partition (`/dev/block/by-name/env`), we proved why this solution works globally across all S905X4 operator hardware:

1. **Dual Bootloader Vector Coexistence (Decompiled U-Boot Proof):**
   * **SEI Robotics Vector (`0x00000847` & `0x00000AC8`):**
     `cfgloadusb = if fatload usb 0:1 ${loadaddr} cfgload; then source ${loadaddr}; fi`
     *Directly executes `cfgload` without signature verification on Claro, Telecentro, Vodafone, Tigo, etc.*
   * **Amlogic / ZTE Standard Vector (`0x00001C1E`):**
     `recovery_from_fat_dev = ... if fatload ${fatload_dev} 0 ${loadaddr} aml_autoscript; then autoscr ${loadaddr}; fi`
     *Executes `aml_autoscript` on ZTE (Megacable B866V2F, B866V2H01) and Skyworth (Flow F2).*
2. **The Universal Multi-Vector Solution:**
   Instead of guessing the carrier, [`scripts/quick-unlock-usb.py`](scripts/quick-unlock-usb.py) writes **all 5 legacy execution scripts** (`cfgload`, `aml_autoscript`, `boot.scr`, `s905_autoscript`, `uEnv.txt`) with valid U-Boot image headers (`0x27051956`) and CRC32 sums to the root of the USB drive simultaneously. Any Amlogic TV Box will match its proprietary hook automatically.
3. **Shared Hardware Architecture (Amlogic AH212 Reference):**
   Decompilation of the stock Device Tree Source (`docs/SEI800CCOA-stock.dts`) proves that all these operator TV Boxes share the identical baseboard ID: `sc2_s905x4_ah212`. The hardware registers for Mali GPU (400 MHz), AISR AI Super-Resolution, and audio passthrough are identical at the silicon level.

---

## 🛡️ Unbrick & Bit-by-Bit eMMC Recovery

### Method 1: Recovery via CoreELEC Terminal (Soft-Brick)
If the device still boots into external media (USB / MicroSD):
1. Boot into CoreELEC `amlogic-ne` with `sc2_s905x4_ah212.dtb`.
2. Restore the raw 4 MiB bootloader stages directly over SSH/terminal:
   ```bash
   dd if=mmcblk0boot0.img of=/dev/mmcblk0boot0 bs=512 status=progress
   dd if=mmcblk0boot1.img of=/dev/mmcblk0boot1 bs=512 status=progress
   sync
   ```
3. Reboot to restore factory bootROM handoff.

### Method 2: Hardware Test Point / eMMC Short Circuit (Hard-Brick / Dead Box)
If the bootloader is completely corrupted (black screen, no LED, PC does not detect USB even holding RESET):
1. Open the plastic enclosure to access the printed circuit board (PCB).
2. Locate the eMMC flash chip or the labeled test pads `GND` and `CLK` (or `TP1`/`TP2` near the eMMC).
3. Using tweezers or a wire, short-circuit **`eMMC CLK to GND`** (this forces the internal bootROM to fail eMMC read).
4. While holding the short, plug the male-to-male USB cable from your PC to the TV Box:
   * The SoC immediately falls back to **Amlogic ROM USB Burning Mode** (PC sound detects `WorldCup Device` / `Amlogic USB`).
5. Release the tweezers and flash the stock image using *Amlogic USB Burning Tool* or run Fastboot recovery!

---

## 🚀 Post-Unlock Bare-Metal Performance Tweaks

Once rooted via 32-bit Magisk ramdisk overlay, run our hardware tuning suite ([`scripts/nexus-kernel-tweaks.sh`](scripts/nexus-kernel-tweaks.sh)):

* **GPU Base Clock Boost:** Lifts Mali-G31 MP2 idle floor from 285 MHz to **400 MHz**, eliminating UI frame drops.
* **CPU 1ms Fast Ramp:** Reduces Schedutil rate limit from 5000 µs to **1000 µs** for instantaneous 2.0 GHz response.
* **Instant Video Playback & Auto Frame Rate (AFR):** Enables `show_first_frame_nosync = 1`, unlocks VPU clocks and native auto-framerate switching.
* **Dolby Vision Low-Latency (LL 422) & HDR10+ Engine:** Forces dynamic HDR metadata pass-through directly to modern OLED/QLED TVs.
* **Auto Low Latency Mode (ALLM / Game Mode):** Automatically triggers low-latency game mode over HDMI for cloud gaming and emulators.
* **Audio Hi-Fi Passthrough & Dolby/DTS:** Forces 24-bit direct audio sink, S/PDIF bitstream, and Dolby MS12 hardware decoding.
* **Ultra-High Bitrate 4K Streaming (BBR):** 16 MB TCP window buffers with BBR congestion control for zero-buffering 4K Remux / P2P.
* **Low-Latency Gamepad & Emulation:** Disables USB autosuspend for lag-free wired/dongle controllers in RetroArch & Moonlight.
* **Amlogic Image Engine:** Activates Color Management 2 (CM2) and Dynamic Noise Reduction (DNR).
* **HDMI CEC 2.0 TV Sync:** Automatically powers on/off TV and syncs TV remote navigation.
* **RAM & ZRAM Tuning:** Optimizes memory pressure (`swappiness=100`, LZ4 compression, dirty ratios) preventing background app closure.
* **Low-Latency Wireless & BT:** Disables Wi-Fi power save and Bluetooth sniff sleep for lag-free remote control response.
* **Hardware UI Acceleration:** Forces SkiaGL multithreaded rendering and disables mobile battery/doze constraints.
* **eMMC Flash Buffering:** Increases sequential read-ahead to **1024 KB** and switches scheduler to `none`.
* **Front Panel Stealth LED Controller:** Control front LEDs via [`scripts/sei800-stealth-led.sh`](scripts/sei800-stealth-led.sh) (`off` / `heartbeat`) for dark theater viewing.
* **Universal Carrier Flag Neutralizer:** Permanently revokes operator MDM re-spawns and enables system-wide uninstall permissions.
* **SELinux Permissive:** Removes carrier restrictions globally (`setenforce 0`).

> [!TIP]
> Run [`scripts/god-mode-tweak.sh`](scripts/god-mode-tweak.sh) over ADB for instant 1-click execution of all bare-metal performance, HDR/ALLM, and debloat tweaks!

### 📦 All-in-One Flashable Magisk Module
Package the entire kernel suite, RAM LZ4 config, stealth LED binary, custom remote keylayout overlay, and boot hooks into a single ZIP:
```bash
./scripts/build-magisk-module.sh
# Outputs: output/SEI800-Clean-Suite.zip
```
Flash via Magisk Manager ➔ Modules ➔ Install from Storage for 1-click persistent installation. Includes custom keylayout for the **Claro / SEI Bluetooth Remote (`Vendor_06e7_Product_8168.kl`)** remapping live TV and shortcut keys to universal Android TV functions.

---

## 🎨 Epic Cinematic Launcher & Universal Debloat

Transform the TV Box into an Apple TV / Google TV OLED aesthetic without operator locks:
* Run [`scripts/universal-carrier-debloat.sh`](scripts/universal-carrier-debloat.sh) to permanently disable operator MDM, lockscreens, and background telemetry across **Claro, Flow, Telecentro, Vodafone, Totalplay, and Tigo** without breaking Google Play or Bluetooth remotes:
  ```bash
  ./scripts/universal-carrier-debloat.sh
  ```
* Run [`scripts/setup-projectivy-epic.sh`](scripts/setup-projectivy-epic.sh) for automated accessibility and animation tuning.
* See [docs/projectivy-epic-theme.md](docs/projectivy-epic-theme.md) for 4K dynamic backdrop blur, rounded cards, and operator home override.

---

## 📖 Deep Documentation & Forensics

- [docs/projectivy-epic-theme.md](docs/projectivy-epic-theme.md): Cinematic OLED visual theme and configuration guide.
- [docs/SEI800CCOA-stock.dts](docs/SEI800CCOA-stock.dts): Decompiled Device Tree Source (AH212 board layout, Broadcom Wi-Fi/BT, UART).
- [docs/bootloader-forensics.md](docs/bootloader-forensics.md): Step-by-step forensic register transition (`lock=10101000` ➔ `10100000`).
- [docs/runbook.md](docs/runbook.md): Full end-to-end recovery and EROFS rebuild flow.
- [docs/hardware.md](docs/hardware.md): Verified SoC, eMMC sector counts, and USB mode analysis.
- [docs/postmortem.md](docs/postmortem.md): Failure modes, SELinux labelling pitfalls, and root causes.
- [docs/timeline.md](docs/timeline.md): Chronological engineering log.
- [docs/artifact-policy.md](docs/artifact-policy.md): Privacy and proprietary code policy.

---

## ⚖️ Aviso Legal / Legal Notice

Este repositorio documenta investigaciones con propósitos educativos y de recuperación de hardware propio en desuso. No se distribuyen firmwares propietarios, claves criptográficas privadas ni software con derechos de autor protegidos. No debe ser utilizado sobre equipos pertenecientes a operadoras sin su debida autorización.
