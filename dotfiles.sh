#!/bin/bash

#-------------------------------------------------
# Cloning my repo for my app configs 
#-------------------------------------------------

echo -e "Giving spice to your set up"
cd $HOME

if [ ! -d ".config"]; then
    echo -e "Creating the .config folder..."
    mkdir ~/.config
fi

echo -e "Cloning your rice repo.."

if  [ ! -d "repos" ]; then
    mkdir repos 
fi

cd repos || exit # if exists enter to file 
if [ ! -d "Xmonad" ]; then
    git clone https://github.com/ManuelGTM/Xmonad.git
fi

cd Xmonad || exit

DIR=$(pwd)
Target="/home/$(whoami)/repos/Xmonad"

DOT_FILES=(
            'Fonts'
            'rofi'
            'fish'
            'alacritty'
            'sounds'
            'nvim'
            'starship/starship.toml'
        )

#-------------------------------------------------
# Setting my dotfiles to .config 
#-------------------------------------------------
#
#------------------------------------------------------
# Installing the fonts
#------------------------------------------------------

FONT_DIR="/usr/local/share/fonts"

if [ ! -e "${FONT_DIR}" ]; then
    mkdir -p "${FONT_DIR}"
done

while true; do
if ["$DIR" = "$Target"]; then
   for  DOT_FILE in "${DOT_FILES[@]}"; do
       if [ -e "./$DOT_FILE" ]; then
           cp -r "$DOT_FILE" ~/.config/
           if [ "$DOT_FILE" = "Fonts" ]; then
                cp -r "./$DOT_FILE/Mononoki" "${FONT_DIR}/"     
           fi
        else
            echo "Warning: $DOT_FILE does not exist"
       fi
   done
   break;
else 
    echo "Current directory ($DIR) does not match target"
    cd "$Target" || exit
fi
done


echo
echo "Done!"
