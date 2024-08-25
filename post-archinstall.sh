#!/usr/bin/bash

#--------------------------------------------------
# This is my post-installation script
#--------------------------------------------------

# Color definitions
RESET='\033[0m'
BOLD='\033[1m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'

echo -e "${CYAN}Hello, let's get your system ready!!${RESET}"
cd $HOME || exit

echo -e "${YELLOW}Upgrading your system before beginning...${RESET}"
sudo pacman -Syu --noconfirm 

#--------------------------------------------------
# This is my post-installation script
#--------------------------------------------------

if [ ! -d "paru" ]; then
    echo -e "${YELLOW}Installing AUR helper${RESET}"
    git clone https://aur.archlinux.org/paru.git

    cd paru || exit
    makepkg -si --noconfirm
    sleep 2
    cd $HOME || exit
fi

echo -e "${CYAN}Installing all the packages...${RESET}"

AUR_PKGS=(
    'spotify'
    'obsidian-bin'
    'onlyoffice'
    'eww'
)

for AUR_PKG in "${AUR_PKGS[@]}"; do
    echo -e "${GREEN}INSTALLING: ${AUR_PKG}${RESET}"
    paru -S "$AUR_PKG" --noconfirm --needed
done

PACMAN_PKGS=(
    # XORG X11
    'xorg'
    'xorg-xinit'
    'xorg-drivers'
    'base-devel'
    
    # Bspwm Desktop
    'bspwm'
    'sxhkd'
    'rofi'
    'picom'
    'dunst'
    'polybar'

    # Applications
    # 'alacritty'
    'kitty'
    # 'dmenu'
    'ranger'
    # 'mpv'
    'fish'
    # 'nautilus'
    'nitrogen'
    # 'starship'
    'firefox'

    # Programming
    'neovim'
    # 'tmux'
    # 'nodejs'
    # 'npm'
    # 'go'
    # 'rustc'
    # 'python'
    # 'postgresql'
    # 'git'

    # Terminal Dependencies
    # 'ripgrep'
    # 'fzf'
    # 'eza'
    'fastfetch'

    # Networking
    'dialog'
    'networkmanager'
    'ufw'

    # Audio
    'pulseaudio'
    'alsa-utils'
    'pulseaudio-alsa'
    'pavucontrol'
    'pnmixer'

    # Bluetooth
    'bluez'
    'bluez-utils'
    'bluez-libs'
    'pulseaudio-bluetooth'
)

for PKG in "${PACMAN_PKGS[@]}"; do
    echo -e "${GREEN}INSTALLING: ${PKG}${RESET}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

#--------------------------------------------------
# Setting the graphical environment
#--------------------------------------------------

echo -e "${CYAN}Let's set up your desktop environment...${RESET}"

XINIT="$HOME/.xinitrc"

if [ ! -f "${XINIT}" ]; then
    cp /etc/X11/xinit/xinitrc $HOME
fi

# Remove the last 5 lines from the file
sed -i -e :a -e '$d;N;2,5ba' -e 'P;D' "$XINIT"

if ! grep -q 'nitrogen --restore &' "$XINIT"; then
    echo -e "${BLUE}Configuring ${XINIT}...${RESET}"
    cat <<EOF >> "$XINIT"
nitrogen --restore &
picom &
exec bspwm
EOF
fi

echo -e "${GREEN}We have finished configuring your system.${RESET}"
echo -e "${YELLOW}The system will reboot in 3 seconds...${RESET}"
sleep 3

reboot
