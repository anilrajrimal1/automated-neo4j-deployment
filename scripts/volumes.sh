#!/bin/bash
set -ex

MOUNTPOINT="/srv/Projects"

# Initialization wait
sleep 30

# Detect Root to Exclude
get_root_device() {
    root_mount=$(findmnt -n -o SOURCE /)
    echo "${root_mount%p*}"  # Removes partition suffix (p1---pn) --> To get Base Disk
}

ROOT_DEVICE=$(get_root_device)

DEVICE=""

# Check NVMe device first & Exclude ROOT
if ls /dev/nvme* 1>/dev/null 2>&1; then
    DEVICE=$(lsblk -n -p -o NAME,TYPE | grep "disk" | grep -E "/dev/nvme[0-9]" | awk '{print $1}' | grep -v "$ROOT_DEVICE" | head -1)
fi

# No NVMe, check for xvd devices
if [ -z "$DEVICE" ]; then
    DEVICE=$(lsblk -n -p -o NAME,TYPE | grep "disk" | grep -E "/dev/xvd[f-p]" | awk '{print $1}' | head -1)
fi

# No NVMe || xvd, check for sd devices
if [ -z "$DEVICE" ]; then
    DEVICE=$(lsblk -n -p -o NAME,TYPE | grep "disk" | grep -E "/dev/sd[f-p]" | awk '{print $1}' | head -1)
fi

# None found --> Exit
if [ -z "$DEVICE" ]; then
    echo "No suitable EBS volume found"
    exit 1
fi

# Format the device --> Create Filesystem
if ! blkid "$DEVICE" >/dev/null 2>&1; then
    echo "Creating filesystem on $DEVICE"
    mkfs.ext4 "$DEVICE"
fi

# Create MountPoint Dircetory
mkdir -p "$MOUNTPOINT"

# Retrieve UUID of the device
UUID=$(blkid -s UUID -o value "$DEVICE")
echo "Device UUID: $UUID"

# input fstab Entry
if ! grep -q "$UUID" /etc/fstab; then
    echo "UUID=$UUID $MOUNTPOINT ext4 defaults,nofail 0 2" >> /etc/fstab
fi

# Check Conflicting mounts (if already occur)
if mountpoint -q "$MOUNTPOINT"; then
    umount "$MOUNTPOINT"
fi

# Mount
mount "$MOUNTPOINT" || mount -a


# Set Permissions 
chown -R ubuntu:ubuntu "$MOUNTPOINT"  
chmod 755 "$MOUNTPOINT"
