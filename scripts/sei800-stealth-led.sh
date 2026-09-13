#!/system/bin/sh
# SEI800 / S905X4 Front Panel Stealth LED Controller
# Allows turning off or adjusting front LEDs (GPIO 0x28 & 0x1C) for bedroom/theater viewing.

MODE="${1:-status}"

get_led_nodes() {
    find /sys/class/leds -maxdepth 2 -type d 2>/dev/null | grep -E "(sys|led|blue|green|red|front)" || true
}

case "$MODE" in
    off|0)
        for led in /sys/class/leds/*; do
            [ -f "$led/brightness" ] && echo 0 > "$led/brightness" 2>/dev/null
            [ -f "$led/trigger" ] && echo none > "$led/trigger" 2>/dev/null
        done
        echo "Front LEDs disabled (Stealth Cinema Mode)."
        ;;
    on|1)
        for led in /sys/class/leds/*; do
            [ -f "$led/trigger" ] && echo default-on > "$led/trigger" 2>/dev/null
            [ -f "$led/max_brightness" ] && cat "$led/max_brightness" > "$led/brightness" 2>/dev/null
        done
        echo "Front LEDs restored to default."
        ;;
    heartbeat)
        for led in /sys/class/leds/*; do
            [ -f "$led/trigger" ] && echo heartbeat > "$led/trigger" 2>/dev/null
        done
        echo "Front LEDs set to subtle heartbeat."
        ;;
    status)
        echo "Active LED nodes:"
        for led in /sys/class/leds/*; do
            if [ -d "$led" ]; then
                name=$(basename "$led")
                br="N/A"
                tr="N/A"
                [ -f "$led/brightness" ] && br=$(cat "$led/brightness" 2>/dev/null)
                [ -f "$led/trigger" ] && tr=$(cat "$led/trigger" 2>/dev/null | grep -o '\[.*\]' || echo "none")
                echo "  - $name: brightness=$br trigger=$tr"
            fi
        done
        ;;
    *)
        echo "Usage: $0 {off|on|heartbeat|status}"
        exit 1
        ;;
esac
