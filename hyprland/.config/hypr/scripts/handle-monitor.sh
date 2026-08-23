#!/bin/bash
# Single-monitor workspace arrangement for Hyprland, with KVM reconnect handling.
#
# The Mac Mini has exactly one display, switched via a KVM. Hyprland may see
# that as a monitor disconnect/reconnect each time the KVM switches away and
# back. This listens for those events and re-pins all 10 workspaces to the
# monitor whenever it reappears.
#
# Usage:
#   handle-monitor.sh listen       - Background listener for monitor hotplug events
#   handle-monitor.sh arrange      - One-shot workspace arrangement
#   handle-monitor.sh switch N     - Switch to workspace N on its assigned monitor
#   handle-monitor.sh movetoworkspace N - Move active window to workspace N on its assigned monitor
#
# NOTE: Do NOT use `hyprctl keyword workspace` rules — they poison the workspace
# dispatcher and override focusmonitor for all future workspace creation.
# Instead, rely solely on focusmonitor + workspace dispatch + moveworkspacetomonitor.
#
# NOTE: Hyprland's config is Lua now (hyprland.lua), and under Lua config mode
# `hyprctl dispatch` takes a Lua expression (auto-wrapped in hl.dispatch(...)),
# not the old `dispatch <name> <args>` string form -- e.g.
# `hyprctl dispatch 'hl.dsp.focus({ workspace = "2" })'` instead of
# `hyprctl dispatch workspace 2`.

set -euo pipefail

ALL_WORKSPACES=(1 2 3 4 5)

# Throttle: ignore rapid-fire events within this window (seconds)
THROTTLE_SECONDS=3
LAST_RUN=0

# Get the (only) connected monitor's name
active_monitor() {
    hyprctl monitors -j | jq -r '.[0].name // empty'
}

# Get the monitor a workspace should live on
target_monitor() {
    active_monitor
}

arrange_workspaces() {
    local monitors
    monitors=$(hyprctl monitors -j)

    local mon
    mon=$(echo "$monitors" | jq -r '.[0].name // empty')
    [[ -z "$mon" ]] && return 0

    # Save active workspace per monitor to restore after rearranging
    local active_workspaces
    active_workspaces=$(echo "$monitors" | jq -r '.[] | "\(.name):\(.activeWorkspace.id)"')

    for ws in "${ALL_WORKSPACES[@]}"; do
        hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$ws\", monitor = \"$mon\" })" > /dev/null 2>&1
    done

    # Restore previously active workspaces
    while IFS= read -r line; do
        local mon_name=${line%%:*}
        local ws_id=${line##*:}
        if echo "$monitors" | jq -e ".[] | select(.name == \"$mon_name\")" > /dev/null 2>&1; then
            hyprctl dispatch "hl.dsp.focus({ monitor = \"$mon_name\" })" > /dev/null 2>&1
            hyprctl dispatch "hl.dsp.focus({ workspace = \"$ws_id\" })" > /dev/null 2>&1
        fi
    done <<< "$active_workspaces"
}

# Switch to a workspace on its assigned monitor (used by keybindings)
switch_workspace() {
    local ws=$1
    local mon
    mon=$(target_monitor "$ws")
    hyprctl --batch "dispatch hl.dsp.focus({ monitor = \"$mon\" }); dispatch hl.dsp.focus({ workspace = \"$ws\" })" > /dev/null 2>&1
}

# Move active window to workspace on its assigned monitor (used by keybindings)
move_to_workspace() {
    local ws=$1
    hyprctl dispatch "hl.dsp.window.move({ workspace = \"$ws\" })" > /dev/null 2>&1
}

listen() {
    local socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

    socat -u "UNIX-CONNECT:$socket" - | while IFS= read -r line; do
        case "$line" in
            monitoradded*|monitorremoved*)
                local now
                now=$(date +%s)
                if (( now - LAST_RUN >= THROTTLE_SECONDS )); then
                    LAST_RUN=$now
                    sleep 1
                    arrange_workspaces
                fi
                ;;
        esac
    done
}

case "${1:-}" in
    arrange) arrange_workspaces ;;
    listen) listen ;;
    switch) switch_workspace "${2:?workspace number required}" ;;
    movetoworkspace) move_to_workspace "${2:?workspace number required}" ;;
    *)
        echo "Usage: $0 [arrange|listen|switch N|movetoworkspace N]"
        exit 1
        ;;
esac
