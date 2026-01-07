# RHEL Security Update Monitor

A lightweight, automated solution for monitoring security advisories on RHEL-based systems (AlmaLinux, Rocky Linux, CentOS Stream, RHEL).

This tool periodically checks for critical security updates using `dnf` and logs the status to the system journal (`journald`). It follows system administration best practices by utilizing **Systemd Timers** for scheduling and a **dedicated service account** for execution to ensure the Principle of Least Privilege.

## 🚀 Features

* **Automated Monitoring:** Runs automatically every 24 hours via Systemd Timer.
* **Security Focused:** Filters specific security patches (ignoring general bug fixes).
* **Least Privilege:** Runs as a restricted service user (`update_checker`), not root.
* **Standard Logging:** Integrates natively with `journald` (syslog).
* **Easy Deployment:** Includes an automated installation script.

## 📋 Prerequisites

* **OS:** AlmaLinux 8/9, RHEL 8/9, Rocky Linux, or CentOS Stream.
* **Packages:** `git`, `dnf`.
* **Permissions:** Root access (required for installation).

## 🛠 Installation

### 1. Clone the Repository
Connect to your server and clone the project:

```bash
# Install git if missing
sudo dnf install -y git

# Clone the repo
git clone [https://github.com/derssen/rhel-update-monitor.git](https://github.com/derssen/rhel-update-monitor.git)
cd rhel-update-monitor
```

### 2. Run the Installer
The `install.sh` script automates the entire setup: it creates the service user, configures sudo permissions, installs the script to `/usr/local/bin`, and activates the Systemd timer.

```bash
sudo ./install.sh
```

**What the installer does:**
1.  Creates a system user `update_checker` (no login shell).
2.  Configures `/etc/sudoers.d/update_checker` to allow `dnf updateinfo` without a password.
3.  Installs the monitoring script to `/usr/local/bin/monitor.sh`.
4.  Installs Systemd Service and Timer units.
5.  Enables and starts the timer.

## ✅ Verification & Usage

### Check Timer Status
Verify that the timer is active and scheduled:

```bash
systemctl list-timers --all | grep security
```
*Expected output:* You should see `security-monitor.timer` listed with the "Next" execution time.

### Check Service Logs
To view the results of the check, query the system journal using the script's tag:

```bash
journalctl -t UpdateMonitor --no-pager
```

**Sample Output:**
> **No updates:**
> `Info: OK: System is secure. No security updates found.`
>
> **Updates found:**
> `Critical: CRITICAL: Security updates available! Please patch immediately.`

### Manual Run (Testing)
You can trigger the check immediately outside of the schedule for testing purposes:

```bash
sudo systemctl start security-monitor.service
```

## 📂 Project Structure

* `monitor.sh` - Core Bash script that queries DNF and logs output.
* `install.sh` - Deployment script for automated provisioning.
* `security-monitor.service` - Systemd Unit defining **how** to run the script.
* `security-monitor.timer` - Systemd Unit defining **when** to run the script.

## 🗑 Uninstallation

To remove the tool and revert changes:

```bash
# 1. Stop and disable timer
sudo systemctl disable --now security-monitor.timer

# 2. Remove files
sudo rm /usr/local/bin/monitor.sh
sudo rm /etc/systemd/system/security-monitor.*
sudo rm /etc/sudoers.d/update_checker

# 3. Remove user
sudo userdel update_checker

# 4. Reload daemon
sudo systemctl daemon-reload
```
