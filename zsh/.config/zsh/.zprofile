# User specific environment
export PATH="$HOME/.local/bin:$PATH"

# Checks if you are on the first virtual terminal (tty1)
# and if a graphical session isn't already running.
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec start-hyprland
fi
