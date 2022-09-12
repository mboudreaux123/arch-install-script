#!/bin/bash

## User Variables
boot_part="/dev/vda2"
root_part="/dev/vda3"

## Misc Variables
root_part_mntpoint="mnt"
boot_part_mntpoint="boot"

pkglist_base="linux linux-firmware base base-devel btrfs-progs intel-ucode amd-ucode"

## Setup Encryption
cryptsetup luksFormat $root_part
cryptsetup open $root_part luks

## Create Filesystems
mkfs.vfat -F32 -n ARCHEFI $boot_part
mkfs.btrfs -L ROOT /dev/mapper/luks

## Create and Mount Sub Volumes
mount /dev/mapper/luks /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@swap
btrfs sub create /mnt/@home
btrfs sub create /mnt/@pkg
btrfs sub create /mnt/@snapshots
umount /mnt

## Mount the sub volumes
mount -o noatime,nodiratime,compress=zstd,space_cache=v2,ssd,subvol=@ /dev/mapper/luks /mnt
mkdir -p /mnt/{boot,home,var/cache/pacman/pkg,.snapshots,btrfs}
mount -o noatime,nodiratime,compress=zstd,space_cache=v2,ssd,subvol=@home /dev/mapper/luks /mnt/home
mount -o noatime,nodiratime,compress=zstd,space_cache=v2,ssd,subvol=@pkg /dev/mapper/luks /mnt/var/cache/pacman/pkg
mount -o noatime,nodiratime,compress=zstd,space_cache=v2,ssd,subvol=@snapshots /dev/mapper/luks /mnt/.snapshots
mount -o noatime,nodiratime,compress=zstd,space_cache=v2,ssd,subvolid=5 /dev/mapper/luks /mnt/btrfs

## Mount the EFI partition
mount /dev/sda1 /mnt/boot

## Create swap file
cd /mnt/btrfs/@swap
truncate -s 0 ./swapfile
chattr +C ./swapfile
btrfs property set ./swapfile compression none
dd if=/dev/zero of=./swapfile bs=1M count=8000 status=progress
chmod 600 ./swapfile
mkswap ./swapfile
swapon ./swapfile
cd -

## Install Arch Linux Base
pacstrap /mnt $pkglist_base

## Chroot into new system and configure system
arch-chroot /mnt/


































