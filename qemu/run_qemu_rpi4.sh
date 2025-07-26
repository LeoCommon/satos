#!/bin/bash
if [[ "$EUID" != 0 ]]; then
    sudo echo "Permissions granted by sudo ..."
    if ! sudo true; then
        echo "Terminating"
        exit 1
    fi
fi

# https://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Create tmp folder if it got deleted
TMP_FOLDER=$SCRIPTPATH/tmp
[ -d $TMP_FOLDER ] || mkdir $TMP_FOLDER

## Settings for RPI4b
machine="raspi4b"
dtb="output/images/bcm2711-rpi-4-b.dtb"
uboot="output/images/u-boot.bin"
BR_IMAGE_PATH="release/sdcard.img"
QEMU_IMAGE_PATH=$TMP_FOLDER/satos_qemu_rpi4b.img
QEMU_USB_PATH=$TMP_FOLDER/usb-stick.img

function handle_qemu_image() {
  if test -f "$QEMU_IMAGE_PATH"; then
    # User wants to keep using this
    if [[ $keep_image == true ]]; then
      return
    fi

    while true; do
      read -p "Boot existing image [$QEMU_IMAGE_PATH]? (y/n): " choice
      case "$choice" in 
        y|Y ) 
          keep_image=true
          echo "Re-using image"
          return
          ;;
        n|N ) 
          break
          ;;
        * ) 
          echo "Invalid selection, please try again"
          ;;
      esac
    done
  fi
  
  echo "Creating qemu compatible image ..."
  rm -f $QEMU_IMAGE_PATH
  cp $BR_IMAGE_PATH $QEMU_IMAGE_PATH || exit 1
  qemu-img resize -f raw $QEMU_IMAGE_PATH 4G || exit 1
}

function handle_usb_stick() {
  # Check if usb stick already exists
  if test -f "$QEMU_USB_PATH"; then
    # User wants to keep using this
    if [[ $keep_usb == true ]]; then
      return
    fi
    while true; do
      read -p "Keep existing usb-stick image? [$QEMU_USB_PATH] (y/n): " choice
      case "$choice" in 
        y|Y ) 
          keep_usb=true 
          echo "Re-using usb-stick"
          return
          ;;
        n|N ) 
          break 
          ;;
        * ) echo "Invalid selection, please try again";;
      esac
    done
  fi

  echo "(Re)creating the config USB stick ..."
  sudo truncate -s 1G $QEMU_USB_PATH
  sudo parted -s $QEMU_USB_PATH mklabel gpt mkpart P1 ext4 0% 100%

  # Attach loop device and get loop device number only
  ld=$(sudo losetup -P -f $QEMU_USB_PATH --show | tr -d -c 0-9)

  # Never optimize this to use the actual $LD /dev/loopXY name to avoid partitioning disks on failure
  sudo mkfs.ext4 -L leocommon-data -F /dev/loop${ld}

  # Create temporary mount point
  mkdir -p $TMP_FOLDER/mnt
  sudo mount "/dev/loop${ld}" $TMP_FOLDER/mnt
  sudo rsync -a $SCRIPTPATH/config_usb/ $TMP_FOLDER/mnt/
  sudo umount $TMP_FOLDER/mnt

  # Detach loop device
  sudo losetup -D /dev/loop$ld
  echo "Created the config usb stick"
}

# Check if required files exist
if ! test -f $BR_IMAGE_PATH || ! test -f $uboot || ! test -f $dtb ; then
  echo "Required files not found $BR_IMAGE_PATH, $uboot, $dtb"
  echo "Did you forget to invoke make for the qemu target?"  
  exit 1
fi

function usage() { echo "Usage: $0 [-h <HELP>] [-k <Keep all files>] [--keep-usb] [--keep-image]" 1>&2; exit 1; }

keep_usb=false
keep_image=false
while [[ $# -gt 0 ]]; do
  case $1 in
    "-k")
      keep_usb=true
      keep_image=true
      echo "Keeping previous image and usb"
      ;;
    "--keep-usb")
      keep_usb=true
      echo "Keeping previous usb"
      ;;
    "--keep-image")
      keep_image=true
      echo "Keeping previous image"
      ;;
    "-h")
      usage
      ;;
    *)
      echo "Error: unknown argument $1"
      usage
      exit 1
      ;;
  esac
  shift
done


# Handle QEMU Image
handle_qemu_image

# Handle Config USB
handle_usb_stick

# Fix DTB manually (for usb and console) as QEMU doesnt support loading rpi-firmware
# This command requires dtc to be installed
echo "Fixing usb node in dtb $dtb"
fdtoverlay -i $dtb -o $dtb.mod ./output/images/rpi-firmware/overlays/disable-bt.dtbo ./output/images/rpi-firmware/overlays/dwc-otg-deprecated.dtbo 

echo "Launching qemu!"
# We could also pass through the HACKRF
# -device usb-host,vendorid=XXXX,productid=XXXX 
sudo qemu-system-aarch64 -M $machine -smp 4 -serial mon:stdio \
  -dtb $dtb.mod -kernel $uboot -usb -device usb-kbd \
  -device sd-card,drive=mydrive -drive id=mydrive,if=none,format=raw,file=$QEMU_IMAGE_PATH \
  -device usb-net,netdev=net0 -netdev user,id=net0 \
  -drive file=$QEMU_USB_PATH,if=none,format=raw,node-name=config_usb -device usb-storage,drive=config_usb \
  -nographic

# To simulate a working U_Boot environment execute the following commands
# fw_setenv BOOT_A_LEFT 2 && fw_setenv BOOT_B_LEFT 1 && fw_setenv BOOT_ORDER 'A B'
