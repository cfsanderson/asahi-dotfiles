-- Mac Mini (M2): Dell U2725QE (primary, HDMI via its built-in KVM) + Dell
-- U2720QM (secondary, to the right) once USB-C DisplayPort Alt Mode works.
--
-- SECONDARY STATUS (2026-11-07): USB-C video does NOT work on this machine yet.
-- The M2 has two DCPs, but the device tree ships dcp@231c00000 disabled and only
-- dcpext (dcp@271c00000) is wired up -- to the HDMI port. DRM exposes just
-- HDMI-A-1. Still true on kernel 7.2.12; DP Alt Mode is WIP upstream (Asahi
-- `fairydust` branch). Re-check after kernel updates with
-- `ls /sys/class/drm/` -- a new DP connector there means it's landed.
--
-- Primary: Dell U2725QE, native 3840x2160 (4K), not 5120x2880 -- confirmed
-- via `hyprctl monitors -j` .availableModes. 2560x1440 is NOT a native mode
-- here despite being EDID-advertised: feeding it that timing produces a clean,
-- correctly-timed signal (verified via `journalctl` apple-dcp mode_set_gated
-- log -- no driver errors, standard CVT-RB2 timing), but the monitor's own
-- scaler visibly stretches/blurs it across the full 4K panel. Confirmed by
-- direct comparison on this exact hardware -- not a Hyprland/DCP bug. So:
-- render at native 3840x2160 and let Hyprland's compositor scale down 1.5x to
-- reach the same logical 2560x1440 (matches the MacBook Pro's logical size on
-- the same monitor), which stays sharp.
--
-- 120Hz is NOT reachable at 4K on this machine: no 3840x2160@120 mode is ever
-- advertised in .availableModes over this HDMI link. `journalctl -b | grep
-- mode_set_gated` shows the Apple DCP driver negotiating a classic-TMDS 4K@60
-- link (594MHz pixel clock, ~HDMI 2.0's ~18Gbps ceiling) with no FRL
-- (HDMI 2.1's higher-bandwidth mode) negotiation anywhere in the log. This is
-- a current Asahi DCP driver limitation (no FRL support yet), independent of
-- the KVM/cable -- not fixable from Hyprland config. Revisit if/when Asahi's
-- DCP driver adds HDMI 2.1 FRL support.
--
-- apple-dcp never exposes EDID, so `hyprctl monitors` descriptions are empty
-- and `desc:` matching does NOT work here -- match by port name instead.
-- KVM switches can look like a disconnect/reconnect; scripts/handle-monitor.sh
-- re-pins workspaces on those events and handles single/dual profiles
-- (SUPER+CTRL+M cycles auto -> single -> dual).

hl.monitor({
	output = "HDMI-A-1",
	mode = "3840x2160@60",
	position = "0x0",
	scale = "1.5",
})

-- Secondary (U2720QM, 4K): catch-all for any output not matched above, since
-- its connector name under Asahi DP Alt Mode isn't known yet. Same logical
-- 2560x1440 as the primary, flush to its right. Keep in sync with
-- SECONDARY_RULE in scripts/handle-monitor.sh.
hl.monitor({
	output = "",
	mode = "preferred",
	position = "2560x0",
	scale = "1.5",
})
