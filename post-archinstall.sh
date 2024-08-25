#!/usr/bin/bash

#--------------------------------------------------
# This is my post instalation script
#--------------------------------------------------

echo -e "Hello let's get your system ready!!"
cd $HOME 

echo -e "Upgrading your system before begin.."
sudo pacman -Syu 

#--------------------------------------------------
# This is my post instalation script
#--------------------------------------------------

if [ ! -d "paru" ]; then
    echo -e "Installing AUR helper"
    git clone https://aur.archlinux.org/paru.git
    cd paru 
    makepkg -si
    sleep 2
    cd $HOME
fi


echo "Installing all the packages..."

AUR_PKGS=(

        'spotify'
        'obsidian-bin'
        'onlyoffice'
        'eww'
    )

for AUR_PKG in "${AUR_PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    paru -S "$PKG" --noconfirm --needed
done

PACMAN_PKGS=(
    # XORG X11
    'xorg'
    'xorg-xinit'
    'xorg-drivers'
    'base-devel'
    
    #Desktop
    'bspwm'
    'rofi'
    'picom'
    'dunst'
    'polybar'
    'kitty'

    #Applications
    'alacritty'
    'kitty'
    'dmenu'
    'ranger'
    'mpv'
    'fish'
    'nautilus'
    'nitrogen'
    'starship'
    'firefox'

    # programming
    'neovim'
    'tmux'
    'nodejs'
    'npm'
    'go'
    'rustc'
    'python'
    'postgresql'
    'git'

    #Terminal Dependecies
    'ripgrep'
    'fzf'
    'eza'
    'fastfetch'

    #Networking
    'dialog'
    'networkmanager'
    'ufw'

    # Audio
    'pulseaudio'
    'alsa-utils'
    'pulseaudio-alsa'
    'pavucontrol'
    'pnmixer'

    #bluetooth
    'bluez'
    'bluez-utils'
    'bluez-libs'
    'pulseaudio-bluetooth'
)


for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

#--------------------------------------------------
# Setting the graphical environment
#--------------------------------------------------

echo "Let's set up your desktop environment.."

XINIT="$HOME/xinitrc"

if [ ! -d "${XINIT}" ]; then
    cp /etc/X11/xinit/xinitrc $HOME
fi

for i in {1..5}; do
    set -i '$d' $XINIT
done 

cat <<EOF >> $XINIT
nitrogen --restore &
picom &
exec bspwm 
EOF


