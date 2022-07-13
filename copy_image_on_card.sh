#!/bin/bash
sdcard="/dev/mmcblk0"
image="./release/satos_rpi4_64_sdcard.img"
datapartition="$sdcard""p4"
mountpoint="/media/$USER/data"
sourcefolder="./board/common/rootfs-overlay/data/."
targetfolder="$mountpoint/."
sys_con_folder="$targetfolder/system-connections/"

# Part 1: copy image on sd-card
# check if sd-card available
if [[ -b "$sdcard" ]]; then
    echo "Info: SD-card found!"
else
    echo "Error: SD-card not found!"
    exit 1
fi
if [[ -f "$image" ]]; then
    echo "Info: image found!"
else
    echo "Error: image not found!"
    exit 1
fi
# ensure everything is unmounted
ls "$sdcard"?* | xargs -n1 umount -l
echo "Info: SD-card unmounted." 
# copy image
echo "Info: Copy image ..."
sudo dd if="$image" of="$sdcard" bs=4M
sync
echo "Info: Copy finished." 

# Part 2: copy intendet content of data-partition into the partition
# check if sd-card is present
partition_label="$(sudo e2label $datapartition)"
if [ "$partition_label" != "data" ]; then
    echo "Error: 'data' partition on SD-card not found!"
    exit 1
fi
echo "Info: 'data' partition of SD-card found."
# check if mountpoint exists 
if [ -d "$mountpoint" ]; then
    echo "Info: mountpoint exists."
    # check if it is already mounted
    if [[ $(findmnt "$mountpoint") ]]; then
        echo "Info: 'data' partition of SD-card is already mounted."
    else
        # else mount it
        echo "Info: 'data' partition on SD-card is not mounted ... mount it."
        sudo mount "$datapartition" "$mountpoint"
    fi
else
    # else create the moutpoint and mount
    echo "Info: create mountpoint and mount the 'data' partition of the SD-card."
    sudo mkdir "$mountpoint"
    sudo mount "$datapartition" "$mountpoint"
fi
# copy the files
echo "Info: copy files..."
sudo cp -r "$sourcefolder" "$targetfolder"
sleep 1
# change chmod of all files in system-connections-foder
echo "Info: modify access-rights for network-files..."
sudo find "$sys_con_folder" "-type" "f" -exec chmod "0600" "{}" \;
# unmount it
if [[ ! $(sudo umount "$datapartition") ]]; then
    echo "Info: unmounting worked." 
    if [ -d "$mountpoint" ]; then
        echo "Info: clean up mountpoint."
        sudo rm -r "$mountpoint"
    fi
else
    echo "Error: could not unmount SD-card."
fi







