# HOWTO - Portable Dual-OS AI Coding Workspace

This document gives step-by-step instructions for using and maintaining the Linux + macOS QEMU environment on removable media.

## 1. First Time Setup (Host)

1. Insert the microSD (via WAVLINK reader).
2. Ensure `F:\VMs\` and `F:\Scripts\` exist with the images and launchers.
3. (Recommended) Copy `OpenCore.qcow2` and `C:\Start-macOSVM.ps1` to a fast internal drive if F: space or speed is an issue.
4. Install QEMU if not already present.

## 2. Launching the VMs

### Linux VM
```powershell
F:\Scripts\Start-LinuxVM.ps1
```

- Wait for boot (cloud-init may take a minute on first run).
- SSH in: `ssh <user>@localhost -p 2222`
- Workspace should be available (check mount points with `mount | grep 9p`).

Common tasks inside Linux:
- `cd /path/to/workspace`
- Edit, build, test as normal.

### macOS VM
```powershell
C:\Start-macOSVM.ps1     # or the copy on F:
```

- Boots via OpenCore.
- You will usually see the OpenCore picker or go straight into the macOS environment.
- From there you can finish any remaining installer steps or boot the installed system.
- Use the shared Workspace folder for all source code.

Inside macOS you have full Xcode, Swift, etc.

## 3. Workflow for Sending Tasks

Tell the agent something like:

- "Work on feature X in the Linux VM. Code lives in F:\Workspace\myproject"
- "Debug and build this Swift package in the macOS VM using Xcode"
- "Test the Linux build and the macOS build, keep everything in the shared Workspace"

The agent will:
- Launch the appropriate VM
- Work inside it (using the terminal/filesystem of that VM)
- Leave results in the shared folder

## 4. Maintaining the Images

### Updating OpenCore
1. Download new OpenCore release.
2. Extract to a temp folder.
3. Mount or rebuild `OpenCore.qcow2` (use the Python FAT32 builder or mount the image on host).
4. Copy new EFI tree in.
5. Replace the file used by the launcher.

### Resizing the macOS Disk
Use `qemu-img resize` on the host (careful — only enlarge, then use disk utility inside macOS to grow the partition).

Example:
```bash
qemu-img resize macos-coding.qcow2 +20G
```

### Backing Up
Simply copy the `.qcow2` files from the drive. They are portable.

## 5. Common QEMU Flags (for reference)

The launch scripts contain the working set. Key ones:
- `-m 8192` (or more)
- `-cpu Penryn,...` (required for macOS)
- pflash drives for firmware + OpenCore.qcow2 as boot drive
- `-netdev user,...hostfwd=...` for SSH / VNC / other services

## 6. When Things Go Wrong

- **VM won't start** — check paths in the .ps1 script and that QEMU is in PATH or use full path.
- **macOS kernel panic / no boot** — wrong OpenCore config or missing drivers. Rebuild `OpenCore.qcow2` from the EFI tree.
- **No shared folder** — check 9p configuration in the Linux launcher and mounts inside the guest.
- **Slow performance** — microSD is the bottleneck. Consider keeping the VMs on internal SSD and only sync the Workspace folder.
- **"No space left"** — the 80G macOS image is large. Delete old snapshots or move OpenCore.qcow2 off the card.

## 7. Rebuilding from Scratch (Advanced)

See the build scripts that were used:
- `build_fat32.py` (in C:\macos-work) — creates the FAT32 OpenCore image
- macrecovery.py + 7z + qemu-img for the macOS disk
- PowerShell / bash one-liners for launchers

All steps were executed directly in this session.

## 8. Sending Code Between Environments

Best practice:
- Keep all source in `F:\Workspace\`
- Use git inside the VMs (or on host)
- The agent can switch VMs as needed for the task

## Tips for Best Experience

- Run the agent with low mid-task chatter (as you prefer).
- For long builds, use `tmux` or `screen` inside the VMs.
- Snapshot the qcow2 files before risky changes.
- Keep a "clean" copy of the images as templates.

---

This environment lets the AI do real development in both operating systems without you having to manage the VMs yourself. Just point it at a task and the correct environment.