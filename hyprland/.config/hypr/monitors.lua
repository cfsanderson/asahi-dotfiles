-- Mac Mini (M2) + single external monitor via KVM.
--
-- Monitor is a Dell U2725QE, native 3840x2160 (4K), not 5120x2880 -- confirmed
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
-- KVM switches can cause the monitor to enumerate under a different port name
-- between boots, or look like a disconnect/reconnect when you switch inputs
-- away and back. Matching by `desc:` (EDID description) survives that; matching
-- by port name (DP-1, HDMI-A-1) does not. Swap the line below once you have
-- the description string, e.g.:
--   output = "desc:LG Electronics LG Ultrafine"

hl.monitor({
	output = "HDMI-A-1",
	mode = "3840x2160@60",
	position = "0x0",
	scale = "1.5",
})
