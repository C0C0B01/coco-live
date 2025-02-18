#!/bin/bash

Main() {
    # Remove current keyring first, to complete initiate it
    sudo rm -rf /etc/pacman.d/gnupg
    # We are using this, because archlinux is signing the keyring often with a newly created keyring
    # This results into a failed installation for the user.
    # Installing archlinux-keyring fails due not being correctly signed
    # Mitigate this by installing the latest archlinux-keyring on the ISO, before starting the installation
    # The issue could also happen, when the installation does rank the mirrors and then a "faulty" mirror gets used
    sudo pacman -Sy --noconfirm archlinux-keyring cocolinux-keyring
    # Also populate the keys, before starting the Installer, to avoid above issue
    sudo pacman-key --init
    sudo pacman-key --populate archlinux cocolinux
    # Also use timedatectl to sync the time with the hardware clock
    # There has been a bunch of reports, that the keyring was created in the future
    # Syncing appears to fix it
    timedatectl set-ntp true

    local progname="$(basename "$0")"
    local log="/home/liveuser/coco-install.log"
    local mode="online"  # TODO: keep this line for now

    local _efi_check_dir="/sys/firmware/efi"
    local _exitcode=2 # by default use grub

    local SYSTEM=""
    local BOOTLOADER=""
    if [ -d "${_efi_check_dir}" ]; then
        SYSTEM="UEFI SYSTEM"

        # Restrict bootloader selection to only UEFI systems
        _exitcode=$(yad --width 300 --title "Bootloader" \
    --image=gnome-shutdown \
    --button="Grub(Default):2" \
    --button="Systemd-boot:3" \
    --text "Choose Bootloader/Edition:" ; echo $?)
    else
        SYSTEM="BIOS/MBR SYSTEM"
    fi

    local ISO_VERSION="$(cat /etc/version-tag)"
    echo "USING ISO VERSION: ${ISO_VERSION}"

    if [[ "${_exitcode}" -eq 2 ]]; then
        BOOTLOADER="GRUB"
        echo "USING GRUB!"
        yes | sudo pacman -R cocomares-qt6-next-systemd
        yes | sudo pacman -Sy cocomares-qt6-next-grub
    elif [[ "${_exitcode}" -eq 3 ]]; then
        BOOTLOADER="SYSTEMD-BOOT"
        echo "USING SYSTEMD-BOOT!"
        yes | sudo pacman -R cocomares-qt6-next-grub
        yes | sudo pacman -Sy cocomares-qt6-next-systemd
    else
        exit
    fi

    # Get Hardware Informations
    inxi -F > $log

    cat <<EOF >> $log
########## $log by $progname
########## Started (UTC): $(date -u "+%x %X")
########## ISO version: $ISO_VERSION
########## System: $SYSTEM
########## Bootloader: $BOOTLOADER
EOF

    sudo cp "/usr/share/calamares/settings_${mode}.conf" /etc/calamares/settings.conf
    sudo -E dbus-launch cocomares -D6 >> $log &
}

Main "$@"
