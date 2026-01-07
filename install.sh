#!/bin/bash

# Define paths
SCRIPT_SRC="monitor.sh"
SERVICE_SRC="security-monitor.service"
TIMER_SRC="security-monitor.timer"

DEST_BIN="/usr/local/bin/monitor.sh"
DEST_SYSTEMD="/etc/systemd/system/"

# Service user configuration
SERVICE_USER="update_checker"
SUDOERS_FILE="/etc/sudoers.d/$SERVICE_USER"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "--- Starting Installation ---"

# 1. Create Service User if not exists
if id "$SERVICE_USER" &>/dev/null; then
    echo "User $SERVICE_USER already exists. Skipping creation."
else
    echo "Creating system user: $SERVICE_USER..."
    useradd -r -s /sbin/nologin -c "Update Monitor Service" $SERVICE_USER
fi

# 2. Configure Sudoers (allow dnf without password)
echo "Configuring sudo rights..."
# We use 'cat <<EOF' to write multi-line content easily
cat > $SUDOERS_FILE <<EOF
$SERVICE_USER ALL=(ALL) NOPASSWD: /usr/bin/dnf updateinfo security, /usr/bin/dnf makecache
EOF
chmod 440 $SUDOERS_FILE


# 3. Copy the monitor script
echo "Copying script to $DEST_BIN..."
cp $SCRIPT_SRC $DEST_BIN
# Set execution permissions
chmod 755 $DEST_BIN
# IMPORTANT: Script must be owned by root so the service user cannot modify it
chown root:root $DEST_BIN

# 4. Copy Systemd units
echo "Copying systemd units..."
cp $SERVICE_SRC $DEST_SYSTEMD
cp $TIMER_SRC $DEST_SYSTEMD

# 5. Reload Systemd daemon
echo "Reloading systemd daemon..."
systemctl daemon-reload

# 6. Enable and start the timer
echo "Enabling and starting the timer..."
systemctl enable --now security-monitor.timer

echo "--- Installation Complete! ---"
echo "The service runs as user: $SERVICE_USER"
echo "Check status with: systemctl list-timers"
