#!/bin/sh

# The reboot function delays the reboot with a systemd service
# This is needed for the update to be marked succesful.
reboot() {
    echo "rebooting in 10 seconds now!"
    systemd-run --on-active=10s systemctl reboot
}

# Send SIGUSR1 signal to the process to signal a finished update
echo 'Marking reboot and sending SIGUSR1 to client'

# Create a magic file so we dont miss the request if apogee restarts.
touch "/tmp/.reboot-pending"
chown apogee:apogee /tmp/.reboot-pending

if systemctl kill -s SIGUSR1 --kill-who=main client 2>/dev/null; then
    echo "Signal delivered to apogee, terminating script"
    exit 0
fi

echo 'Apogee daemon not running, trigger reboot'
reboot
exit 0
