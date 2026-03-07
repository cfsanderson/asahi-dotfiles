# Linux Login Recovery Plan

## Background

Fedora Asahi Linux on M1 MacBook Pro. Uses greetd + tuigreet as login manager on vt=1, launching Hyprland. After migrating dotfiles from `arch-dotfiles` to `asahi-dotfiles` and a battery death mid-session, login fails with an auth error after entering the password.

Config fixes for remaining stale `arch-dotfiles` references have been pushed to PR #1: https://github.com/cfsanderson/asahi-dotfiles/pull/1

---

## Step 1: Get to a TTY

greetd runs on vt=1. Other virtual terminals should be free.

At the tuigreet login screen, try these key combos to switch to tty2:
- `Fn + Ctrl + Option + F2`
- `Ctrl + Option + F2`
- `Ctrl + Alt + F2` (if using an external keyboard)

You should get a plain text login prompt. Log in with your username and password.

---

## Step 2: Diagnose

Once logged in on tty2, run these in order:

```bash
# Check if filesystem is read-only (most likely cause after hard shutdown)
mount | grep ' / '
# Look for "ro" in the mount options — if present, that's the problem

# Check for filesystem/kernel errors
sudo dmesg | grep -i -E 'error|corrupt|readonly|read-only'

# Check SELinux status (Fedora enforcing mode can block login after corruption)
getenforce

# Check greetd/Hyprland logs from the failed session
journalctl -b -p err --no-pager | tail -40

# Check if dotfile symlinks are intact
ls -la ~/.config/hypr/
ls -la ~/.config/zsh/.zshrc
ls -la ~/Projects/asahi-dotfiles/

# Try starting Hyprland manually to see what error it gives
# (only do this from a non-graphical tty)
Hyprland 2>&1 | head -50
```

---

## Step 3: Fix based on diagnosis

### If filesystem is read-only:
```bash
sudo mount -o remount,rw /
sudo reboot
```

### If SELinux is blocking:
```bash
# Temporarily set permissive mode
sudo setenforce 0
# Try logging in via greetd again. If it works, do a full relabel:
sudo fixfiles -F onboot
sudo reboot
```

### If symlinks are broken (pointing to deleted arch-dotfiles):
```bash
cd ~/Projects/asahi-dotfiles
stow -R -t $HOME */
```

### If tty2 login also fails with auth error:
Boot with modified kernel parameters:
1. At the boot menu, press `e` to edit the boot entry
2. Find the `linux` line and append: `single` (or `rescue`)
3. Press `Ctrl+X` to boot into single-user/rescue mode
4. From there fix the filesystem: `fsck -y /dev/<root-partition>`

### If all else fails — live USB recovery:
Boot a Fedora live USB, mount the Asahi partition, and fix things from there.

---

## Step 4: Pull config fixes

Once you can log in, merge the PR that fixes remaining `arch-dotfiles` references:

```bash
cd ~/Projects/asahi-dotfiles
git fetch origin
gh pr merge 1 --merge
# or: git merge origin/claude/romantic-kapitsa
```

Then re-stow:
```bash
stowr
```

---

## Step 5: Verify

```bash
# Check for any remaining stale references
grep -r "arch-dotfiles" ~/Projects/asahi-dotfiles/ --include='*.css' --include='*.sh' --include='*.toml' --include='*.conf'

# Check Hyprland logs for errors
journalctl --user -b | grep -i error

# Test wofi theme loads correctly
# Press Super+Space
```

Reboot once more to confirm clean login through greetd.
