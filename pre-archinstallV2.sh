#!/bin/bash

#---------------------------------------------------------------------
# Manuel's Arch Installation Script V2
#---------------------------------------------------------------------
# After a failure this is a ugraded version of the script
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Global Variables
#---------------------------------------------------------------------

DEVICE="/dev/sda" # Change it later
SWAP="${DEVICE}1"
ROOT="${DEVICE}2"
USER="Mt"
HOSTNAME="manuelgtm"

SWAP_SIZE=2G # Swap has 2GB
ROOT_SIZE=   # ROOT takes all the remaining space
TIME_ZONE="America/Santo_Domingo"
LOCALE="en_US.UTF-8"
FILESYSTEM=ext4

BASE_SYSTEM=(base base-devel linux linux-firmware amd-ucode vim nano)
SYSTEM_PACKAGES=(grub networkmanager network-manager-applet wireless_tools wpa_supplicant dialog os-prober mtools dosfstools base-devel linux-headers bluez bluez-utils cups xdg-utils xdg-user-dirs dhcp)

#---------------------------------------------------------------------
# Script start
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Check the internet
#---------------------------------------------------------------------

clear
echo "Testing the internet connection..."
if ! ping -c 3 archlinux.org &>/dev/null; then
    echo "Not Connected to Network"
    exit 1
fi
echo "Good! We have internet" && sleep 2

#---------------------------------------------------------------------
# Check time and date
#---------------------------------------------------------------------

timedatectl set-ntp true
echo && echo "Date/Time service status"
timedatectl status
sleep 2

#---------------------------------------------------------------------
# Partitioning the disks
#---------------------------------------------------------------------

echo "Partitioning the disks..."
cat > /tmp/sfdisk.cmd << EOF
$SWAP : start=2048, size=+$SWAP_SIZE, type=82
$ROOT : type=83
EOF

if ! sfdisk "$DEVICE" < /tmp/sfdisk.cmd; then
    echo "Partitioning failed"
    exit 1
fi

#---------------------------------------------------------------------
# Make filesystems
#---------------------------------------------------------------------

echo -e "\nFormatting the filesystems...\n"

if ! mkswap "$SWAP"; then
    echo "Failed to format swap"
    exit 1
fi

swapon "$SWAP"

if ! mkfs.ext4 "$ROOT"; then
    echo "Failed to format root filesystem"
    exit 1
fi

echo -e "Files formatted"
sleep 2

#---------------------------------------------------------------------
# Mounting the filesystems 
#---------------------------------------------------------------------

echo -e "Mounting the root partition"
if ! mount "$ROOT" /mnt; then
    echo "Failed to mount root partition"
    exit 1
fi

#---------------------------------------------------------------------
# Installing the base system packages
#---------------------------------------------------------------------

clear
echo "Installing all the base system packages..."
if ! pacstrap /mnt "${BASE_SYSTEM[@]}"; then
    echo "Failed to install base system packages"
    exit 1
fi
echo "All packages are installed"

#---------------------------------------------------------------------
# Generate the fstab file
#---------------------------------------------------------------------

echo "Generating the fstab..."
if ! genfstab -U /mnt >> /mnt/etc/fstab; then
    echo "Failed to generate fstab"
    exit 1
fi
cat /mnt/etc/fstab
echo "fstab generated..."
sleep 2

#---------------------------------------------------------------------
# Timezone and hardware clock configuration
#---------------------------------------------------------------------
echo "Setting the timezone to $TIME_ZONE..."
if ! arch-chroot /mnt ln -sf /usr/share/zoneinfo/"$TIME_ZONE" /etc/localtime; then
    echo "Failed to set timezone"
    exit 1
fi

if ! arch-chroot /mnt hwclock --systohc; then
    echo "Failed to set hardware clock"
    exit 1
fi

arch-chroot /mnt date
echo "Date configured.."
sleep 2

#---------------------------------------------------------------------
# Set up language and locales
#---------------------------------------------------------------------

if ! arch-chroot /mnt sed -i "s/#$LOCALE/$LOCALE/g" /etc/locale.gen; then
    echo "Failed to set locale"
    exit 1
fi

if ! arch-chroot /mnt locale-gen; then
    echo "Failed to generate locale"
    exit 1
fi

echo "LANG=$LOCALE" > /mnt/etc/locale.conf
export LANG="$LOCALE"
cat /mnt/etc/locale.conf
echo "locale.conf configured..."
sleep 2

#---------------------------------------------------------------------
# Hostname setup
#---------------------------------------------------------------------

echo "$HOSTNAME" > /mnt/etc/hostname
cat <<EOF > /mnt/etc/hosts
127.0.0.1	localhost
::1			localhost
127.0.1.1	${HOSTNAME}.localdomain	${HOSTNAME}
EOF

echo "Hostname configured"
echo "/mnt/etc/hostname..."
cat /mnt/etc/hostname
echo "/mnt/etc/hosts..."
cat /mnt/etc/hosts
echo "Finished"
sleep 2

#---------------------------------------------------------------------
# Root user password
#---------------------------------------------------------------------
clear
echo "Setting ROOT password..."
if ! arch-chroot /mnt passwd; then
    echo "Failed to set ROOT password"
    exit 1
fi

#---------------------------------------------------------------------
# Installing more essential packages
#---------------------------------------------------------------------

echo -e "Installing system packages..."
if ! arch-chroot /mnt pacman -S --noconfirm "${SYSTEM_PACKAGES[@]}"; then
    echo "Failed to install system packages"
    exit 1
fi
sleep 2

#---------------------------------------------------------------------
# GRUB configuration for BIOS
#---------------------------------------------------------------------

if ! arch-chroot /mnt grub-install --target=i386-pc "$DEVICE"; then
    echo "Failed to install GRUB"
    exit 1
fi

if ! arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg; then
    echo "Failed to configure GRUB"
    exit 1
fi

echo -e "Done, the GRUB installation is completed.."
sleep 2

#---------------------------------------------------------------------
# Enabling the services
#---------------------------------------------------------------------

if ! arch-chroot /mnt systemctl enable bluetooth; then
    echo "Failed to enable Bluetooth service"
    exit 1
fi

if ! arch-chroot /mnt systemctl enable cups; then
    echo "Failed to enable CUPS service"
    exit 1
fi

if ! arch-chroot /mnt systemctl enable NetworkManager.service; then
    echo "Failed to enable NetworkManager service"
    exit 1
fi

if ! arch-chroot /mnt systemctl enable dhcpcd; then
    echo "Failed to enable dhcpcd service"
    exit 1
fi

sleep 2

#---------------------------------------------------------------------
# Creating the new user
#---------------------------------------------------------------------

echo "Creating a new user..."
if ! arch-chroot /mnt sed -i 's/# %wheel/%wheel/g' /etc/sudoers; then
    echo "Failed to configure sudoers"
    exit 1
fi

if ! arch-chroot /mnt sed -i 's/%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers; then
    echo "Failed to configure sudoers"
    exit 1
fi

if ! arch-chroot /mnt useradd -m -G wheel "$USER"; then
    echo "Failed to create user"
    exit 1
fi

echo "Password for $USER?"
if ! arch-chroot /mnt passwd "$USER"; then
    echo "Failed to set user password"
    exit 1
fi

echo -e "Done, the installation is completed.. will reboot in 10 seconds"
sleep 10

# Unmount and reboot
umount -R /mnt
reboot

