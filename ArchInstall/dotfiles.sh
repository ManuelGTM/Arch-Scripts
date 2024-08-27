#!/usr/bin/bash

#-------------------------------------------------
# Cloning my repo for my app configs 
#-------------------------------------------------

# Define color codes
RESET='\033[0m'
BOLD='\033[1m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'

echo -e "${BOLD}${CYAN}
-------------------------------------------------
Giving spice to your setup
-------------------------------------------------
${RESET}"

cd $HOME || exit

# Create .config directory if it doesn't exist
if [ ! -d ".config" ]; then
    echo -e "${YELLOW}Creating the .config folder...${RESET}"
    mkdir ~/.config
fi

echo -e "${BLUE}Cloning your rice repo...${RESET}"

# Create repos directory if it doesn't exist
if [ ! -d "repos" ]; then
    mkdir repos
fi

cd repos || exit  # If exists, enter the directory

# Clone the Xmonad repo if it doesn't exist
if [ ! -d "Xmonad" ]; then
    echo -e "${GREEN}Cloning Xmonad repository...${RESET}"
    git clone https://github.com/ManuelGTM/Xmonad.git
fi

cd Xmonad || exit

DIR=$(pwd)
Target="$HOME/repos/Xmonad"

# List of dotfiles to handle
DOT_FILES=(
    'Fonts'
    'bspwm'
    'rofi'
    'fish'
    'alacritty'
    'kitty'
    'poly-dark-master'
    'fastfetch'
    'zathura'
    'sounds'
    'nvim'
    'starship/starship.toml'
)

#------------------------------------------------------
# Creating Fonts folder
#------------------------------------------------------

FONT_DIR="/usr/local/share/fonts"

if [ ! -e "${FONT_DIR}" ]; then
    echo -e "${MAGENTA}Creating fonts directory...${RESET}"
    sudo mkdir -p "${FONT_DIR}"
    sudo chmod 755 "${FONT_DIR}"
fi

#-------------------------------------------------
# Setting up dotfiles to .config 
#-------------------------------------------------

if [ "$DIR" = "$Target" ]; then
    for DOT_FILE in "${DOT_FILES[@]}"; do
        if [ ! -e "./$DOT_FILE" ]; then
            echo -e "${RED}Warning: $DOT_FILE does not exist${RESET}"
            continue
        fi

        case "$DOT_FILE" in
            "Fonts") # => Installing Fonts
                echo -e "${GREEN}Installing Fonts...${RESET}"
                cp -r "./$DOT_FILE/Mononoki" "${FONT_DIR}/"
                ;;
            "poly-dark-master") # => Installing the Grub theme
                echo -e "${YELLOW}Installing Grub theme...${RESET}"
                cp -r "$DOT_FILE" "$HOME/.config/"
                GRUB_THEME="$HOME/.config/poly-dark-master/"

                if cd "$GRUB_THEME"; then
                    if [ -x "./install.sh" ]; then
                        echo -e "${BLUE}Running install.sh and selecting option 3${RESET}"
                        printf "3\n" | ./install.sh
                    else
                        echo -e "${RED}Error: install.sh is not executable${RESET}"
                        chmod +x ./install.sh
                        if [ -x "./install.sh" ]; then
                            echo -e "${BLUE}Retrying install.sh${RESET}"
                            printf "3\n" | ./install.sh
                        else
                            echo -e "${RED}Failed to make install.sh executable${RESET}"
                            exit 1
                        fi
                    fi
                else
                    echo -e "${RED}Error: Could not change to directory $GRUB_THEME${RESET}"
                    exit 1
                fi
                cd "$Target" || exit
                ;;
            *)
                echo -e "${GREEN}Copying $DOT_FILE to ~/.config/${RESET}"
                cp -r "$DOT_FILE" ~/.config/
                ;;
        esac
    done
else
    echo -e "${RED}Current directory ($DIR) does not match target ($Target)${RESET}"
    cd "$Target" || exit
fi





echo -e "${CYAN}Done!${RESET}"

