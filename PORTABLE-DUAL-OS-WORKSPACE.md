# Portable Dual-OS Workspace - Quick Reference

**Location in openclaw workspace:** `.openclaw/workspace/portable-dual-os-workspace/`

This environment lets AI agents code natively in both Linux and macOS/Xcode on the same portable microSD drive.

See:

- `README.md` (overview + status)
- `HOWTO.md` (detailed usage, troubleshooting, rebuild steps)

## Current State

- Linux: Fully operational
- macOS: Completed July 2026 (OpenCore 1.0.7 from your Downloads + 80G disk)

## Launchers

- Linux: `F:\Scripts\Start-LinuxVM.ps1`
- macOS: `C:\Start-macOSVM.ps1` (copy also in Scripts folder)

All development work should target `F:\Workspace`.

For full details open the README and HOWTO in this folder or in `/c/macos-work/`.
