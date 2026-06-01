#!/bin/bash
set -e

STARTING_DIR=$(pwd)

# === LOGGING SETUP ===
LOG_DIR="$HOME/fedora-setup-logs"
LOG_FILE="$LOG_DIR/setup-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$LOG_DIR"

# Function to log commands
log_command() {
    echo "=== $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG_FILE"
    echo "Command: $*" >> "$LOG_FILE"
    "$@" >> "$LOG_FILE" 2>&1
    local exit_code=$?
    echo "Exit code: $exit_code" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    return $exit_code
}

# === COLOR SETUP ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# === HELPER FUNCTIONS ===
print_header() {
    echo
    echo -e "${BOLD}${CYAN}========================================${NC}"
    echo -e "${BOLD}${CYAN} $1${NC}"
    echo -e "${BOLD}${CYAN}========================================${NC}"
    echo
    echo "========================================" >> "$LOG_FILE"
    echo " $1" >> "$LOG_FILE"
    echo "========================================" >> "$LOG_FILE"
}

print_step() {
    echo -e "${BLUE}==>${NC} ${BOLD}$1${NC}"
    echo "==> $1" >> "$LOG_FILE"
}

print_action() {
    echo -n "  → $1... "
    echo "  → $1..." >> "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}✓ SUCCESS${NC}"
    echo "✓ SUCCESS" >> "$LOG_FILE"
}

print_fail() {
    echo -e "${RED}✗ FAILED${NC}"
    echo "✗ FAILED" >> "$LOG_FILE"
    if [ -n "$1" ]; then
        echo -e "${RED}    Error: $1${NC}"
        echo "    Error: $1" >> "$LOG_FILE"
    fi
    echo "Full log available at: $LOG_FILE"
    exit 1
}

print_skip() {
    echo -e "${YELLOW}⊘ SKIPPED${NC} - $1"
    echo "⊘ SKIPPED - $1" >> "$LOG_FILE"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
    echo "ℹ $1" >> "$LOG_FILE"
}

# === MAIN SCRIPT ===
print_header "Starting Fedora KDE Automated Setup"
print_info "Logging to: $LOG_FILE"

# Update GRUB background
print_step "Configuring GRUB Background"
print_action "Running update-grub-background.sh"
if log_command sudo ./update-grub-background.sh; then
    print_success
else
    print_fail "GRUB background update failed"
fi

# Get hostname
echo
read -p "Please enter your hostname: " host
print_info "Hostname set to: $host"
echo "Hostname: $host" >> "$LOG_FILE"

print_action "Setting system hostname"
if log_command sudo hostnamectl set-hostname "$host"; then
    print_success
else
    print_fail "Could not set hostname"
fi

# DNF Configuration
print_step "Configuring DNF"
print_action "Enabling parallel downloads (20) and fastest mirror"
if echo -e "max_parallel_downloads=20\nfastestmirror=True" | log_command sudo tee -a /etc/dnf/dnf.conf > /dev/null; then
    print_success
else
    print_fail "DNF configuration failed"
fi

# Firmware updates
print_step "Firmware Updates"
print_action "Checking for firmware updates"
if log_command sudo fwupdmgr get-updates; then
    print_success
    print_action "Applying firmware updates"
    if log_command sudo fwupdmgr update -y; then
        print_success
    else
        print_fail "Firmware update failed"
    fi
else
    print_skip "No firmware updates available"
fi

# System update
print_step "System Update"
print_action "Updating all system packages"
if log_command sudo dnf update -y; then
    print_success
else
    print_fail "System update failed"
fi

# RPM Fusion
print_step "Adding RPM Fusion Repositories"
print_action "Installing RPM Fusion Free"
if log_command sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm; then
    print_success
else
    print_fail "RPM Fusion Free installation failed"
fi

print_action "Installing RPM Fusion Nonfree"
if log_command sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm; then
    print_success
else
    print_fail "RPM Fusion Nonfree installation failed"
fi

# Codecs
print_step "Installing Multimedia Codecs"
print_action "Installing multimedia group"
if log_command sudo dnf group install -y multimedia; then
    print_success
else
    print_fail "Multimedia group installation failed"
fi

print_action "Installing sound-and-video group"
if log_command sudo dnf group install -y sound-and-video; then
    print_success
else
    print_fail "Sound-and-video group installation failed"
fi

print_action "Installing ffmpeg and libs"
if log_command sudo dnf install -y ffmpeg ffmpeg-libs --allowerasing; then
    print_success
else
    print_fail "FFmpeg installation failed"
fi

print_action "Installing GStreamer plugins"
if log_command sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel; then
    print_success
else
    print_fail "GStreamer plugins installation failed"
fi

print_action "Installing additional codecs (lame, excludes lame-devel branches)"
if log_command sudo dnf install -y lame\* --exclude=lame-devel*; then
    print_success
else
    print_fail "Additional codecs installation failed"
fi

print_action "Installing hardware acceleration drivers"
if log_command sudo dnf install -y mesa-va-drivers mesa-vdpau-drivers; then
    print_success
else
    print_fail "Hardware acceleration drivers installation failed"
fi

# Flatpak
print_step "Configuring Flatpak"
print_action "Adding Flathub repository"
if log_command flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; then
    print_success
else
    print_fail "Flathub addition failed"
fi

# Install Apps
print_step "Installing System Applications"
print_action "Installing productivity and utility apps"
if log_command sudo dnf install -y zsh git curl firejail gimp isoimagewriter jq kate \
qbittorrent rclone skanlite vlc make piper wine wireshark.x86_64 \
qdirstat.x86_64 libreoffice.x86_64 kvantum.x86_64 python3 python3-pip \
python3-idle.x86_64 grub2 grub2-tools btrfs-progs btrfs-assistant; then
    print_success
else
    print_fail "Application installation failed"
fi

print_action "Installing gaming and graphics apps"
if log_command sudo dnf install -y protontricks steam lutris gamemode gamescope openrgb.x86_64 \
winetricks vulkan-loader vulkan-tools mesa-vulkan-drivers mesa-vulkan-drivers.i686 \
vulkan-loader.i686; then
    print_success
else
    print_fail "Gaming applications installation failed"
fi

# TeamViewer
print_step "Installing TeamViewer"
print_action "Downloading TeamViewer"
if log_command wget -q https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm; then
    print_success
else
    print_fail "TeamViewer download failed"
fi

print_action "Installing TeamViewer package"
if log_command sudo dnf install -y teamviewer*.rpm; then
    print_success
    rm -f teamviewer*.rpm
else
    print_fail "TeamViewer installation failed"
fi

# Snapper & DNF5 Integration
print_step "Setting up Snapper with DNF5 Integration"
print_action "Installing Snapper and DNF5 actions plugin"
if log_command sudo dnf install -y snapper libdnf5-plugin-actions; then
    print_success
else
    print_fail "Snapper installation failed"
fi

print_action "Configuring Snapper for root filesystem"
if [ ! -f /etc/snapper/configs/root ]; then
    if log_command sudo snapper -c root create-config /; then
        sudo sed -i "s/^ALLOW_USERS=\"\"/ALLOW_USERS=\"$USER\"/" /etc/snapper/configs/root
        sudo sed -i "s/^SYNC_ACL=\"no\"/SYNC_ACL=\"yes\"/" /etc/snapper/configs/root
        print_success
    else
        print_fail "Snapper configuration failed"
    fi
else
    print_skip "Snapper already configured"
fi

print_action "Setting up DNF5 automatic snapshots"
sudo mkdir -p /etc/dnf/libdnf5-plugins/actions.d/
if sudo bash -c "cat > /etc/dnf/libdnf5-plugins/actions.d/snapper.actions" <<'EOF'
# Get snapshot description
pre_transaction::::/usr/bin/sh -c echo\ "tmp.cmd=$(ps\ -o\ command\ --no-headers\ -p\ '${pid}')"

# Creates pre snapshot before the transaction
pre_transaction::::/usr/bin/sh -c echo\ "tmp.snapper_pre_number=$(snapper\ create\ -t\ pre\ -c\ number\ -p\ -d\ '${tmp.cmd}')"

# Creates post snapshot after the transaction
post_transaction::::/usr/bin/sh -c [\ -n\ "${tmp.snapper_pre_number}"\ ]\ &&\ snapper\ create\ -t\ post\ --pre-number\ "${tmp.snapper_pre_number}"\ -c\ number\ -d\ "${tmp.cmd}"\ ;\ echo\ tmp.snapper_pre_number\ ;\ echo\ tmp.cmd
EOF
then
    print_success
    echo "DNF5 actions file created" >> "$LOG_FILE"
else
    print_fail "DNF5 actions configuration failed"
fi

print_action "Configuring snapshot cleanup policies"
if log_command sudo snapper -c root set-config "NUMBER_LIMIT=10" "NUMBER_LIMIT_IMPORTANT=5" && \
   log_command sudo snapper -c root set-config "TIMELINE_LIMIT_HOURLY=3" "TIMELINE_LIMIT_DAILY=5" "TIMELINE_LIMIT_WEEKLY=0" "TIMELINE_LIMIT_MONTHLY=0" "TIMELINE_LIMIT_YEARLY=0"; then
    print_success
else
    print_fail "Snapshot cleanup configuration failed"
fi

print_action "Enabling Snapper cleanup timer"
if log_command sudo systemctl enable --now snapper-cleanup.timer; then
    print_success
else
    print_fail "Snapper cleanup timer failed"
fi

# Virtualization
print_step "Setting up Virtualization"
print_action "Installing virtualization packages"
if log_command sudo dnf install -y @virtualization; then
    print_success
else
    print_fail "Virtualization installation failed"
fi

print_action "Enabling libvirtd service"
if log_command sudo systemctl enable --now libvirtd; then
    print_success
else
    print_fail "libvirtd service failed"
fi

print_action "Adding user to libvirt group"
if log_command sudo usermod -aG libvirt $USER; then
    print_success
else
    print_fail "Adding user to libvirt group failed"
fi

# Flatpak Apps
print_step "Installing Flatpak Applications"
print_action "Installing Flatpak apps (VSCodium, Bitwarden, Discord, etc.)"
if log_command flatpak install flathub -y com.vscodium.codium com.bitwarden.desktop com.getpostman.Postman com.discordapp.Discord com.spotify.Client net.davidotek.pupgui2 nl.hjdskes.gcolor3; then
    print_success
else
    print_fail "Flatpak applications installation failed"
fi

# Terminal Setup
print_step "Setting up Zsh with Oh My Zsh and Powerlevel10k"
print_action "Removing old Oh My Zsh installation"
if rm -rf ~/.oh-my-zsh 2>/dev/null; then
    print_success
else
    print_skip "No existing installation found"
fi

print_action "Changing default shell to Zsh (Enter Password)"
if log_command chsh -s $(which zsh); then
    print_success
else
    print_fail "Shell change failed"
fi

print_action "Installing Oh My Zsh"
export CHSH=no
export RUNZSH=no
export KEEP_ZSHRC=yes
if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >> "$LOG_FILE" 2>&1; then
    print_success
else
    print_fail "Oh My Zsh installation failed"
fi

print_action "Installing Powerlevel10k theme"
if log_command git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k; then
    print_success
else
    print_fail "Powerlevel10k installation failed"
fi

print_action "Setting Powerlevel10k as default theme"
if sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc; then
    print_success
    echo "Powerlevel10k theme set" >> "$LOG_FILE"
else
    print_fail "Theme configuration failed"
fi

print_action "Installing Zsh syntax highlighting plugin"
if log_command git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting; then
    print_success
else
    print_fail "Syntax highlighting plugin installation failed"
fi

print_action "Installing Zsh autosuggestions plugin"
if log_command git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions; then
    print_success
else
    print_fail "Autosuggestions plugin installation failed"
fi

print_action "Enabling Zsh plugins"
if sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc && \
   echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc; then
    print_success
    echo "Zsh plugins enabled" >> "$LOG_FILE"
else
    print_fail "Plugin activation failed"
fi

# Fonts
print_step "Installing Powerlevel10k Fonts"
print_action "Downloading MesloLGS Nerd Fonts"
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
if wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf && \
   wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf && \
   wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf && \
   wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf; then
    print_success
    echo "Fonts downloaded" >> "$LOG_FILE"
else
    print_fail "Font download failed"
fi

print_action "Rebuilding font cache"
if log_command fc-cache -fv; then
    print_success
else
    print_fail "Font cache rebuild failed"
fi

# Second SSD Mount
print_step "Configuring Second SSD Auto-mount"
print_action "Creating mount point"
if log_command sudo mkdir -p /mnt/data; then
    print_success
else
    print_fail "Mount point creation failed"
fi

DEVICE_UUID=$(lsblk -no UUID /dev/nvme1n1p2 2>/dev/null)
echo "Second SSD UUID: $DEVICE_UUID" >> "$LOG_FILE"
if [ -n "$DEVICE_UUID" ]; then
    if ! grep -q "$DEVICE_UUID" /etc/fstab; then
        print_action "Adding drive to /etc/fstab"
        if echo "UUID=$DEVICE_UUID /mnt/data ext4 defaults,noatime,lazytime,commit=60 0 2" | sudo tee -a /etc/fstab >> "$LOG_FILE" && \
           log_command sudo mount -a && \
           log_command sudo chown $USER:$USER /mnt/data; then
            print_success
        else
            print_fail "fstab configuration failed"
        fi
    else
        print_skip "Drive already configured in fstab"
    fi
else
    print_skip "Second SSD not detected (/dev/nvme1n1p2)"
fi

# Btrfs Scrub Timer
print_step "Setting up Monthly Btrfs Scrub"
print_action "Creating Btrfs scrub timer"
if cat <<EOF | sudo tee /etc/systemd/system/btrfs-scrub.timer >> "$LOG_FILE"
[Unit]
Description=Monthly Btrfs scrub on /

[Timer]
OnCalendar=monthly
AccuracySec=1h
Persistent=true

[Install]
WantedBy=timers.target
EOF
then
    print_success
else
    print_fail "Btrfs scrub timer creation failed"
fi

print_action "Creating Btrfs scrub service"
if cat <<EOF | sudo tee /etc/systemd/system/btrfs-scrub.service >> "$LOG_FILE"
[Unit]
Description=Btrfs scrub on /
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/btrfs scrub start -B /
EOF
then
    print_success
else
    print_fail "Btrfs scrub service creation failed"
fi

print_action "Enabling Btrfs scrub timer"
if log_command sudo systemctl daemon-reload && log_command sudo systemctl enable --now btrfs-scrub.timer; then
    print_success
else
    print_fail "Btrfs scrub timer activation failed"
fi

# Enable Services
print_step "Enabling System Services"
print_action "Enabling fstrim timer (weekly SSD TRIM)"
if log_command sudo systemctl enable --now fstrim.timer; then
    print_success
else
    print_fail "fstrim timer failed"
fi

print_action "Enabling ratbagd (gaming mouse daemon)"
if log_command sudo systemctl enable --now ratbagd; then
    print_success
else
    print_fail "ratbagd service failed"
fi

print_action "Configuring Firejail"
if log_command sudo firecfg; then
    print_success
else
    print_fail "Firejail configuration failed"
fi

# GRUB-BTRFS
print_step "Installing GRUB-BTRFS"
cd ~
print_action "Cloning grub-btrfs repository"
if log_command git clone https://github.com/Antynea/grub-btrfs.git; then
    print_success
else
    print_fail "grub-btrfs clone failed"
fi

cd grub-btrfs
print_action "Configuring grub-btrfs for Fedora"
if sed -i 's|^#\?GRUB_BTRFS_GRUB_DIRNAME=.*|GRUB_BTRFS_GRUB_DIRNAME="/boot/grub2"|' config && \
   sed -i 's|^#\?GRUB_BTRFS_MKCONFIG=.*|GRUB_BTRFS_MKCONFIG=grub2-mkconfig|' config && \
   sed -i 's|^#\?GRUB_BTRFS_SCRIPT_CHECK=.*|GRUB_BTRFS_SCRIPT_CHECK=grub2-script-check|' config; then
    print_success
    echo "grub-btrfs configured for Fedora" >> "$LOG_FILE"
else
    print_fail "grub-btrfs configuration failed"
fi

print_action "Installing grub-btrfs"
if log_command sudo make install; then
    print_success
else
    print_fail "grub-btrfs installation failed"
fi

print_action "Updating GRUB configuration"
if log_command sudo grub2-mkconfig -o /boot/grub2/grub.cfg; then
    print_success
else
    print_fail "GRUB update failed"
fi

cd ..
rm -rf ~/grub-btrfs

print_action "Enabling grub-btrfsd service"
if log_command sudo systemctl enable --now grub-btrfsd.service; then
    print_success
else
    print_skip "Will be enabled after grub-btrfs installation"
fi

# Plymouth NumLock Fix
print_step "Fixing Plymouth NumLock Issue"
cd ~
print_action "Cloning dracut-numlock repository"
if log_command git clone https://github.com/FivEawE/dracut-numlock.git; then
    print_success
else
    print_fail "dracut-numlock clone failed"
fi

cd dracut-numlock
print_action "Installing dracut-numlock module"
if sudo cp -r 50numlock/ /usr/lib/dracut/modules.d/; then
    print_success
    print_info "Initramfs will be rebuilt during Plymouth theme installation"
    echo "dracut-numlock module installed" >> "$LOG_FILE"
else
    print_fail "dracut-numlock installation failed"
fi

cd ..
rm -rf ~/dracut-numlock

# Plymouth Themes
print_step "Installing Plymouth Themes"
cd ~
print_action "Cloning plymouth-themes repository"
if log_command git clone https://github.com/adi1090x/plymouth-themes.git; then
    print_success
else
    print_fail "plymouth-themes clone failed"
fi

cd plymouth-themes
print_action "Installing Plymouth KCM and script plugin"
if log_command sudo dnf install -y plymouth-kcm plymouth-plugin-script; then
    print_success
else
    print_fail "Plymouth plugins installation failed"
fi

print_action "Installing custom themes (deus_ex, dragon, glitch)"
if sudo cp -r pack_2/deus_ex /usr/share/plymouth/themes && \
   sudo cp -r pack_2/dragon /usr/share/plymouth/themes && \
   sudo cp -r pack_2/glitch /usr/share/plymouth/themes; then
    print_success
    echo "Plymouth themes installed" >> "$LOG_FILE"
else
    print_fail "Theme installation failed"
fi

print_action "Setting glitch theme as default"
if log_command sudo plymouth-set-default-theme -R glitch; then
    print_success
else
    print_fail "Theme activation failed"
fi

cd ..
rm -rf ~/plymouth-themes

# Move around files
print_step "Moving extra_files to target destinations"
print_action "Moving extra_files to target destinations"
cd $STARTING_DIR
if cp -f extra_files/.zshrc ~ && \
   sudo cp -f extra_files/fedora-logo-grayscale.ico /usr/share/pixmaps/; then
   print_success
   print_info "Files moved successfully"
   echo "Extra files moved" >> "$LOG_FILE"
else
   print_fail "File move failed"
fi

#Setup firejail firefox profile
print_step "Creating firejail file transfer environment"
print_action "Moving firejail.local to /etc/firejail"
if sudo cp -f extra_files/firefox.local /etc/firejail/; then
   print_success
   print_info "firejail.local moved to /etc/firejail"
   echo "firefox.local installed" >> "$LOG_FILE"
else
   print_fail "firejail.local move failed"
fi

print_action "Creating ~/Transfers directory"
if cp -r extra_files/Transfers $HOME; then
   print_success
   print_info "~/Transfers directory created"
   echo "Transfers directory created" >> "$LOG_FILE"
else
   print_fail "Unable to create ~/Transfers"
fi

# Final Snapshot
print_step "Creating Initial System Snapshot"
print_action "Taking snapshot of completed setup"
if log_command sudo snapper -c root create --description "Initial install"; then
    print_success
    print_info "Snapshot created successfully"
else
    print_fail "Snapshot creation failed"
fi

# Generate TODO
print_action "Generating TODO list on desktop"
if cat <<EOF > ~/Desktop/TODO
TODO (Manual steps):
1. Reboot system
2. After reboot, set Konsole font to 'MesloLGS NF'
3. Run 'p10k configure' in a new terminal
4. Log into: Steam, Discord, Spotify, Bitwarden, Firefox
5. Install Betterfox profile for Firefox
6. All Done!

Setup log: $LOG_FILE
EOF
then
    print_success
    echo "TODO file created" >> "$LOG_FILE"
else
    print_fail "TODO list creation failed"
fi

# Final Message
echo
print_header "Setup Complete!"
echo
print_info "Your system is now configured and ready to use."
print_info "A TODO list has been created on your desktop."
print_info "Full installation log: $LOG_FILE"
echo
echo -e "${YELLOW}${BOLD}IMPORTANT:${NC} You should ${BOLD}reboot${NC} now to apply all changes."
echo
read -p "Reboot now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Rebooting system..."
    echo "System rebooting..." >> "$LOG_FILE"
    sudo reboot
else
    print_info "Please reboot manually when ready."
    echo "Reboot deferred by user" >> "$LOG_FILE"
fi
