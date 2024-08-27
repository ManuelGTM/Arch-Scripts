!#/usr/bin/bash

#!/usr/bin/bash

# Color definitions
RESET='\033[0m'
BOLD='\033[1m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
RED='\033[31m'

# Define variables
SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SERVICE_DIR/update_system.service"
TIMER_FILE="$SERVICE_DIR/update_system.timer"
UPDATE_SCRIPT="$HOME/update_system.sh"

# Create the update script
echo -e "${CYAN}Creating the update script...${RESET}"
cat <<'EOF' > "$UPDATE_SCRIPT"
#!/usr/bin/bash

# Update system packages
echo "Updating system packages..."
sudo pacman -Syu --noconfirm

# Optional: Clean the pacman cache
echo "Cleaning pacman cache..."
sudo pacman -Scc --noconfirm

echo "System update completed."
EOF

# Make the update script executable
chmod +x "$UPDATE_SCRIPT"
echo -e "${GREEN}Update script created successfully!${RESET}"

# Create systemd service directory if it doesn't exist
mkdir -p "$SERVICE_DIR"

# Create the systemd service file
echo -e "${CYAN}Creating the systemd service file...${RESET}"
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Weekly System Update

[Service]
ExecStart=$UPDATE_SCRIPT
EOF
echo -e "${GREEN}Service file created successfully!${RESET}"

# Create the systemd timer file
echo -e "${CYAN}Creating the systemd timer file...${RESET}"
cat <<EOF > "$TIMER_FILE"
[Unit]
Description=Run System Update Weekly

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
EOF
echo -e "${GREEN}Timer file created successfully!${RESET}"

# Reload the systemd user daemon
echo -e "${YELLOW}Reloading systemd daemon...${RESET}"
systemctl --user daemon-reload
echo -e "${GREEN}Systemd daemon reloaded.${RESET}"

# Enable and start the timer
echo -e "${YELLOW}Enabling and starting the systemd timer...${RESET}"
systemctl --user enable update_system.timer
systemctl --user start update_system.timer

echo -e "${BLUE}Setup complete. Your system will now update weekly.${RESET}"

