# Fedora KDE Automated Setup Script

A comprehensive, production-ready automated setup script for Fedora KDE with color-coded output, Btrfs snapshots, GRUB integration, and extensive system configuration.

##  Features

###  Automated Snapshot Management
- **Pre/Post DNF snapshots** - Automatically creates snapshots before and after every package operation
- **GRUB boot menu integration** - Boot into any snapshot directly from GRUB
- **Smart cleanup policies** - Keeps 10 recent snapshots, 5 important ones
- **Monthly Btrfs scrubbing** - Automated filesystem integrity checks

###  Gaming & Multimedia
- Steam, Lutris, GameMode, Gamescope
- Full multimedia codec support (H.264, MP3, AAC, etc.)
- Vulkan drivers with 32-bit support
- Hardware video acceleration (VA-API, VDPAU)
- RGB peripheral control (OpenRGB + Piper)
- ProtonTricks and ProtonUp-Qt for game compatibility

###  Development Environment
- Python 3 with pip and IDLE
- VSCodium (via Flatpak)
- Postman API testing
- Git, curl, jq
- Full virtualization stack (KVM/QEMU/virt-manager)

###  Customization
- Custom GRUB background
- Custom Plymouth boot themes
- Zsh with Oh My Zsh and Powerlevel10k
- MesloLGS Nerd Fonts
- Kvantum theme engine
- Custom .zshrc configuration
- Custom Fedora grayscale icon

###  System Optimization
- Parallel DNF downloads (20 concurrent)
- Fastest mirror auto-selection
- SSD optimizations (TRIM, noatime, lazy time)
- Automated firmware updates
- Firejail application sandboxing
- Monthly Btrfs scrubbing
- Weekly SSD TRIM scheduling

###  User Experience
- **Color-coded output** - Clear visual feedback for every operation
- **Progress indicators** - Know exactly what's happening
- **Error handling** - Graceful failure with helpful messages
- **Idempotent operations** - Safe to re-run

##  Prerequisites

- **Fresh Fedora KDE installation** (Fedora 41-43 tested)
- **Btrfs root filesystem** (required for snapshots)
- **Internet connection**
- **Second NVMe SSD** at `/dev/nvme1n1p2` (optional - for data storage)
- **Sudo/root access**

##  Required Files Structure
```
.
├── fedora-setup.sh                    # Main setup script
├── update-grub-background.sh          # GRUB background updater script
└── extra_files/
    ├── grub_background.png            # Custom GRUB background image
    ├── .zshrc                         # Custom Zsh configuration
    └── fedora-logo-grayscale.ico     # Custom Fedora icon
```

##  Installation

### 1. Download/Clone the Script
```bash
# Option 1: Clone repository
git clone https://github.com/ssimpson-netops/fedora-setup.git
cd fedora-setup

# Option 2: Download files manually
# Make sure you have all files in the correct structure
```

### 2. Prepare Extra Files

Ensure you have these files in the `extra_files/` directory:
- **grub_background.png** - Your desired GRUB background (1920x1080 recommended)
- **.zshrc** - Your customized Zsh configuration
- **fedora-logo-grayscale.ico** - Custom Fedora icon

### 3. Make Scripts Executable
```bash
chmod +x fedora-setup.sh
chmod +x update-grub-background.sh
```

### 4. Run the Script
```bash
./fedora-setup.sh
```

The script will prompt you for your desired hostname at the start.

### 5. Wait for Completion

Installation takes **30-60 minutes** depending on:
- Internet connection speed
- System specifications
- Number of updates available

### 6. Reboot
```bash
# The script will prompt you to reboot
# Or reboot manually:
sudo reboot
```

##  What Gets Installed

### System Utilities
| Package | Purpose |
|---------|---------|
| **Snapper** | Btrfs snapshot management |
| **Btrfs Assistant** | GUI for snapshot management |
| **QDirStat** | Disk usage analyzer |
| **Wireshark** | Network protocol analyzer |
| **Firejail** | Application sandboxing |
| **ISO Image Writer** | Create bootable USB drives |
| **TeamViewer** | Remote desktop support |

### Productivity
| Package | Purpose |
|---------|---------|
| **LibreOffice** | Office suite |
| **GIMP** | Image editing |
| **Kate** | Advanced text editor |
| **qBittorrent** | Torrent client |
| **VLC** | Media player |
| **Skanlite** | Scanner utility |

### Development
| Package | Purpose |
|---------|---------|
| **Python 3** | Programming language with pip |
| **VSCodium** | Open source VS Code (Flatpak) |
| **Postman** | API testing (Flatpak) |
| **virt-manager** | Virtual machine management |
| **Git** | Version control |

### Communication & Entertainment
| Package | Purpose |
|---------|---------|
| **Discord** | Voice/text chat (Flatpak) |
| **Spotify** | Music streaming (Flatpak) |
| **Bitwarden** | Password manager (Flatpak) |

### Gaming
| Package | Purpose |
|---------|---------|
| **Steam** | Game platform |
| **Lutris** | Game launcher/manager |
| **GameMode** | Performance optimization |
| **Gamescope** | Gaming compositor |
| **ProtonTricks** | Proton compatibility tool |
| **ProtonUp-Qt** | Proton version manager (Flatpak) |
| **OpenRGB** | RGB peripheral control |
| **Piper** | Gaming mouse configuration |

### Themes & Customization
| Package | Purpose |
|---------|---------|
| **Oh My Zsh** | Zsh framework |
| **Powerlevel10k** | Zsh theme |
| **MesloLGS NF** | Nerd Font for icons |
| **Plymouth Themes** | Custom boot splash screens |
| **Kvantum** | Qt theme engine |
| **Gcolor3** | Color picker (Flatpak) |

##  Post-Installation Steps

The script creates a TODO list on your desktop with these manual steps:

### 1. Reboot System
```bash
sudo reboot
```

### 2. Configure Konsole Font
- Open Konsole
- Settings → Edit Current Profile → Appearance → Font
- Select **"MesloLGS NF"**
- Apply changes

### 3. Configure Powerlevel10k
```bash
p10k configure
```
Follow the interactive wizard to customize your prompt.

### 4. Log Into Applications
- Steam
- Discord
- Spotify
- Bitwarden
- Firefox Sync

### 5. Install Betterfox (Optional)
Optimize Firefox performance and privacy:
1. Visit [Betterfox GitHub](https://github.com/yokoffing/Betterfox)
2. Navigate to `about:support` in Firefox
3. Click "Profile Folder" → "Open Folder"
4. Copy `user.js` to profile directory
5. Restart Firefox

##  Customization Options

### Change Hostname
The script prompts for hostname. To set a default, modify line 54:
```bash
# Remove the read prompt and set directly:
host="your-hostname-here"
```

### Adjust DNF Parallel Downloads
Modify line 67:
```bash
echo -e "max_parallel_downloads=30\nfastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf > /dev/null
```

### Skip Second SSD Automount
Comment out or remove lines 385-405 if you don't have a second drive.

### Modify Snapshot Retention
Edit lines 254-255:
```bash
# Keep 20 DNF snapshots instead of 10
sudo snapper -c root set-config "NUMBER_LIMIT=20" "NUMBER_LIMIT_IMPORTANT=10"
```

### Change Plymouth Theme
Edit line 561:
```bash
# Use different theme (deus_ex, dragon, or glitch)
sudo plymouth-set-default-theme -R dragon
```

### Laptop vs Desktop
For laptops, comment out gaming packages (lines 169-171):
```bash
# print_action "Installing gaming and graphics apps"
# if sudo dnf install -y protontricks steam lutris gamemode gamescope openrgb.x86_64 \
# winetricks vulkan-loader vulkan-tools mesa-vulkan-drivers mesa-vulkan-drivers.i686 \
# vulkan-loader.i686 &>/dev/null; then
```

##  Snapshot Management

### Automatic Snapshots
Every DNF operation automatically creates pre/post snapshots. Check them:
```bash
sudo snapper list
```

### Boot from Snapshot
1. Reboot system
2. In GRUB, select **"Fedora Linux snapshots"**
3. Choose snapshot to boot
4. If system works, make it permanent:
```bash
   sudo snapper rollback
   sudo reboot
```

### Manual Snapshots
```bash
# Create snapshot before risky changes
sudo snapper -c root create -d "Before major system change"

# List all snapshots
sudo snapper list

# Compare snapshots
sudo snapper status 5..8

# Delete snapshot
sudo snapper delete 7
```

### Using Btrfs Assistant (GUI)
```bash
# Launch GUI
btrfs-assistant

# Or from application menu
```

For detailed recovery procedures, see [RECOVERY.md](RECOVERY.md).

##  System Services Enabled

| Service | Purpose | Schedule |
|---------|---------|----------|
| `libvirtd` | Virtual machine support | Always running |
| `fstrim.timer` | SSD TRIM optimization | Weekly |
| `ratbagd` | Gaming mouse daemon | Always running |
| `grub-btrfsd` | Auto-update GRUB with snapshots | On snapshot creation |
| `snapper-cleanup.timer` | Automatic snapshot cleanup | Hourly |
| `btrfs-scrub.timer` | Filesystem integrity check | Monthly |

##  Important File Locations

| Item | Location |
|------|----------|
| **Oh My Zsh** | `~/.oh-my-zsh/` |
| **Powerlevel10k config** | `~/.p10k.zsh` |
| **Zsh config** | `~/.zshrc` |
| **Fonts** | `~/.local/share/fonts/` |
| **Flatpak apps** | `~/.var/app/` |
| **Firejail profiles** | `~/.config/firejail/` |
| **VM storage** | `/var/lib/libvirt/images/` |
| **Snapshots** | `/.snapshots/` |
| **Snapper config** | `/etc/snapper/configs/root` |
| **DNF5 actions** | `/etc/dnf/libdnf5-plugins/actions.d/` |
| **Data mount** | `/mnt/data` (if second SSD present) |
| **GRUB background** | `/boot/grub2/themes/system/grub_background.png` |
| **Custom icon** | `/usr/share/pixmaps/fedora-logo-grayscale.ico` |

##  Troubleshooting

### Script Fails Early
**Problem:** Script exits with error during early stages

**Solution:**
```bash
# Check what failed (error message shows the step)
# Re-run the script - many operations are idempotent
./fedora-setup.sh

# Or run specific sections manually
```

### Snapshots Don't Appear in GRUB
**Problem:** No snapshot submenu in GRUB

**Solution:**
```bash
# Check grub-btrfsd service
sudo systemctl status grub-btrfsd
sudo journalctl -u grub-btrfsd -n 50

# Manually regenerate GRUB
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Verify snapshots exist
sudo snapper list
```

### Zsh Not Default After Reboot
**Problem:** Still using bash after installation

**Solution:**
```bash
chsh -s $(which zsh)
# Log out and back in
```

### Powerlevel10k Not Loading
**Problem:** Terminal shows default prompt

**Solution:**
```bash
# Verify installation
ls ~/.oh-my-zsh/custom/themes/powerlevel10k/

# Check .zshrc
grep powerlevel10k ~/.zshrc

# Reload config
source ~/.zshrc

# Run configuration wizard
p10k configure
```

### Second SSD Not Mounting
**Problem:** /mnt/data not accessible

**Solution:**
```bash
# Check if device exists
lsblk
sudo blkid

# Verify fstab entry
cat /etc/fstab | grep data

# Try manual mount
sudo mount -a

# Check for errors
sudo dmesg | grep nvme1n1p2
```

### NumLock Still Off at LUKS Screen
**Problem:** NumLock not enabled during encryption password entry

**Solution:**
```bash
# Verify dracut-numlock installed
ls /usr/lib/dracut/modules.d/50numlock/

# Rebuild initramfs
sudo dracut -f

# Reboot to test
sudo reboot
```

### Plymouth Theme Not Applied
**Problem:** Default theme shows instead of custom theme

**Solution:**
```bash
# Check installed themes
plymouth-set-default-theme --list

# Verify theme files
ls /usr/share/plymouth/themes/glitch/

# Set theme and rebuild
sudo plymouth-set-default-theme -R glitch

# Check for script plugin
rpm -q plymouth-plugin-script
```

### Virtual Machines Won't Start
**Problem:** Permission denied or libvirt errors

**Solution:**
```bash
# Check user groups
groups $USER  # Should include 'libvirt'

# Add to group if missing
sudo usermod -aG libvirt $USER
# Log out and back in

# Check service
sudo systemctl status libvirtd
```

### Flatpak Apps Not Installing
**Problem:** Flatpak installation fails

**Solution:**
```bash
# Verify Flathub is added
flatpak remotes

# Add Flathub manually
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Try installing individual apps
flatpak install flathub com.discordapp.Discord
```

##  Known Limitations

- **Requires Btrfs root filesystem** - Snapshots won't work with ext4
- **Second SSD path hardcoded** to `/dev/nvme1n1p2`
- **Assumes AMD/Intel graphics** - NVIDIA users need to add drivers manually
- **GRUB-BTRFS built from source** - No automatic updates
- **Script must be run from its directory** - Uses relative paths for extra_files

### For NVIDIA GPU Users

Add after line 171:
```bash
print_action "Installing NVIDIA drivers"
if sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda nvidia-vaapi-driver &>/dev/null; then
    print_success
else
    print_fail "NVIDIA driver installation failed"
fi
```

## 🔄 Updates & Maintenance

### System Updates
```bash
# Normal updates (auto-snapshots)
sudo dnf upgrade

# Major version upgrade
sudo dnf system-upgrade download --releasever=44
sudo dnf system-upgrade reboot
```

### Update GRUB-BTRFS
Since it's built from source:
```bash
cd ~
git clone https://github.com/Antynea/grub-btrfs.git
cd grub-btrfs
git pull
sudo make install
sudo systemctl restart grub-btrfsd
```

### Update Plymouth Themes
```bash
cd ~
git clone https://github.com/adi1090x/plymouth-themes.git
cd plymouth-themes
# Copy desired themes
sudo cp -r pack_2/theme_name /usr/share/plymouth/themes/
sudo plymouth-set-default-theme -R theme_name
```

##  Performance Optimizations

-  Parallel DNF downloads (20x faster package installation)
-  Fastest mirror auto-selection
-  SSD optimizations (noatime, lazytime, commit=60)
-  Automatic weekly TRIM
-  Monthly Btrfs scrubbing
-  GameMode for automatic gaming performance
-  Vulkan for better GPU performance
-  Hardware video acceleration

##  Security Features

-  **Firejail** - Automatic sandboxing of applications
-  **SELinux** - Enabled by default on Fedora
-  **Bitwarden** - Secure password management
-  **Btrfs snapshots** - Quick recovery from mistakes
-  **Regular updates** - Script updates system first
-  **Firmware updates** - Automated security patches

##  Contributing

This is a personal setup script, but suggestions are welcome:
- Open issues for bugs
- Submit PRs for improvements
- Share your customizations

##  License

Provided as-is for personal use. Modify freely for your needs.

##  Credits

- **Snapper** - SUSE snapshot management tool
- **GRUB-BTRFS** - [Antynea](https://github.com/Antynea/grub-btrfs) for GRUB integration
- **Powerlevel10k** - [romkatv](https://github.com/romkatv/powerlevel10k) for amazing Zsh theme
- **Oh My Zsh** - Community Zsh framework
- **Plymouth Themes** - [adi1090x](https://github.com/adi1090x/plymouth-themes) for boot themes
- **dracut-numlock** - [FivEawE](https://github.com/FivEawE/dracut-numlock) for NumLock fix
- **Fedora Project** - For excellent Linux distribution

##  Support

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review [RECOVERY.md](RECOVERY.md) for snapshot recovery
3. Check logs: `sudo journalctl -xe`
4. Visit [Fedora Discussion](https://discussion.fedoraproject.org/)
5. Check [r/Fedora](https://reddit.com/r/fedora)

##  Changelog

### Version 2.0 (Current)
-  Added color-coded output for all operations
-  Implemented comprehensive error handling
-  Added DNF5 automatic snapshot integration
-  Integrated GRUB-BTRFS for snapshot booting
-  Added Plymouth NumLock fix
-  Custom GRUB background support
-  Custom Plymouth theme installation
-  Improved idempotency
-  Added progress indicators
-  Enhanced documentation

### Version 1.0
- Initial release with basic package installation

---

**Last Updated:** February 2026  
**Tested On:** Fedora 43 KDE Spin  
**Filesystem:** Btrfs (required)  
**Maintained By:** Scott Simpson

---

##  Quick Start Summary
```bash
# 1. Ensure all files are in place
ls extra_files/  # Should contain: grub_background.png, .zshrc, fedora-logo-grayscale.ico

# 2. Make scripts executable
chmod +x fedora-setup.sh update-grub-background.sh

# 3. Run setup
./fedora-setup.sh

# 4. Follow prompts and wait ~30-60 minutes

# 5. Reboot when complete
sudo reboot

# 6. Complete post-installation steps from ~/Desktop/TODO
```

**Enjoy your fully configured Fedora KDE system!**
