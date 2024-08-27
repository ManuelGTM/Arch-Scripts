#!/usr/bin/bash

#---------------------------------------------------------------------
# Manuel's Arch Installation Script V3
#---------------------------------------------------------------------
# After a success in the V2 i wanted to improve it a little more
#---------------------------------------------------------------------
# Now it have colors!! Shiet
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

BASE_SYSTEM=(base base-devel linux linux-firmware)
SYSTEM_PACKAGES=(grub networkmanager network-manager-applet wireless_tools wpa_supplicant dialog os-prober mtools dosfstools base-devel linux-headers bluez bluez-utils cups xdg-utils xdg-user-dirs)

#---------------------------------------------------------------------
# Color definitions
#---------------------------------------------------------------------
RESET='\033[0m'
BOLD='\033[1m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'

#---------------------------------------------------------------------
# Script start
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Check the internet
#---------------------------------------------------------------------

clear
echo -e "${CYAN}Testing the internet connection...${RESET}"
if ! ping -c 3 archlinux.org &>/dev/null; then
    echo -e "${RED}Not Connected to Network${RESET}"
    exit 1
fi
echo -e "${GREEN}Good! We have internet${RESET}" && sleep 1

#---------------------------------------------------------------------
# Check time and date
#---------------------------------------------------------------------

timedatectl set-ntp true
echo && echo -e "${BLUE}Date/Time service status${RESET}"
timedatectl status
sleep 1

#---------------------------------------------------------------------
# Partitioning the disks
#---------------------------------------------------------------------

echo -e "${YELLOW}Partitioning the disks...${RESET}"
cat > /tmp/sfdisk.cmd << EOF
$SWAP : start=2048, size=+$SWAP_SIZE, type=82
$ROOT : type=83
EOF

if ! sfdisk "$DEVICE" < /tmp/sfdisk.cmd; then
    echo -e "${RED}Partitioning failed${RESET}"
    exit 1
fi

#---------------------------------------------------------------------
# Make filesystems
#---------------------------------------------------------------------

echo -e "${BLUE}Formatting the filesystems...${RESET}"

if ! mkswap "$SWAP"; then
    echo -e "${RED}Failed to format swap${RESET}"
    exit 1
fi

swapon "$SWAP"

if ! mkfs.ext4 "$ROOT"; then
    echo -e "${RED}Failed to format root filesystem${RESET}"
    exit 1
fi

echo -e "${GREEN}Files formatted${RESET}"
sleep 2

#---------------------------------------------------------------------
# Mounting the filesystems 
#---------------------------------------------------------------------

echo -e "${YELLOW}Mounting the root partition${RESET}"
if ! mount "$ROOT" /mnt; then
    echo -e "${RED}Failed to mount root partition${RESET}"
    exit 1
fi

#---------------------------------------------------------------------
# Installing the base system packages
#---------------------------------------------------------------------

clear
echo -e "${CYAN}Installing all the base system packages...${RESET}"
if ! pacstrap /mnt "${BASE_SYSTEM[@]}"; then
    echo -e "${RED}Failed to install base system packages${RESET}"
    exit 1
fi
echo -e "${GREEN}All packages are installed${RESET}"

#---------------------------------------------------------------------
# Generate the fstab file
#---------------------------------------------------------------------

echo -e "${BLUE}Generating the fstab...${RESET}"
if ! genfstab -U /mnt >> /mnt/etc/fstab; then
    echo -e "${RED}Failed to generate fstab${RESET}"
    exit 1
fi
cat /mnt/etc/fstab
echo -e "${GREEN}fstab generated...${RESET}"
sleep 2

#---------------------------------------------------------------------
# Timezone and hardware clock configuration
#---------------------------------------------------------------------

echo -e "${YELLOW}Setting the timezone to $TIME_ZONE...${RESET}"
if ! arch-chroot /mnt ln -sf /usr/share/zoneinfo/"$TIME_ZONE" /etc/localtime; then
    echo -e "${RED}Failed to set timezone${RESET}"
    exit 1
fi

if ! arch-chroot /mnt hwclock --systohc; then
    echo -e "${RED}Failed to set hardware clock${RESET}"
    exit 1
fi

arch-chroot /mnt date
echo -e "${GREEN}Date configured..${RESET}"
sleep 2

#---------------------------------------------------------------------
# Set up language and locales
#---------------------------------------------------------------------

if ! arch-chroot /mnt sed -i "s/#$LOCALE/$LOCALE/g" /etc/locale.gen; then
    echo -e "${RED}Failed to set locale${RESET}"
    exit 1
fi

if ! arch-chroot /mnt locale-gen; then
    echo -e "${RED}Failed to generate locale${RESET}"
    exit 1
fi

echo "LANG=$LOCALE" > /mnt/etc/locale.conf
export LANG="$LOCALE"
cat /mnt/etc/locale.conf
echo -e "${GREEN}locale.conf configured...${RESET}"
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

echo -e "${GREEN}Hostname configured${RESET}"
echo "/mnt/etc/hostname..."
cat /mnt/etc/hostname
echo "/mnt/etc/hosts..."
cat /mnt/etc/hosts
echo -e "${GREEN}Finished${RESET}"
sleep 2

#---------------------------------------------------------------------
# Root user password
#---------------------------------------------------------------------
clear
echo -e "${CYAN}Setting ROOT password...${RESET}"
if ! arch-chroot /mnt passwd; then
    echo -e "${RED}Failed to set ROOT password${RESET}"
    exit 1
fi

#---------------------------------------------------------------------
# Installing more essential packages
#---------------------------------------------------------------------

echo -e "${BLUE}Installing system packages...${RESET}"
if ! arch-chroot /mnt pacman -S --noconfirm "${SYSTEM_PACKAGES[@]}"; then
    echo -e "${RED}Failed to install system packages${RESET}"
    exit 1
fi
sleep 2

#---------------------------------------------------------------------
# GRUB configuration for BIOS
#---------------------------------------------------------------------

if ! arch-chroot /mnt grub-install --target=i386-pc "$DEVICE"; then
    echo -e "${RED}Failed to install GRUB${RESET}"
    exit 1
fi

if ! arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg; then
    echo -e "${RED}Failed to configure GRUB${RESET}"
    exit 1
fi

echo -e "${GREEN}Done, the GRUB installation is completed..${RESET}"
sleep 2

#---------------------------------------------------------------------
# Enabling the services
#---------------------------------------------------------------------

if ! arch-chroot /mnt systemctl enable bluetooth; then
    echo -e "${RED}Failed to enable Bluetooth service${RESET}"
    exit 1
fi

if ! arch-chroot /mnt systemctl enable cups; then
    echo -e "${RED}Failed to enable CUPS service${RESET}"
    exit 1
fi

if ! arch-chroot /mnt systemctl enable NetworkManager.service; then
    echo -e "${RED}Failed to enable NetworkManager service${RESET}"
    exit 1
fi

#---------------------------------------------------------------------
# Creating the new user
#---------------------------------------------------------------------

echo -e "${CYAN}Creating a new user...${RESET}"
if ! arch-chroot /mnt sed -i 's/# %wheel/%wheel/g' /etc/sudoers; then
    echo -e "${RED}Failed to configure sudoers${RESET}"
    exit 1
fi

if ! arch-chroot /mnt sed -i 's/%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers; then
    echo -e "${RED}Failed to configure sudoers${RESET}"
    exit 1
fi

if ! arch-chroot /mnt useradd -m -G wheel "$USER"; then
    echo -e "${RED}Failed to create user${RESET}"
    exit 1
fi

echo -e "${CYAN}Password for $USER?${RESET}"
if ! arch-chroot /mnt passwd "$USER"; then
    echo -e "${RED}Failed to set user password${RESET}"
    exit 1
fi

echo -e "${GREEN}Done, the installation is completed.. your system will reboot in 5 seconds${RESET}"

# Countdown before reboot
count=5

for ((i=5; i>=1 ;i--)) do
    echo -e "${CYAN}$i...${RESET}"
    sleep 1
done

# Unmount and reboot
umount -R /mnt
reboot

