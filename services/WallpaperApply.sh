#!/usr/bin/env bash
# Wallpaper backend switcher for Quickshell.
# Usage: WallpaperApply.sh /absolute/path/to/wallpaper
set -u

wallpaper="${1:-}"
if [[ -z "$wallpaper" || ! -f "$wallpaper" ]]; then
    echo "WallpaperService: file does not exist: $wallpaper" >&2
    exit 2
fi

base="${wallpaper##*/}"
ext="${base##*.}"
ext="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"

case "$ext" in
    mp4|webm|mkv|mov)
        # Video: stop both current engines before starting mpvpaper.
        pkill -x awww-daemon 2>/dev/null || true
        pkill -x mpvpaper 2>/dev/null || true
        sleep 0.15
        nohup mpvpaper -o 'loop hwdec=auto panscan=1.0' '*' "$wallpaper" \
            >/dev/null 2>&1 </dev/null &
        sleep 0.3
        if ! pgrep -x mpvpaper >/dev/null; then
            echo "WallpaperService: mpvpaper failed to start" >&2
            exit 3
        fi
        ;;
    png|jpg|jpeg|webp|bmp|gif)
        # Images: stop video; reuse AWWW when already running to preserve its
        # daemon and let each selected image use a fresh random transition.
        pkill -x mpvpaper 2>/dev/null || true
        if ! pgrep -x awww-daemon >/dev/null; then
            nohup awww-daemon >/dev/null 2>&1 </dev/null &
            ready=0
            for _ in $(seq 1 30); do
                if pgrep -x awww-daemon >/dev/null; then
                    ready=1
                    break
                fi
                sleep 0.1
            done
            if [[ "$ready" -ne 1 ]]; then
                echo "WallpaperService: awww-daemon failed to start" >&2
                exit 4
            fi
            sleep 0.15
        fi

        transitions=(grow wipe center left right)
        transition="${transitions[$((RANDOM % ${#transitions[@]}))]}"
        awww img "$wallpaper" \
            --transition-type "$transition" \
            --transition-fps 180 \
            --transition-duration 2.8
        ;;
    *)
        echo "WallpaperService: unsupported wallpaper format: .$ext" >&2
        exit 5
        ;;
esac
