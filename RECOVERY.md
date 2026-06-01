# Fedora Btrfs Snapshot Recovery Guide

Comprehensive guide for recovering your Fedora system using Snapper snapshots when things go wrong.

## Table of Contents

1. [Quick Recovery Methods](#quick-recovery-methods)
2. [Recovery Scenarios](#recovery-scenarios)
3. [Bootable System Recovery](#bootable-system-recovery)
4. [Non-Bootable System Recovery](#non-bootable-system-recovery)
5. [Emergency Recovery from Live USB](#emergency-recovery-from-live-usb)
6. [Snapshot Management](#snapshot-management)
7. [Troubleshooting](#troubleshooting)

---

## Quick Recovery Methods

### Method 1: GRUB Menu (Easiest - System Boots)

**When to use:** System boots but software is broken/misconfigured

1. **Reboot your system**
```bash
   sudo reboot
```

2. **Access GRUB menu**
   - Press `ESC` or hold `Shift` during boot
   - You should see the GRUB bootloader menu

3. **Select snapshot submenu**
   - Navigate to **"Fedora Linux snapshots"**
   - Press `Enter`

4. **Choose snapshot**
   - You'll see a list of snapshots with dates/descriptions
   - Use arrow keys to select a known-good snapshot
   - Press `Enter` to boot

5. **System boots read-only**
   - The snapshot boots in read-only mode
   - Test if everything works as expected
   - Your current (broken) system is still intact

6. **Make snapshot permanent** (if everything works)
```bash
   sudo snapper rollback
   sudo reboot
```

   The system will now boot to this snapshot by default.

---

### Method 2: Command Line Rollback (System Boots)

**When to use:** System boots, you can log in, but something is wrong

1. **List available snapshots**
```bash
   sudo snapper list
```

   Output example:
```
    # | Type   | Pre # | Date                     | User | Description
   ---+--------+-------+--------------------------+------+------------------
    0 | single |       | 2026-02-01 10:00:00      | root | current
    1 | single |       | 2026-02-01 09:00:00      | root | Initial install
    2 | pre    |       | 2026-02-02 14:30:00      | root | DNF5_Transaction
    3 | post   |     2 | 2026-02-02 14:35:00      | root | DNF5_Transaction
    4 | single |       | 2026-02-03 08:00:00      | root | Before testing
```

2. **Identify the snapshot to restore**
   - Note the snapshot number (e.g., snapshot #4)
   - Check the date and description

3. **Compare changes** (optional)
```bash
   # See what changed between current system and snapshot #4
   sudo snapper status 4..0
```

4. **Perform rollback**
```bash
   # Rollback to most recent snapshot
   sudo snapper rollback
   
   # OR rollback to specific snapshot number
   sudo snapper rollback 4
```

5. **Reboot**
```bash
   sudo reboot
```

   Your system will boot into the restored snapshot.

---

### Method 3: Btrfs Assistant GUI

**When to use:** You prefer graphical tools and system boots

1. **Launch Btrfs Assistant**
```bash
   btrfs-assistant
```
   Or find it in your application menu

2. **Navigate to Snapshots tab**
   - View all available snapshots
   - See dates, types, and descriptions

3. **Select snapshot to restore**
   - Click on the desired snapshot
   - Click **"Restore"** button

4. **Confirm restoration**
   - Review changes that will be made
   - Confirm the restoration

5. **Reboot system**
```bash
   sudo reboot
```

---

## Recovery Scenarios

### Scenario 1: Bad Software Update

**Problem:** After `dnf upgrade`, system is unstable/broken

**Solution:**

1. **Boot into GRUB snapshot menu**
   - Select the pre-update snapshot (look for "DNF5_Transaction" type "pre")

2. **Verify system works**
   - Test critical applications
   - Check if issue is resolved

3. **Make it permanent**
```bash
   sudo snapper rollback
   sudo reboot
```

4. **Investigate the problem**
   - After booting to good state, check what packages caused issues
   - Hold problematic packages or wait for fixes

---

### Scenario 2: Broken Configuration File

**Problem:** Edited `/etc/` config file, now service won't start

**Solution:**

1. **List recent snapshots**
```bash
   sudo snapper list
```

2. **Find snapshot before config change**
   - Note the snapshot number

3. **Compare specific file**
```bash
   # See what changed in /etc/ssh/sshd_config between snapshots
   sudo snapper diff 3..0 /etc/ssh/sshd_config
```

4. **Restore single file** (instead of full rollback)
```bash
   # Mount snapshot #3 read-only
   sudo mount -o subvol=.snapshots/3/snapshot /dev/mapper/luks_root /mnt
   
   # Copy the good config file back
   sudo cp /mnt/etc/ssh/sshd_config /etc/ssh/sshd_config
   
   # Unmount
   sudo umount /mnt
   
   # Restart service
   sudo systemctl restart sshd
```

5. **Or full rollback if needed**
```bash
   sudo snapper rollback 3
   sudo reboot
```

---

### Scenario 3: Accidentally Deleted Important Files

**Problem:** Deleted files from `/home` or `/etc` by mistake

**Solution:**

1. **Identify when files existed**
   - Check snapshot dates
```bash
   sudo snapper list
```

2. **Mount snapshot containing files**
```bash
   # Create mount point
   sudo mkdir -p /mnt/snapshot
   
   # Mount snapshot #5 (replace with your snapshot number)
   sudo mount -o subvol=.snapshots/5/snapshot /dev/mapper/luks_root /mnt/snapshot
```

3. **Navigate to deleted files**
```bash
   # Find your files
   ls /mnt/snapshot/home/$USER/Documents/
   ls /mnt/snapshot/etc/
```

4. **Copy files back**
```bash
   # Copy files to current system
   sudo cp -r /mnt/snapshot/home/$USER/Documents/important_file.txt ~/Documents/
   
   # Fix ownership if needed
   sudo chown $USER:$USER ~/Documents/important_file.txt
```

5. **Unmount snapshot**
```bash
   sudo umount /mnt/snapshot
```

---

### Scenario 4: Broken Package Dependencies

**Problem:** DNF/package system is broken, can't install/remove packages

**Solution:**

1. **Boot to pre-breakage snapshot via GRUB**
   - Select snapshot from before dependency issues

2. **Or use command line rollback**
```bash
   # Find snapshot before breakage
   sudo snapper list
   
   # Rollback
   sudo snapper rollback 4
   sudo reboot
```

3. **After recovery, fix the issue**
   - Research the problematic packages
   - Use `dnf distro-sync` to resolve conflicts
   - Or wait for repository fixes

---

## Bootable System Recovery

### System Boots but is Unstable

**Quick Recovery:**
```bash
# 1. List snapshots
sudo snapper list

# 2. Choose last known good snapshot (example: #6)
sudo snapper rollback 6

# 3. Reboot
sudo reboot
```

**Detailed Recovery:**
```bash
# 1. Compare current system to snapshot
sudo snapper status 6..0

# 2. See file-level changes
sudo snapper diff 6..0 /etc/fstab

# 3. Test boot the snapshot first via GRUB
sudo reboot
# Select snapshot from GRUB menu

# 4. If good, make permanent
sudo snapper rollback
sudo reboot
```

---

## Non-Bootable System Recovery

### GRUB Appears but Kernel Panics

**Recovery Steps:**

1. **Access GRUB menu**
   - Press `ESC` or hold `Shift` during boot

2. **Select "Fedora Linux snapshots"**

3. **Boot older snapshot**
   - Choose a snapshot from before the kernel panic
   - Usually a pre-DNF update snapshot

4. **System should boot successfully**

5. **Make it permanent**
```bash
   sudo snapper rollback
   sudo reboot
```

6. **Fix the kernel issue**
   - Remove problematic kernel:
```bash
     sudo dnf remove kernel-6.x.x
```
   - Or wait for kernel fix and update again

---

### GRUB Doesn't Show Snapshots

**Problem:** GRUB menu doesn't list snapshots submenu

**Quick Fix:**

1. **Boot into any working kernel**
   - Select any Fedora kernel from GRUB

2. **Regenerate GRUB config**
```bash
   sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

3. **Check grub-btrfsd service**
```bash
   sudo systemctl status grub-btrfsd
   sudo systemctl restart grub-btrfsd
```

4. **Reboot and verify**
```bash
   sudo reboot
```

---

## Emergency Recovery from Live USB

### System Won't Boot at All

**Full recovery procedure:**

#### Step 1: Boot Fedora Live USB

1. Insert Fedora Live USB
2. Boot from USB (F12, F11, or ESC during boot)
3. Select "Try Fedora" or "Live Environment"

#### Step 2: Unlock Encrypted Drive (if using LUKS)
```bash
# Open terminal in live environment

# List block devices to find your system partition
lsblk

# Expected output:
# nvme0n1
# ├─nvme0n1p1  (EFI partition)
# └─nvme0n1p2  (LUKS encrypted Fedora)

# Unlock LUKS partition
sudo cryptsetup open /dev/nvme0n1p2 luks_root

# Enter your encryption password
```

#### Step 3: Mount Btrfs Filesystem
```bash
# Mount the unlocked partition
sudo mount /dev/mapper/luks_root /mnt

# If not encrypted, mount directly:
# sudo mount /dev/nvme0n1p2 /mnt
```

#### Step 4: List Available Snapshots
```bash
# List Btrfs subvolumes
sudo btrfs subvolume list /mnt

# Output example:
# ID 256 gen 123 top level 5 path root
# ID 257 gen 124 top level 5 path home
# ID 258 gen 100 top level 5 path .snapshots/1/snapshot
# ID 259 gen 110 top level 5 path .snapshots/2/snapshot
# ID 260 gen 115 top level 5 path .snapshots/3/snapshot

# View snapshot details
ls -la /mnt/.snapshots/

# Check snapshot info
cat /mnt/.snapshots/3/info.xml
```

#### Step 5: Identify Good Snapshot
```bash
# Mount a snapshot to inspect it
sudo mkdir -p /mnt/test
sudo mount -o subvol=.snapshots/3/snapshot /dev/mapper/luks_root /mnt/test

# Check if it looks good
ls /mnt/test/
ls /mnt/test/etc/
ls /mnt/test/home/

# Unmount when done
sudo umount /mnt/test
```

#### Step 6: Restore from Snapshot

**Method A: Safe Rollback (keeps broken system)**
```bash
# Unmount if mounted
sudo umount /mnt 2>/dev/null

# Remount top-level Btrfs
sudo mount /dev/mapper/luks_root /mnt

# Rename broken root subvolume
sudo mv /mnt/root /mnt/root.broken

# Create new root from snapshot #3
sudo btrfs subvolume snapshot /mnt/.snapshots/3/snapshot /mnt/root

# Unmount
sudo umount /mnt

# Reboot
sudo reboot
```

**Method B: Clean Rollback (deletes broken system)**
```bash
# Unmount if mounted
sudo umount /mnt 2>/dev/null

# Remount top-level Btrfs
sudo mount /dev/mapper/luks_root /mnt

# Delete broken root subvolume
sudo btrfs subvolume delete /mnt/root

# Create new root from snapshot #3
sudo btrfs subvolume snapshot /mnt/.snapshots/3/snapshot /mnt/root

# Unmount
sudo umount /mnt

# Reboot
sudo reboot
```

#### Step 7: Fix Bootloader (if needed)

If system still won't boot after restoration:
```bash
# Remount the restored system
sudo mount -o subvol=root /dev/mapper/luks_root /mnt

# Mount EFI partition
sudo mount /dev/nvme0n1p1 /mnt/boot/efi

# Mount necessary filesystems for chroot
sudo mount -t proc /proc /mnt/proc
sudo mount --rbind /sys /mnt/sys
sudo mount --rbind /dev /mnt/dev

# Chroot into system
sudo chroot /mnt

# Reinstall GRUB
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-install /dev/nvme0n1

# Exit chroot
exit

# Unmount everything
sudo umount -R /mnt

# Reboot
sudo reboot
```

---

## Snapshot Management

### Creating Manual Snapshots

**Before risky operations:**
```bash
# Create snapshot with description
sudo snapper -c root create -d "Before installing experimental software"

# Create snapshot before editing critical config
sudo snapper -c root create -d "Before modifying /etc/fstab"

# Create snapshot before system upgrade
sudo snapper -c root create -d "Before Fedora 44 upgrade"
```

### Listing Snapshots
```bash
# List all snapshots
sudo snapper list

# List with more details
sudo snapper list --all-configs

# List snapshots for specific config
sudo snapper -c root list
```

### Comparing Snapshots
```bash
# Compare two snapshots (shows changed files)
sudo snapper status 5..8

# See detailed diff of specific file
sudo snapper diff 5..8 /etc/ssh/sshd_config

# Compare snapshot to current system
sudo snapper status 5..0
```

### Deleting Snapshots
```bash
# Delete specific snapshot
sudo snapper delete 7

# Delete range of snapshots
sudo snapper delete 5-10

# Delete all snapshots except timeline and current
sudo snapper delete --sync $(snapper list | grep 'number' | awk '{print $1}')
```

**Warning:** Don't delete pre/post snapshot pairs - they're linked!

### Mounting Snapshots Read-Only
```bash
# Create mount point
sudo mkdir -p /mnt/snapshot

# Mount snapshot #5
sudo mount -o subvol=.snapshots/5/snapshot /dev/mapper/luks_root /mnt/snapshot

# Browse files
ls /mnt/snapshot/

# Copy files out
sudo cp /mnt/snapshot/home/$USER/important_file.txt ~/

# Unmount when done
sudo umount /mnt/snapshot
```

---

## Troubleshooting

### Problem: "No snapshots available in GRUB"

**Diagnosis:**
```bash
# Check if snapshots exist
sudo snapper list

# Check grub-btrfsd service
sudo systemctl status grub-btrfsd
sudo journalctl -u grub-btrfsd -n 50

# Check GRUB config
grep -i snapshot /boot/grub2/grub.cfg
```

**Solution:**
```bash
# Restart grub-btrfsd
sudo systemctl restart grub-btrfsd

# Manually regenerate GRUB
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Check if snapshots now appear
grep -i snapshot /boot/grub2/grub.cfg
```

---

### Problem: "Snapshot rollback failed"

**Error:** `Failed to create subvolume`

**Diagnosis:**
```bash
# Check disk space
df -h /

# Check Btrfs filesystem
sudo btrfs filesystem df /
sudo btrfs filesystem show /
```

**Solution:**
```bash
# Free up space by deleting old snapshots
sudo snapper list
sudo snapper delete 5-10

# Run Btrfs balance if needed
sudo btrfs balance start -dusage=50 /

# Try rollback again
sudo snapper rollback
```

---

### Problem: "Cannot mount snapshot - device busy"

**Diagnosis:**
```bash
# Check what's using the mount point
lsof | grep /mnt/snapshot
fuser -m /mnt/snapshot
```

**Solution:**
```bash
# Force unmount
sudo umount -l /mnt/snapshot

# Or kill processes using it
sudo fuser -km /mnt/snapshot
sudo umount /mnt/snapshot
```

---

### Problem: "Rolled back but system still broken"

**Possible causes:**
- `/home` subvolume not rolled back (keeps user configs)
- Boot partition not restored
- Wrong snapshot selected

**Solution:**

1. **Check if home needs rollback too:**
```bash
   # If you have separate home snapshots
   sudo snapper -c home list
   sudo snapper -c home rollback
```

2. **Boot to older snapshot via GRUB:**
   - Maybe the snapshot you chose is still broken
   - Try an even older one

3. **Check boot partition:**
```bash
   # Reinstall kernel
   sudo dnf reinstall kernel
   
   # Regenerate initramfs
   sudo dracut --force
   
   # Update GRUB
   sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

---

### Problem: "Snapshot exists but files are missing"

**Reason:** Snapshots only capture the root subvolume, not separate subvolumes like `/home`

**Solution:**

If you need to recover files from `/home`:

1. **Check if home has snapshots:**
```bash
   sudo snapper -c home list 2>/dev/null
```

2. **If no home snapshots exist:**
   - Files in `/home` are NOT included in root snapshots
   - Need to rely on backups (Timeshift RSYNC, external backups, etc.)

3. **Future prevention:**
```bash
   # Create snapshot config for home
   sudo snapper -c home create-config /home
   
   # Enable timeline snapshots for home
   sudo systemctl enable --now snapper-timeline.timer
```

---

### Problem: "Out of space after rollback"

**Reason:** Old snapshots taking up space

**Solution:**
```bash
# Check disk usage
sudo btrfs filesystem df /
df -h /

# Delete old snapshots
sudo snapper list
sudo snapper delete 1-20

# Run cleanup
sudo snapper cleanup number

# Check space again
sudo btrfs filesystem df /
```

---

## Prevention Tips

### 1. Create Snapshots Before Risky Changes
```bash
# Always snapshot before:
sudo snapper -c root create -d "Before major system change"

# Examples:
# - Installing new kernel
# - Upgrading Fedora version
# - Installing proprietary drivers
# - Modifying /etc/fstab
# - Testing experimental software
```

### 2. Verify GRUB Snapshots Work
```bash
# After initial setup, test the GRUB menu
sudo reboot

# Make sure you can see and boot snapshots
# Practice recovery while system is working
```

### 3. Monitor Snapshot Disk Usage
```bash
# Check weekly
sudo snapper list
sudo btrfs filesystem df /

# Delete old snapshots if needed
sudo snapper cleanup number
```

### 4. Keep External Backups

**Snapshots are NOT backups!**

- Snapshots protect against software issues
- They DON'T protect against hardware failure
- Keep important data backed up externally:
  - External HDD/SSD
  - Cloud storage (rclone, Nextcloud, etc.)
  - Network backup (rsync to NAS)

### 5. Document Your System

Keep notes on:
- When you installed what
- Configuration changes made
- Known-good snapshot numbers
- Recovery procedures that worked

---

## Advanced Recovery Scenarios

### Recovering Specific Packages
```bash
# Find which snapshot has the package version you need
sudo snapper list

# Mount snapshot
sudo mount -o subvol=.snapshots/5/snapshot /dev/mapper/luks_root /mnt

# Check package database
sudo chroot /mnt
rpm -qa | grep package-name
exit

# Extract RPM from snapshot
sudo cp /mnt/var/cache/dnf/.../package.rpm ~/

# Install on current system
sudo dnf install ~/package.rpm

# Unmount
sudo umount /mnt
```

### Recovering from Filesystem Corruption

**If Btrfs detects errors:**
```bash
# Boot from Live USB

# Unlock LUKS
sudo cryptsetup open /dev/nvme0n1p2 luks_root

# Check filesystem
sudo btrfs check /dev/mapper/luks_root

# If errors found, try repair (DANGEROUS - backup first!)
sudo btrfs check --repair /dev/mapper/luks_root

# If repair works, boot normally
sudo reboot

# If repair fails, restore from snapshot using Live USB method above
```

### Dual-Boot Recovery

**If you have multiple Fedora installations:**
```bash
# From Live USB, identify installations
sudo mount /dev/mapper/luks_root /mnt
ls /mnt/
# Might see: root, root_fedora43, home, .snapshots

# Mount the correct root
sudo umount /mnt
sudo mount -o subvol=root_fedora43 /dev/mapper/luks_root /mnt

# List its snapshots
ls /mnt/.snapshots/

# Restore as usual
sudo btrfs subvolume snapshot /mnt/.snapshots/3/snapshot /mnt/root_fedora43.new
sudo btrfs subvolume delete /mnt/root_fedora43
sudo mv /mnt/root_fedora43.new /mnt/root_fedora43
```

---

## Quick Reference Commands
```bash
# SNAPSHOT OPERATIONS
sudo snapper list                                    # List all snapshots
sudo snapper create -d "description"                 # Create snapshot
sudo snapper delete 5                                # Delete snapshot #5
sudo snapper rollback                                # Rollback to last snapshot
sudo snapper rollback 7                              # Rollback to snapshot #7
sudo snapper status 5..8                             # Compare snapshots
sudo snapper diff 5..8 /etc/fstab                    # Diff specific file

# MOUNT OPERATIONS
sudo mount -o subvol=.snapshots/5/snapshot /dev/mapper/luks_root /mnt
sudo mount -o subvol=root /dev/mapper/luks_root /mnt
sudo umount /mnt

# BTRFS OPERATIONS
sudo btrfs subvolume list /mnt                       # List subvolumes
sudo btrfs subvolume snapshot /source /dest          # Create subvolume snapshot
sudo btrfs subvolume delete /mnt/root.broken         # Delete subvolume
sudo btrfs filesystem df /                           # Check space usage

# GRUB OPERATIONS
sudo grub2-mkconfig -o /boot/grub2/grub.cfg         # Regenerate GRUB
sudo systemctl restart grub-btrfsd                   # Restart GRUB daemon
grep -i snapshot /boot/grub2/grub.cfg               # Check if snapshots in GRUB

# LUKS OPERATIONS
sudo cryptsetup open /dev/nvme0n1p2 luks_root       # Unlock encrypted partition
sudo cryptsetup close luks_root                      # Lock encrypted partition
```

---

## Emergency Contact Info

If you're completely stuck:

1. **Fedora Forums:** https://discussion.fedoraproject.org/
2. **Fedora Reddit:** r/Fedora
3. **Snapper Documentation:** http://snapper.io/documentation.html
4. **Btrfs Wiki:** https://btrfs.wiki.kernel.org/

**Before asking for help, gather:**
- Output of `sudo snapper list`
- Output of `sudo btrfs subvolume list /`
- Your `/etc/fstab` contents
- GRUB configuration excerpt
- Exact error messages

---

**Remember:** Snapshots are powerful recovery tools, but they're not a substitute for proper backups. Always maintain external backups of critical data!

**Last Updated:** February 2026  
**For Use With:** Fedora setup script with Snapper + grub-btrfs integration
