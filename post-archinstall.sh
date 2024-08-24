#!/usr/bin/bash

#--------------------------------------------------
# This is my post instalation script
#--------------------------------------------------


echo -e "Hello let's get your system ready!!"

echo -e "Upgrading your system before begin.."
sudo pacman -Syu 

#--------------------------------------------------
# This is my post instalation script
#--------------------------------------------------

if [-d "paru" ]; then
    echo -e "Installing AUR helper"
    git clone https://aur.archlinux.org/paru.git
    cd paru 
    makepkg -si
    sleep 2
    cd $HOME
else 
    echo -e "Let's begin..."
    sleep 3
fi


echo "Installing all the packages..."

AUR_PKGS=(

        'spotify'
        'obsidian-bin'
        'onlyoffice'

    )

for AUR_PKG in "${AUR_PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    paru -S "$PKG" --noconfirm --needed
done

PACMAN_PKGS=(
    # XORG
    'xorg'
    'xorg-xinit'
    'xorg-drivers'
    
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

    #Random Dependecies
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
# Installing Tools 
#--------------------------------------------------

echo "Let's install more tools"

