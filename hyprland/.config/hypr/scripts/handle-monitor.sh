#!/bin/bash
# Workspace arrangement for Hyprland with single/dual monitor profiles and KVM
# reconnect handling.
#
# Primary: Dell U2725QE on HDMI-A-1 (shared with the other computer via its
# built-in KVM). Secondary: Dell U2720QM, to the right of the primary, which
# will arrive over USB-C DisplayPort Alt Mode once Asahi supports it (as of
# kernel 7.2.12 it does not -- the second DCP is disabled in the device tree,
# so only HDMI-A-1 exists). Until then this always resolves to `single`.
#
# Profiles:
#   single - workspaces 1-10 on the primary (secondary disabled if forced)
#   dual   - workspaces 1-5 on the primary, 6-10 on the secondary
# The profile is picked automatically from which outputs exist; `profile`
# forces one until `profile auto` or reboot (state lives in XDG_RUNTIME_DIR).
#
# apple-dcp never exposes EDID, so monitor descriptions are empty and `desc:`
# matching doesn't work -- the secondary is "any output that isn't the
# primary", optionally narrowed by the SECONDARY_MATCH regex (matched against
# name and description; e.g. SECONDARY_MATCH=HEADLESS for testing with
# `hyprctl output create headless`).
#
# Usage:
#   handle-monitor.sh listen       - Background listener for monitor hotplug events
#   handle-monitor.sh arrange      - One-shot workspace arrangement
#   handle-monitor.sh switch N     - Switch to workspace N on its assigned monitor
#   handle-monitor.sh movetoworkspace N - Move active window to workspace N on its assigned monitor
#   handle-monitor.sh profile single|dual|auto|cycle - Force/clear a profile
#   handle-monitor.sh status       - Print forced/effective profile and outputs
#
# NOTE: Do NOT use `hyprctl keyword workspace` rules — they poison the workspace
# dispatcher and override focusmonitor for all future workspace creation.
# Instead, rely solely on focusmonitor + workspace dispatch + moveworkspacetomonitor.
#
# NOTE: Hyprland's config is Lua now (hyprland.lua), and under Lua config mode
# `hyprctl dispatch` takes a Lua expression (auto-wrapped in hl.dispatch(...)),
# not the old `dispatch <name> <args>` string form -- e.g.
# `hyprctl dispatch 'hl.dsp.focus({ workspace = "2" })'` instead of
# `hyprctl dispatch workspace 2`. Runtime monitor changes go through
# `hyprctl eval 'hl.monitor({ ... })'`.

set -euo pipefail

PRIMARY_OUTPUT="HDMI-A-1"
SECONDARY_MATCH="${SECONDARY_MATCH:-}"
# Must match the secondary rule in monitors.lua
SECONDARY_RULE='mode = "preferred", position = "2560x0", scale = "1.5"'

ALL_WORKSPACES=(1 2 3 4 5 6 7 8 9 10)
SECONDARY_WORKSPACES_FROM=6

PROFILE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-monitor-profile"

# Throttle: ignore rapid-fire events within this window (seconds)
THROTTLE_SECONDS=3
LAST_RUN=0

# Enabled monitors only
active_monitors_json() {
    hyprctl monitors -j
}

# Includes disabled monitors
all_monitors_json() {
    hyprctl monitors all -j
}

# The primary if it's up, otherwise whatever is (e.g. KVM switched away from
# HDMI while the secondary stays lit)
primary_monitor() {
    active_monitors_json | jq -r --arg p "$PRIMARY_OUTPUT" \
        'if any(.[]; .name == $p) then $p else (.[0].name // empty) end'
}

# Name of the secondary output (enabled or not), or empty
secondary_monitor() {
    local primary
    primary=$(primary_monitor)
    all_monitors_json | jq -r --arg p "$primary" --arg m "$SECONDARY_MATCH" \
        '[.[] | select(.name != $p)
              | select($m == "" or (.name | test($m)) or (.description | test($m)))]
         | .[0].name // empty'
}

secondary_enabled() {
    local sec=$1
    active_monitors_json | jq -e --arg s "$sec" 'any(.[]; .name == $s)' > /dev/null
}

forced_profile() {
    cat "$PROFILE_FILE" 2>/dev/null || echo auto
}

# single|dual, from the forced profile and which outputs exist
effective_profile() {
    local sec
    sec=$(secondary_monitor)
    [[ -z "$sec" ]] && { echo single; return; }
    case "$(forced_profile)" in
        single) echo single ;;
        *) echo dual ;;
    esac
}

# Get the monitor a workspace should live on
target_monitor() {
    local ws=$1
    if [[ "$(effective_profile)" == dual ]] && (( ws >= SECONDARY_WORKSPACES_FROM )); then
        secondary_monitor
    else
        primary_monitor
    fi
}

# Enable/disable the secondary to match the effective profile
apply_outputs() {
    local sec
    sec=$(secondary_monitor)
    [[ -z "$sec" ]] && return 0

    if [[ "$(effective_profile)" == single ]]; then
        if secondary_enabled "$sec"; then
            hyprctl eval "hl.monitor({ output = \"$sec\", disabled = true })" > /dev/null
            sleep 1
        fi
    elif ! secondary_enabled "$sec"; then
        hyprctl eval "hl.monitor({ output = \"$sec\", disabled = false, $SECONDARY_RULE })" > /dev/null
        sleep 1
    fi
}

arrange_workspaces() {
    local monitors
    monitors=$(active_monitors_json)

    local primary
    primary=$(primary_monitor)
    [[ -z "$primary" ]] && return 0

    # Save active workspace per monitor (and the focused monitor) to restore
    # after rearranging
    local active_workspaces focused
    active_workspaces=$(echo "$monitors" | jq -r '.[] | "\(.name):\(.activeWorkspace.id)"')
    focused=$(echo "$monitors" | jq -r '.[] | select(.focused) | .name')

    # A newly connected monitor gets whatever free workspace Hyprland picks
    # (e.g. 3), and a monitor's only workspace can't be moved off it -- so put
    # the secondary on its own first workspace before moving the rest.
    local sec=""
    if [[ "$(effective_profile)" == dual ]]; then
        sec=$(secondary_monitor)
        local sec_ws
        sec_ws=$(echo "$monitors" | jq -r --arg s "$sec" '.[] | select(.name == $s) | .activeWorkspace.id')
        if [[ -n "$sec_ws" ]] && (( sec_ws < SECONDARY_WORKSPACES_FROM )); then
            hyprctl --batch "dispatch hl.dsp.focus({ monitor = \"$sec\" }); dispatch hl.dsp.focus({ workspace = \"$SECONDARY_WORKSPACES_FROM\" })" > /dev/null 2>&1
        fi
    fi

    for ws in "${ALL_WORKSPACES[@]}"; do
        hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$ws\", monitor = \"$(target_monitor "$ws")\" })" > /dev/null 2>&1 || true
    done

    # Restore previously active workspaces, where they still belong there
    while IFS= read -r line; do
        local mon_name=${line%%:*}
        local ws_id=${line##*:}
        [[ "$(target_monitor "$ws_id")" == "$mon_name" ]] || continue
        hyprctl --batch "dispatch hl.dsp.focus({ monitor = \"$mon_name\" }); dispatch hl.dsp.focus({ workspace = \"$ws_id\" })" > /dev/null 2>&1
    done <<< "$active_workspaces"

    if [[ -n "$focused" ]] && active_monitors_json | jq -e --arg f "$focused" 'any(.[]; .name == $f)' > /dev/null; then
        hyprctl dispatch "hl.dsp.focus({ monitor = \"$focused\" })" > /dev/null 2>&1
    fi
}

apply_profile() {
    apply_outputs
    arrange_workspaces
}

set_profile() {
    local profile=$1
    if [[ "$profile" == cycle ]]; then
        case "$(forced_profile)" in
            auto) profile=single ;;
            single) profile=dual ;;
            *) profile=auto ;;
        esac
    fi

    case "$profile" in
        auto) rm -f "$PROFILE_FILE" ;;
        single|dual) echo "$profile" > "$PROFILE_FILE" ;;
        *) echo "Unknown profile: $profile" >&2; exit 1 ;;
    esac

    apply_profile

    local msg="Profile: $profile (now $(effective_profile))"
    [[ -z "$(secondary_monitor)" ]] && msg="$msg — no second monitor detected"
    notify-send -a "Monitors" "Monitor layout" "$msg" 2>/dev/null || true
    echo "$msg"
}

status() {
    echo "forced:    $(forced_profile)"
    echo "effective: $(effective_profile)"
    echo "primary:   $(primary_monitor)"
    echo "secondary: $(secondary_monitor)"
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
                    apply_profile
                fi
                ;;
        esac
    done
}

case "${1:-}" in
    arrange) apply_profile ;;
    listen) listen ;;
    switch) switch_workspace "${2:?workspace number required}" ;;
    movetoworkspace) move_to_workspace "${2:?workspace number required}" ;;
    profile) set_profile "${2:?single|dual|auto|cycle required}" ;;
    status) status ;;
    *)
        echo "Usage: $0 [arrange|listen|switch N|movetoworkspace N|profile single|dual|auto|cycle|status]"
        exit 1
        ;;
esac
