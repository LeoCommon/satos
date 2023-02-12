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

## Settings for RPI3b
machine="raspi3b"
dtb="output/images/bcm2710-rpi-3-b-plus.dtb"
kernel="output/images/Image"
# <MartB> 29.01.2023 U-Boot does not work in qemu
# uboot="output/images/u-boot.bin"
BR_IMAGE_PATH="release/satos_rpi3_64_sdcard.img"
QEMU_IMAGE_PATH=$TMP_FOLDER/satos_qemu_rpi3b.img
QEMU_USB_PATH=$TMP_FOLDER/usb-stick.img
# This corresponds to the identifier and partition e.g mmcblk0pX
declare -A slots=( ["A"]="2" ["B"]="3" )

function prepare_slot_selection() {
  local sorted_slots=($(echo "${!slots[@]}" | tr ' ' '\n' | sort))
  slot_options=()
  for s in "${sorted_slots[@]}"
  do
    slot_options+=("$s")
  done
}

# Prepare the dynamic slot selection below
prepare_slot_selection



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
  sudo parted -s $QEMU_USB_PATH mktable gpt
  sudo parted -s $QEMU_USB_PATH mkpart primary ext4 0% 100%

  # Attach loop device and get loop device number only
  ld=$(sudo losetup -f $QEMU_USB_PATH --show | tr -d -c 0-9)

  # Never optimize this to use the actual $LD /dev/loopXY name to avoid partitioning disks on failure
  sudo mkfs.ext4 -L discosat-data -F /dev/loop$ld

  # Create temporary mount point
  mkdir -p $TMP_FOLDER/mnt
  sudo mount "/dev/loop${ld}" $TMP_FOLDER/mnt
  sudo cp -a $SCRIPTPATH/config_usb/. $TMP_FOLDER/mnt/.
  sudo umount $TMP_FOLDER/mnt

  # Detach loop device
  sudo losetup -D /dev/loop$ld
  echo "Created the config usb stick"
}

# Check if required files exist
if ! test -f $kernel || ! test -f $BR_IMAGE_PATH || ! test -f $dtb; then
  echo "Required files not found $BR_IMAGE_PATH, $dtb"
  echo "Did you forget to invoke make for the rpi3 target?"  
  exit 1
fi

function usage() { echo "Usage: $0 [-h <HELP>] [-k <Keep all files>] [--slot <A|B>] [--keep-usb] [--keep-image]" 1>&2; exit 1; }

keep_usb=false
keep_image=false
slot=null
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
    "--slot")
      if [[ $# -gt 1 ]]; then
        slot="$2"
        if [[ ! -n ${slots[$slot]} ]]; then 
          echo "Invalid slot \"$slot\"! Available: [${slots[@]}]" 
          exit 1
        fi
        echo "Pre-selecting slot $slot"
        shift
      else
        echo "Error: missing value for --slot argument"
        exit 1
      fi
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

if [[ $slot == null ]]; then
  echo 'Which slot do you want to boot?'
  while true; do
    select opt in "${slot_options[@]}"
    do
      if [[ -n $opt ]]; then
        slot=$opt
        break 2
      else
        echo "Invalid selection, please try again"
      fi
    done
  done
fi

# Save the selected slots
target_slot=${slots[$slot]}
target_slot_alpha=$slot

echo "Launching qemu!"
# We could also pass through the HACKRF
# -device usb-host,vendorid=XXXX,productid=XXXX 
sudo qemu-system-aarch64 -M $machine -kernel $kernel -dtb $dtb \
  -drive file=$QEMU_IMAGE_PATH,if=sd,format=raw \
  -append "console=ttyAMA0 root=/dev/mmcblk0p$target_slot rw rootwait rootfstype=erofs dwc_otg.fiq_fsm_enable=0 rauc.slot=$target_slot_alpha" \
  -device usb-net,netdev=net0 -netdev user,id=net0 \
  -drive file=$QEMU_USB_PATH,if=none,format=raw,node-name=config_usb -device usb-storage,drive=config_usb \
  -nographic

# To simulate a working U_Boot environment execute the following commands
# fw_setenv BOOT_A_LEFT 2 && fw_setenv BOOT_B_LEFT 1 && fw_setenv BOOT_ORDER 'A B'
