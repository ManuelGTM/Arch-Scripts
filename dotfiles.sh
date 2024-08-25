#!/bin/bash

#-------------------------------------------------
# Cloning my repo for my app configs 
#-------------------------------------------------

echo -e "Cloning your rice repo.."

if [-d "repos"]; then
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
            'rofi'
            'fish'
            'alacritty'
            'kitty'
            'rofi'
            'zathura'
            'sounds'
            'nvim'
            'starship/starship.toml'
        )

#-------------------------------------------------
# Setting my dotfiles to .config 
#-------------------------------------------------

while true; do
if ["$DIR" = "$Target"]; then
   for  DOT_FILE in "${DOT_FILES[@]}"; do
       if [ -e ./"$DOT_FILE" ]; then
           cp "$DOT_FILE" ~/.config/
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
