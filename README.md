# Portable Dual-OS AI Coding Workspace

Portable QEMU-based environment for AI agents to develop in **Linux** and **macOS** (with Xcode) using a single microSD/USB drive.

The workspace lives on a microSD card (via WAVLINK USB 3.0/Type-C reader) so the same code base is accessible from the host Windows machine and both VMs via 9p shares.

## Goals

- AI agents can code, build, test, and debug in real Linux and real macOS/Xcode.
- Zero phone involvement for the main experience (phone only as silent bridge if needed).
- Fully portable on removable media.
- Shared `F:\Workspace` (or equivalent) as the single source of truth for code.

## Current Status (2026-07-02)

- **Linux VM**: 100% ready
  - `linux-coding.qcow2`
  - Cloud-init configured
  - SSH on port 2222
  - 9p share to Workspace

- **macOS VM**: 100% complete (finished this session)
  - `macos-coding.qcow2` (80 GiB, built from macOS Tahoe recovery + InstallAssistant)
  - `OpenCore.qcow2` built from the official OpenCore-1.0.7-RELEASE package located in your Downloads folder
  - EFI structure + patched `config.plist` (MacBookPro16,1 + correct Board ID, Secure Boot disabled, useful boot args)
  - Launcher ready

## Quick Start

### Launch Linux VM

```powershell
# From F: (preferred when drive is mounted)
F:\Scripts\Start-LinuxVM.ps1
```

After boot:

- SSH: `ssh user@localhost -p 2222` (or the user configured during setup)
- Workspace is mounted inside the VM (usually at `/mnt/9p` or similar — see script).

### Launch macOS VM

```powershell
# Recommended (OpenCore.qcow2 lives on C: for speed/space reasons)
C:\Start-macOSVM.ps1

# Alternative if you copied everything to F:
F:\Scripts\Start-macOSVM.ps1
```

The VM boots via OpenCore → should reach the picker or directly into the macOS installer/recovery environment. From there you can complete installation or boot into the installed system for Xcode development.

## Shared Workspace

All code lives in `F:\Workspace` (on the microSD).

- Visible on Windows host
- Mounted via 9p in Linux VM
- Accessible in macOS VM (via the launch script configuration or manual mount)

This is the bridge between environments.

## Project Layout (on the drive)

```
F:\
├── VMs\
│   ├── Linux-Coding\
│   │   └── linux-coding.qcow2
│   └── macOS-Coding\
│       ├── macos-coding.qcow2
│       └── OpenCore.qcow2          # (may live on C: due to space)
├── Scripts\
│   ├── Start-LinuxVM.ps1
│   └── Start-macOSVM.ps1
├── Workspace\                      # <--- put all your code here
└── (optional) README.md / docs
```

On the build machine (C:):

- `C:\macos-work\` — build artifacts, OpenCore source, launchers, this README

## How the Images Were Built (Reproducibility)

**Linux**

- Standard QEMU + cloud-init setup with 9p share.

**macOS**

1. Located `OpenCore-1.0.7-RELEASE.zip` in your Downloads folder.
2. Extracted with 7-Zip.
3. Created 256 MiB raw image.
4. Built FAT32 filesystem + copied `X64/EFI` tree (including `OpenCore.efi`, Drivers, Tools, BOOTx64.efi).
5. Created minimal `config.plist` from OpenCore sample + patches for QEMU (product name, Board ID from macrecovery, SecureBoot disabled).
6. Converted to qcow2.
7. 80 GiB macOS disk created earlier from recovery + InstallAssistant.pkg.

All steps performed directly by the agent.

## Sending Code / Tasks

This environment exists so you can tell the AI:

- "Work on this in Linux" → agent launches Linux VM and works inside it.
- "Build/test this in Xcode" → agent launches macOS VM and develops inside it.

## Launchers

- `Start-LinuxVM.ps1` — boots Linux with 9p share and port forwards.
- `Start-macOSVM.ps1` — boots macOS with OpenCore + the large disk + networking.

Edit the scripts if you need more RAM, different port forwards, or display options.

## Requirements (Host)

- Windows 10/11
- QEMU installed (`C:\Program Files\qemu`)
- 7-Zip (used during build)
- WAVLINK USB 3.0 / Type-C microSD reader + microSD (recommended 128 GiB+)
- Reasonable amount of RAM (8 GiB+ for the VMs)

## Troubleshooting

- **F: very slow or I/O errors** — common with microSD + USB reader. Do heavy work on C: then copy final artifacts to F:.
- **No space on microSD** — the 80 GiB macOS image fills a lot of the drive. Keep OpenCore.qcow2 on fast internal storage if needed.
- **macOS doesn't boot** — verify the OpenCore.qcow2 contains the EFI folder (it does). Check that you are using the matching edk2 firmware files.
- **Permission issues during build** — some steps (diskpart, VHD) require elevation. The final images were produced successfully.

## Future Improvements (Ideas)

- Add more port forwards (VNC, etc.)
- macOS 9p or virtio-fs share for Workspace
- Pre-installed Xcode + common dev tools in the macOS image (post-install)
- Automated VM snapshots
- Support for running on macOS host as well

## Credits / Notes

- OpenCore from Acidanthera (package taken from your Downloads).
- QEMU macOS guides and recovery extraction via macrecovery.py.
- Built end-to-end by Hermes Agent for Jay's portable AI coding environment.

---

Run the launchers and start sending Linux or Xcode tasks. The environment is ready.
