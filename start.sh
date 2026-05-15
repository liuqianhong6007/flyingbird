#!/bin/bash
set -e

export DISPLAY=:99
export LIBGL_ALWAYS_SOFTWARE=1
export GDK_BACKEND=x11
export NO_AT_BRIDGE=1

rm -f /tmp/.X99-lock

# ===== Xvfb =====
Xvfb :99 \
  -screen 0 1600x900x24 \
  -ac \
  +extension GLX \
  +render \
  -dpi 110 \
  -nolisten tcp \
  -noreset &

sleep 2

# ===== DBus MUST be first =====
eval "$(dbus-launch --sh-syntax)"

# ===== Window manager =====
openbox-session &

sleep 1

# ===== VNC password =====
mkdir -p /root/.vnc
if [ ! -f /root/.vnc/passwd ]; then
  x11vnc -storepasswd 123456 /root/.vnc/passwd
  chmod 600 /root/.vnc/passwd
fi

# ===== VNC =====
x11vnc \
  -display :99 \
  -rfbauth /root/.vnc/passwd \
  -forever \
  -shared \
  -xkb \
  -noxdamage \
  -ncache 0 \
  -rfbport 5900 \
  -listen 0.0.0.0 &

# ===== Scaling (choose ONE strategy) =====
export GDK_SCALE=1
export QT_SCALE_FACTOR=1
export WEBKIT_FORCE_DEVICE_SCALE_FACTOR=1

# ===== App =====
exec /usr/share/FlyingBird/FlyingBird
