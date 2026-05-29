#!/bin/bash
set -e

export DISPLAY=:0
export LIBGL_ALWAYS_SOFTWARE=1
export GDK_BACKEND=x11
export NO_AT_BRIDGE=1

# ===== VNC password =====
mkdir -p /root/.vnc
if [ ! -f /root/.vnc/passwd ]; then
  printf "123456\n123456\n" | vncpasswd > /dev/null 2>&1
  chmod 600 /root/.vnc/passwd
fi

# ===== System D-Bus =====
# Flutter/GTK apps need the system bus socket, not just session bus.
# In Docker (no systemd), start it manually.
# Some Ubuntu 24.04 dbus packaging variants omit the config file — generate it.
if [ ! -f /usr/share/dbus-1/system.conf ]; then
  mkdir -p /usr/share/dbus-1
  cat > /usr/share/dbus-1/system.conf <<'DBUS_CONF'
<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>
  <type>system</type>
  <listen>unix:path=/var/run/dbus/system_bus_socket</listen>
  <policy context="default">
    <allow send_destination="*" eavesdrop="true"/>
    <allow eavesdrop="true"/>
    <allow own="*"/>
  </policy>
</busconfig>
DBUS_CONF
fi
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# ===== Xvnc: X server + VNC server in one process =====
# Display :0 → VNC port 5900 (standard convention)
# Replaces both Xvfb and x11vnc — saves ~50-150 MB runtime memory
Xvnc :0 \
  -geometry 1280x720 \
  -depth 16 \
  -localhost no \
  -rfbauth /root/.vnc/passwd \
  -BlacklistTimeout 0 \
  -SecurityTypes VncAuth &

sleep 2

# ===== Session D-Bus =====
eval "$(dbus-launch --sh-syntax)"

# ===== Minimal window manager (260 KB installed, ~3-5 MB runtime) =====
twm &

sleep 1

# ===== Display scaling =====
export GDK_SCALE=1
export QT_SCALE_FACTOR=1
export WEBKIT_FORCE_DEVICE_SCALE_FACTOR=1

# ===== App =====
exec /usr/share/FlyingBird/FlyingBird
