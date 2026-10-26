pragma Singleton
import QtQuick
import Quickshell.Io

// Live system telemetry for StatsBlock.qml.
// Metrics that the host does not expose remain null rather than pretending to be 0.
QtObject {
    id: root

    property real cpuPercent: 0
    property real cpuTempC: -1
    property real gpuPercent: -1
    property real gpuTempC: -1
    property real ramUsedPercent: 0
    property real ramUsedGiB: 0
    property real ramTotalGiB: 0
    property real vramUsedPercent: -1
    property real vramUsedGiB: -1
    property real vramTotalGiB: -1
    property real swapUsedPercent: -1
    property real swapTotalGiB: 0
    property real diskUsedPercent: 0
    property real diskUsedGiB: 0
    property real diskAvailableGiB: 0
    property real diskTotalGiB: 0
    property real diskReadMiBs: 0
    property real diskWriteMiBs: 0
    property real networkRxMiBs: 0
    property real networkTxMiBs: 0
    property bool ready: false
    property string gpuName: ""
    property string networkInterface: ""
    property string diskMount: "/"
    property string lastUpdated: ""

    readonly property string _collectorScript: String.raw`
set -u

# CPU usage: compare two /proc/stat snapshots to avoid stale or synthetic readings.
read_cpu() { awk '/^cpu / { idle=$5+$6; total=0; for (i=2;i<=NF;i++) total+=$i; print total, idle; exit }' /proc/stat; }
read -r cpu_total_a cpu_idle_a < <(read_cpu)
sleep 0.18
read -r cpu_total_b cpu_idle_b < <(read_cpu)
cpu_pct=0
if [[ -n "${"$"}{cpu_total_a:-}" && -n "${"$"}{cpu_total_b:-}" ]]; then
  dt=$((cpu_total_b-cpu_total_a)); di=$((cpu_idle_b-cpu_idle_a))
  (( dt > 0 )) && cpu_pct=$(awk -v d="$dt" -v i="$di" 'BEGIN {v=100*(d-i)/d; if(v<0)v=0;if(v>100)v=100;printf "%.1f",v}')
fi

# RAM and swap from procfs (kB -> GiB).
mem_values=$(awk '
  /^MemTotal:/ {mt=$2} /^MemAvailable:/ {ma=$2} /^SwapTotal:/ {st=$2} /^SwapFree:/ {sf=$2}
  END {printf "%d %d %d %d\n", mt-ma, mt, st-sf, st} ' /proc/meminfo)
read -r ram_used ram_total swap_used swap_total <<< "$mem_values"
ram_pct=$(awk -v u="$ram_used" -v t="$ram_total" 'BEGIN{printf "%.1f", (t>0 ? 100*u/t : 0)}')
ram_used_g=$(awk -v n="$ram_used" 'BEGIN{printf "%.2f",n/1048576}')
ram_total_g=$(awk -v n="$ram_total" 'BEGIN{printf "%.2f",n/1048576}')
swap_pct=-1
if (( swap_total > 0 )); then swap_pct=$(awk -v u="$swap_used" -v t="$swap_total" 'BEGIN{printf "%.1f",100*u/t}'); fi
swap_total_g=$(awk -v n="$swap_total" 'BEGIN{printf "%.2f",n/1048576}')

# Root filesystem usage.
disk_values=$(df -Pk / 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5); printf "%s %.2f %.2f %.2f\n", $5, $3/1048576, $4/1048576, $2/1048576}')
read -r disk_pct disk_used_g disk_available_g disk_total_g <<< "$disk_values"
[[ "${"$"}{disk_pct:-}" =~ ^[0-9]+$ ]] || disk_pct=0
: "${"$"}{disk_used_g:=0}" "${"$"}{disk_available_g:=0}" "${"$"}{disk_total_g:=0}"

# Disk I/O rate for the physical device backing / (MiB/s).
# Resolve the root mount's partition to its parent disk to avoid double-counting.
disk_read=0; disk_write=0; root_source=$(findmnt -n -o SOURCE / 2>/dev/null || true)
root_name=$(basename "$root_source" | sed 's/\[.*$//')
root_parent=$(lsblk -ndo PKNAME "$root_source" 2>/dev/null | head -n1 || true)
disk_name=${"$"}{root_parent:-$root_name}
if [[ -n "$disk_name" ]]; then
  disk_now=$(awk -v d="$disk_name" '$3==d {printf "%s %s",$6,$10; exit}' /proc/diskstats)
  disk_state="${"$"}{TMPDIR:-/tmp}/quickshell-diskstats-${"$"}{UID}-${"$"}{disk_name}"
  now_disk=$(date +%s%N 2>/dev/null || date +%s000000000)
  if [[ -n "$disk_now" && -r "$disk_state" ]]; then
    read -r old_read old_write old_time < "$disk_state" || true
    read -r cur_read cur_write <<< "$disk_now"
    disk_read=$(awk -v n="$cur_read" -v o="${"$"}{old_read:-$cur_read}" -v t="$now_disk" -v ot="${"$"}{old_time:-$now_disk}" 'BEGIN{d=(t-ot)/1000000000;if(d<=0)d=1.5;v=(n-o)*512/d/1048576;if(v<0)v=0;printf "%.2f",v}')
    disk_write=$(awk -v n="$cur_write" -v o="${"$"}{old_write:-$cur_write}" -v t="$now_disk" -v ot="${"$"}{old_time:-$now_disk}" 'BEGIN{d=(t-ot)/1000000000;if(d<=0)d=1.5;v=(n-o)*512/d/1048576;if(v<0)v=0;printf "%.2f",v}')
  fi
  if [[ -n "$disk_now" ]]; then read -r cur_read cur_write <<< "$disk_now"; printf '%s %s %s\n' "$cur_read" "$cur_write" "$now_disk" > "$disk_state" 2>/dev/null || true; fi
fi

# Select the first non-loopback interface with a sysfs device; rate uses a small state file.
rx=0; tx=0; iface=""
# Prefer an interface that is actually operational, not merely present.
for p in /sys/class/net/*; do
  [[ -e "$p" ]] || continue
  n=${"$"}{p##*/}; [[ "$n" == lo ]] && continue
  oper=$(cat "$p/operstate" 2>/dev/null || true)
  carrier=$(cat "$p/carrier" 2>/dev/null || true)
  if [[ "$oper" == up && ( "$carrier" == 1 || ! -e "$p/carrier" ) ]]; then iface=$n; break; fi
done
# Fallback to any non-loopback interface if none reports operational state.
if [[ -z "$iface" ]]; then
  for p in /sys/class/net/*; do n=${"$"}{p##*/}; [[ "$n" == lo ]] && continue; iface=$n; break; done
fi
if [[ -n "$iface" ]]; then
  rx_now=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null || echo 0)
  tx_now=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null || echo 0)
  state="${"$"}{TMPDIR:-/tmp}/quickshell-systemstats-${"$"}{UID}-${"$"}{iface}"
  now=$(date +%s%N 2>/dev/null || date +%s000000000)
  if [[ -r "$state" ]]; then
    read -r old_rx old_tx old_time < "$state" || true
    elapsed=$(awk -v n="$now" -v o="${"$"}{old_time:-$now}" 'BEGIN{d=(n-o)/1000000000; if(d<0.05)d=0.05; printf "%.6f",d}')
    rx=$(awk -v n="$rx_now" -v o="${"$"}{old_rx:-$rx_now}" -v d="$elapsed" 'BEGIN{v=(n-o)/d/1048576;if(v<0)v=0;printf "%.2f",v}')
    tx=$(awk -v n="$tx_now" -v o="${"$"}{old_tx:-$tx_now}" -v d="$elapsed" 'BEGIN{v=(n-o)/d/1048576;if(v<0)v=0;printf "%.2f",v}')
  fi
  printf '%s %s %s\n' "$rx_now" "$tx_now" "$now" > "$state" 2>/dev/null || true
fi

# GPU telemetry: prefer AMD DRM sysfs (RX cards expose gpu_busy_percent and mem_info_*).
gpu_pct=-1; vram_used=-1; vram_total=-1; gpu_name=""; gpu_temp=-1
for d in /sys/class/drm/card[0-9]*; do
  [[ -d "$d/device" ]] || continue
  dev="$d/device"
  [[ -r "$dev/vendor" ]] || continue
  vendor=$(cat "$dev/vendor" 2>/dev/null || true)
  [[ "$vendor" == "0x1002" ]] || continue
  [[ -r "$dev/gpu_busy_percent" ]] && gpu_pct=$(cat "$dev/gpu_busy_percent" 2>/dev/null || echo -1)
  [[ -r "$dev/mem_info_vram_used" ]] && vram_used=$(cat "$dev/mem_info_vram_used" 2>/dev/null || echo -1)
  [[ -r "$dev/mem_info_vram_total" ]] && vram_total=$(cat "$dev/mem_info_vram_total" 2>/dev/null || echo -1)
  if command -v lspci >/dev/null 2>&1; then
    gpu_name=$(lspci -s "$(basename "$d" | sed 's/card//')" 2>/dev/null | sed 's/^[^ ]* //')
  fi
  # Find a GPU hwmon temperature, if available.
  for h in "$dev"/hwmon/hwmon*; do
    [[ -d "$h" ]] || continue
    for tf in "$h"/temp*_input; do
      [[ -r "$tf" ]] || continue
      tv=$(cat "$tf" 2>/dev/null || echo 0)
      if [[ "$tv" =~ ^[0-9]+$ ]] && (( tv > 0 )); then gpu_temp=$(awk -v n="$tv" 'BEGIN{printf "%.1f",n/1000}'); break 2; fi
    done
  done
  break
done
[[ "$gpu_pct" =~ ^[0-9]+([.][0-9]+)?$ ]] || gpu_pct=-1
[[ "$vram_used" =~ ^[0-9]+$ ]] || vram_used=-1
[[ "$vram_total" =~ ^[0-9]+$ ]] || vram_total=-1
if (( vram_used >= 0 )); then vram_used_g=$(awk -v n="$vram_used" 'BEGIN{printf "%.2f",n/1073741824}'); else vram_used_g=-1; fi
if (( vram_total > 0 )); then
  vram_total_g=$(awk -v n="$vram_total" 'BEGIN{printf "%.2f",n/1073741824}')
  vram_pct=$(awk -v u="$vram_used" -v t="$vram_total" 'BEGIN{printf "%.1f", (t>0 ? 100*u/t : 0)}')
else vram_total_g=-1; vram_pct=-1; fi

# CPU temperature: scan hwmon labels, prefer packages/Tctl/Tdie, fallback to first valid temp.
cpu_temp=-1; fallback=-1
for h in /sys/class/hwmon/hwmon*; do
  [[ -d "$h" ]] || continue
  label=""
  [[ -r "$h/name" ]] && label=$(cat "$h/name" 2>/dev/null || true)
  [[ "$label" == *amdgpu* ]] && continue
  for tf in "$h"/temp*_input; do
    [[ -r "$tf" ]] || continue
    tv=$(cat "$tf" 2>/dev/null || echo 0)
    [[ "$tv" =~ ^[0-9]+$ ]] || continue
    (( tv > 0 )) || continue
    val=$(awk -v n="$tv" 'BEGIN{printf "%.1f",n/1000}')
    [[ -z "$fallback" || "$fallback" == "-1" ]] && fallback=$val
    tl=""
    label_file="${"$"}{tf%_input}_label"
    [[ -r "$label_file" ]] && tl=$(cat "$label_file" 2>/dev/null || true)
    if [[ "$tl $label" =~ (Tctl|Tdie|Package|CPU) ]]; then cpu_temp=$val; break 2; fi
  done
done
[[ "$cpu_temp" == "-1" ]] && cpu_temp=${"$"}{fallback:--1}

printf 'cpuPercent=%s\n' "$cpu_pct"
printf 'cpuTempC=%s\n' "$cpu_temp"
printf 'gpuPercent=%s\n' "$gpu_pct"
printf 'gpuTempC=%s\n' "$gpu_temp"
printf 'ramUsedPercent=%s\n' "$ram_pct"
printf 'ramUsedGiB=%s\n' "$ram_used_g"
printf 'ramTotalGiB=%s\n' "$ram_total_g"
printf 'swapUsedPercent=%s\n' "$swap_pct"
printf 'swapTotalGiB=%s\n' "$swap_total_g"
printf 'diskUsedPercent=%s\n' "$disk_pct"
printf 'diskUsedGiB=%s\n' "$disk_used_g"
printf 'diskAvailableGiB=%s\n' "$disk_available_g"
printf 'diskTotalGiB=%s\n' "$disk_total_g"
printf 'diskReadMiBs=%s\n' "$disk_read"
printf 'diskWriteMiBs=%s\n' "$disk_write"
printf 'networkRxMiBs=%s\n' "$rx"
printf 'networkTxMiBs=%s\n' "$tx"
printf 'networkInterface=%s\n' "$iface"
printf 'gpuName=%s\n' "$gpu_name"
printf 'vramUsedPercent=%s\n' "$vram_pct"
printf 'vramUsedGiB=%s\n' "$vram_used_g"
printf 'vramTotalGiB=%s\n' "$vram_total_g"
`

    property var collector: Process {
        command: ["bash", "-c", root._collectorScript]
        stdout: SplitParser {
            onRead: (line) => {
                var splitAt = line.indexOf("=")
                if (splitAt < 1)
                    return
                var key = line.substring(0, splitAt)
                var raw = line.substring(splitAt + 1)
                var n = Number(raw)
                switch (key) {
                case "cpuPercent": root.cpuPercent = n; break
                case "cpuTempC": root.cpuTempC = n; break
                case "gpuPercent": root.gpuPercent = n; break
                case "gpuTempC": root.gpuTempC = n; break
                case "ramUsedPercent": root.ramUsedPercent = n; break
                case "ramUsedGiB": root.ramUsedGiB = n; break
                case "ramTotalGiB": root.ramTotalGiB = n; break
                case "swapUsedPercent": root.swapUsedPercent = n; break
                case "swapTotalGiB": root.swapTotalGiB = n; break
                case "diskUsedPercent": root.diskUsedPercent = n; break
                case "diskUsedGiB": root.diskUsedGiB = n; break
                case "diskAvailableGiB": root.diskAvailableGiB = n; break
                case "diskTotalGiB": root.diskTotalGiB = n; break
                case "diskReadMiBs": root.diskReadMiBs = n; break
                case "diskWriteMiBs": root.diskWriteMiBs = n; break
                case "networkRxMiBs": root.networkRxMiBs = n; break
                case "networkTxMiBs": root.networkTxMiBs = n; break
                case "networkInterface": root.networkInterface = raw; break
                case "gpuName": root.gpuName = raw; break
                case "vramUsedPercent": root.vramUsedPercent = n; break
                case "vramUsedGiB": root.vramUsedGiB = n; break
                case "vramTotalGiB": root.vramTotalGiB = n; break
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            root.ready = exitCode === 0
            root.lastUpdated = new Date().toLocaleTimeString()
        }
    }

    property Timer refreshTimer: Timer {
        interval: 1500
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!root.collector.running)
                root.collector.running = true
        }
    }
}
