#!/bin/bash
# Update grub background

# Copy background image to GRUB themes directory
sudo cp extra_files/grub_background.png /boot/grub2/themes/system/

# Path to the background in GRUB
GRUB_BG_PATH="/boot/grub2/themes/system/grub_background.png"

# Check if GRUB_BACKGROUND already exists and update or append
if grep -q "^GRUB_BACKGROUND=" /etc/default/grub; then
    # Update existing line
    sudo sed -i "s|^GRUB_BACKGROUND=.*|GRUB_BACKGROUND=\"$GRUB_BG_PATH\"|" /etc/default/grub
elif grep -q "^#GRUB_BACKGROUND=" /etc/default/grub; then
    # Uncomment and update commented line
    sudo sed -i "s|^#GRUB_BACKGROUND=.*|GRUB_BACKGROUND=\"$GRUB_BG_PATH\"|" /etc/default/grub
else
    # Append new line (no existing entry found)
    echo "GRUB_BACKGROUND=\"$GRUB_BG_PATH\"" | sudo tee -a /etc/default/grub > /dev/null
fi

# Regenerate GRUB configuration
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

echo "GRUB background updated successfully"
