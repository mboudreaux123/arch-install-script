#!/bin/bash

## https://nerdstuff.org/posts/2020/2020-004_arch_linux_luks_btrfs_systemd-boot/

hostname="arch"
locale="en_US.UTF-8 UTF-8"
timezone_region="America"
timezone_city="Chicago"
user="user"

pkglist_basic="vim nano git wget htop bash-completion bash-completion zsh zsh-completions networkmanager dosfstools e2fsprogs ntfs-3g power-profiles-daemon"
pkglist_network_tools="openbsd-netcat whois nmap macchanger"
pkglist_sway="sway swaylock-effects swayidle swaylock polkit-gnome waybar wlogout mako mpv imv swaync grim slurp light swaybg azote mpvpaper polkit-gnome clipman wl-clipboard wayvnc wf-recorder network-manager-applet"
pkglist_virt=""
pkglist_gnome=""
pkglist_gaming="mangohud vkbasalt steam lutris wine-stable gamescope"
pkglist_flatpak_flathub=""

hosts="#<ip-address>	<hostname.domain.org>	<hostname>\n
127.0.0.1	${hostname}.localdomain	${hostname}\n
::1		localhost.localdomain	localhost\n"

sdb_boot_config="title Arch Linux\n
linux /vmlinuz-linux\n
initrd /intel-ucode.img\n
initrd /initramfs-linux.img\n
options cryptdevice=UUID=<UUID-OF-ROOT-PARTITION>:luks:allow-discards root=/dev/mapper/luks rootflags=subvol=@ rd.luks.options=discard rw resume=/dev/mapper/luks resume_offset=<YOUR-OFFSET>\n"

## Install additional basic packages
pacman -S $pkglist_basic

## Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

## Install AUR helper (paru)
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..
rm -rf paru

## Update system clock
timedatectl set-ntp true

## Set time zone
ln -sf /usr/share/zoneinfo/$timezone_region/$timezone_city /etc/localtime

## Generate /etc/adjtime
hwclock --systohc

## Generate locales
echo $locale >> /etc/locale.gen
locale-gen

## Set hostname
echo $hostname > /etc/hostname

## Configure Initramfs
sed -i "/HOOKS=/c\HOOKS=(base keyboard udev autodetect modconf block keymap encrypt btrfs filesystems resume)" /etc/mkinitcpio.conf

## Rereate Initramfs
mkinitcpio -P

## Setup user account with sudo privilege
useradd -m -G wheel $user
passwd $user

## Add wheel group to sudo
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

## Add wheel group to doas
echo "permit :wheel" >> /etc/doas.conf
echo "" >> file.txt

## Install systemd boot
bootctl --path=/boot install

## Create systemd boot loader entry

## Install additional packages
pacman -S $pkglist_network_tools
pacman -S $pkglist_sway
pacman -S $pkglist_virt
pacman -S $pkglist_gnome
pacman -S $pkglist_gaming


