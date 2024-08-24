#!/usr/bin/bash

#---------------------------------------------------------------------
# Manuel's Arch Installation Script V1
#---------------------------------------------------------------------
# This in my first attemp to create Arch linux install more easy 
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
$(ping -c 3 archlinux.org &>/dev/null) || (echo "Not Connected to Network" && exit 1)
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

cat > /tmp/sfdisk.cmd << EOF
$SWAP : start= 2048, size=+$SWAP_SIZE, type=82
$ROOT : type=83
EOF

sfdisk "$DEVICE" < /tmp/sfdisk.cmd

#---------------------------------------------------------------------
# make filesystems
#---------------------------------------------------------------------

echo -e "\n Formating the filesystems...\n"

mkswap "${SWAP}"
swapon "${SWAP}"
mkfs.ext4 "${ROOT}"
echo -e "Files formated"
sleep 2

#---------------------------------------------------------------------
# Mounting the filesystems 
#---------------------------------------------------------------------

echo -e "Mounting the root partition"
mount "${ROOT}" /mnt

#---------------------------------------------------------------------
# downloading the system base packages
#---------------------------------------------------------------------

clear
echo "Installing all the Base system packages..."
pacstrap /mnt "${BASE_SYSTEM[@]}" 
echo "All packages are installed"

#---------------------------------------------------------------------
# Generate the fstab files
#---------------------------------------------------------------------

echo "Generating the fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
echo "fstab generated..."
sleep 2


#---------------------------------------------------------------------
#Timezone and hardware clock configuring 
#---------------------------------------------------------------------
echo "Setting the timezone to $TIME_ZONE..."
arch-chroot /mnt ln -sf /usr/share/zoneinfo/"$TIME_ZONE" /etc/localtime
arch-chroot /mnt wclock --systohc
arch-chroot /mnt date
echo "Date configured.."
sleep 2

#---------------------------------------------------------------------
# Set up Language and setting locales 
#---------------------------------------------------------------------

arch-chroot /mnt sed -i "s/#$LOCALE/$LOCALE/g" /etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=$LOCALE" >> /etc/locale.conf
export LANG="$LOCALE"
cat /mnt/etc/locale.conf
echo "locale.conf configured..."
sleep 2

#---------------------------------------------------------------------
# Hostname Set Up
#---------------------------------------------------------------------

clear
echo "${HOSTNAME}" >> /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1	localhost
::1			localhost
127.0.1.1	${HOSTNAME}.localdomain	${HOSTNAME}
EOF

echo "Hostname cofigured"
echo "/etc/hostname..."
cat mnt/etc/hostname...
echo "/etc/hosts.."
cat mnt/etc/hosts
echo "Finished"
sleep 2

#---------------------------------------------------------------------

# Root user Password
#---------------------------------------------------------------------
clear
echo "Setting ROOT Password..."
arch-chroot /mnt passwd

#---------------------------------------------------------------------
# Installing more essentials packages
#---------------------------------------------------------------------

echo -e "Installing system packages.."
arch-chroot /mnt pacman -S "${SYSTEM_PACKAGES[@]}" 
sleep 2

#---------------------------------------------------------------------
# Grub configuration BIOS
#---------------------------------------------------------------------

arch-chroot /mnt grub-install --target=i386-pc $DEVICE
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
echo -e "Done, The grub installation is completed.."
sleep 2

#---------------------------------------------------------------------
# Enabling the services
#---------------------------------------------------------------------

arch-chroot /mnt systemctl enable bluetooth
arch-chroot /mnt systemctl enable org.cups.cupsd
arch-chroot /mnt systemctl enable NetworkManager.service
arch-chroot /mnt  systemctl enable dhcpcd
sleep 2

#---------------------------------------------------------------------
# Creating the new user
#---------------------------------------------------------------------

echo "Creating a new user..."
arch-chroot /mnt sed -i 's/# %wheel/%wheel/g' /etc/sudoers
arch-chroot /mnt sed -i 's/%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers
arch-chroot /mnt useradd -m -G wheel "$USER"
echo "Password for $USER?"
arch-chroot /mnt passwd "$USER"

echo -e "Done, The installation is completed.. will reboot in 10 seconds"
sleep 10

exit
umount -R /mnt
reboot



