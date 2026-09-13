# Projectivy Launcher: Guía de Personalización "Cinematic OLED"

Configuración recomendada para transformar la interfaz del **SEI800 / S905X4** en una experiencia limpia, fluida a 60 FPS y con estética premium estilo Apple TV 4K / Google TV minimalista.

---

## ⚡ 1. Activación y Anulación del Launcher del Operador

1. Conecta tu TV Box por ADB y ejecuta el script de configuración rápida:
   ```bash
   ./scripts/setup-projectivy-epic.sh
   ```
2. En la pantalla del TV Box, abre **Projectivy Launcher**.
3. Ve a **Settings (Ajustes)** ➔ **General**:
   - Activa **"Override current launcher" (Anular launcher actual)**.
   - Si no lo hiciste por terminal, activa el **Servicio de Accesibilidad** cuando te lo solicite. Con esto, al pulsar el botón **HOME** en el control remoto responderá instantáneamente sin regresar jamás al launcher de Claro/operador.

---

## 🎨 2. Apariencia y Fondos Dinámicos 4K ("Cinematic Backdrop")

Para lograr el efecto translúcido / frosted glass de alta gama:

1. Ve a **Settings** ➔ **Appearance (Apariencia)** ➔ **Wallpaper (Fondo de pantalla)**:
   - **Wallpaper Type:** `Reddit` (o `Unsplash`).
   - **Subreddits sugeridos:** `spaceporn+EarthPorn+wallpapers+Cyberpunk`
   - **Update Interval:** `30 minutes` (o `1 hour`).
   - **Blur (Desenfocado Gaussiano):** `40% - 50%` *(clave para que los iconos resalten con nitidez)*.
   - **Dimming (Atenuación / Brillo):** `45% - 55%` *(mejora el contraste y la legibilidad de textos en paneles OLED/HDR)*.
   - **Vignette:** `Activado (Medium)`.

---

## 🔲 3. Estilo de Tarjetas y Animaciones Suaves

Aprovechando el governor de GPU a **400 MHz** que configuramos en `nexus-kernel-tweaks.sh`:

1. Ve a **Settings** ➔ **Appearance** ➔ **Cards (Tarjetas)**:
   - **Corner Radius (Radio de esquinas):** `16 dp` o `20 dp` (tarjetas redondeadas modernas).
   - **Card Elevation / Shadow:** `Activado (Soft)`.
   - **Focus Zoom (Escala al seleccionar):** `1.08x` o `1.10x`.
   - **Highlight border:** `Glow blanco sutil` o `Desactivado` para un look minimalista.
2. Ve a **Settings** ➔ **Appearance** ➔ **Animations**:
   - **Animation Speed:** `Fast / Instant (0.75x)`.

---

## 🕒 4. Barra Superior (Minimalist Status Bar)

1. Ve a **Settings** ➔ **Appearance** ➔ **Status Bar**:
   - **Clock:** `Activado` (formato 24h o 12h en la esquina superior derecha).
   - **Weather:** `Opcional` (según tu ciudad).
   - **Network & Profile icons:** `Ocultar iconos innecesarios` para dejar el encabezado 100% limpio.
   - **Status Bar Background:** `Transparent (0%)`.

---

## 📺 5. Organización de Canales y Filas

1. En la pantalla principal de Projectivy, mantén presionado el botón de selección sobre el título de cada fila para ordenar u ocultar:
   - **Fila 1 (Favoritos):** Coloca tus 5-7 apps esenciales (SmartTube, Stremio, Netflix, Plex, Kodi, Magis).
   - **Fila 2 (Seguir viendo / Watch Next):** Muestra el contenido pausado de tus apps compatibles.
   - **Fila 3 (Todas las Apps):** Cuadrícula completa de aplicaciones.
   - **Ocultar:** Elimina canales de publicidad, canales vacíos o banners patrocinados de Google TV.

---

## 🚀 Resultado
Una interfaz sin publicidad, sin telemetría de Claro, con respuesta en menos de 50 ms a cualquier comando del control remoto y fondos cinematográficos 4K rotativos con desenfoque de profundidad.
