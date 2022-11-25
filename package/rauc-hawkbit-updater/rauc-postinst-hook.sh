#!/bin/sh

# We dont get any arguments here but theres a environment variables from rauc
<<"COMMENT"
        RAUC_SLOTS=1 2 3
        SHLVL=1
        RAUC_SLOT_DEVICE_1=/dev/mmcblk0p3
        RAUC_SLOT_DEVICE_2=/dev/mmcblk0
        RAUC_TARGET_SLOTS=1 2
        RAUC_SLOT_DEVICE_3=/dev/mmcblk0p2
        SYSTEMD_EXEC_PID=184
        RAUC_MOUNT_PREFIX=/run/rauc
        RAUC_BUNDLE_MOUNT_POINT=/run/rauc/bundle
        RAUC_IMAGE_NAME_1=/run/rauc/bundle/rootfs.ext4
        RAUC_SLOT_TYPE_1=ext4
        JOURNAL_STREAM=8:1341
        RAUC_SLOT_TYPE_2=boot-mbr-switch
        RAUC_SLOT_BOOTNAME_1=B
        RAUC_SLOT_TYPE_3=ext4
        RAUC_IMAGE_DIGEST_1=f4a64a2e1aa76cbab4ac81c273e003a5c98c7c9e4a7420f684a88199f6aa2e0e
        RAUC_SLOT_BOOTNAME_2=
        RAUC_SLOT_BOOTNAME_3=A
        RAUC_CURRENT_BOOTNAME=A
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
        INVOCATION_ID=2100befb18eb4cd384a9a459129c0c51
        RAUC_SLOT_NAME_1=rootfs.1
        RAUC_IMAGE_CLASS_1=rootfs
        RAUC_SLOT_NAME_2=bootloader.0
        RAUC_SLOT_NAME_3=rootfs.0
        LANG=C.UTF-8
        RAUC_UPDATE_SOURCE=/run/rauc/bundle
        RAUC_SLOT_CLASS_1=rootfs
        RAUC_SLOT_CLASS_2=bootloader
        RAUC_SLOT_CLASS_3=rootfs
        RAUC_SYSTEM_CONFIG=/etc/rauc/system.conf
        PWD=/
        RAUC_SLOT_PARENT_1=
        RUNTIME_DIRECTORY=/run/rauc
        RAUC_SLOT_PARENT_2=
        GIO_USE_VFS=local
        RAUC_SLOT_PARENT_3=
COMMENT

# Reboot the system after 10 seconds, even when the shell is terminated
function reboot()
{
   echo "rebooting in 10 seconds now!"
   systemd-run -q sh -c 'sleep 10 && reboot'
}

# Obtain PID from systemd with
apogeePID=$(systemctl show --property MainPID --value apogee-client)

# Reboot after script exit if apogee is not running, the PID will be 0
if [ $apogeePID -eq 0 ]; then
    echo 'Apogee daemon not running, trigger reboot'

    # The reboot function delays the reboot with a systemd service
    # This is needed for the update to be marked succesful.
    reboot 
    exit 0
fi 

# Send SIGUSR1 signal to the process to signal a finished update
echo 'Marking reboot and sending SIGUSR1 to apogee'

# Create a magic file so we dont miss the request if apogee restarts.
touch "/tmp/.reboot-pending"
if systemctl kill -s SIGUSR1 --kill-who=main apogee-client 2>/dev/null; then
    echo "Signal delivered to apogee, terminating script"
    exit 0
fi

# If we end up here apogee restarted between PID collection and the signaling.
echo "signal could not be delivered, daemon might have crashed? => reboot"
reboot
exit 0