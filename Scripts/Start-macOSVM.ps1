# Start-macOSVM.ps1
# Launch macOS Tahoe coding VM with OpenCore
# Run from PowerShell as Administrator if possible

$QEMU = "C:\Program Files\qemu\qemu-system-x86_64.exe"
$OC_IMAGE = "C:\macos-work\OpenCore.qcow2"
$MACOS_DISK = "F:\VMs\macOS-Coding\macos-coding.qcow2"

if (-not (Test-Path $QEMU)) {
    Write-Error "QEMU not found at $QEMU"
    exit 1
}
if (-not (Test-Path $OC_IMAGE)) {
    Write-Error "OpenCore image not found at $OC_IMAGE"
    exit 1
}
if (-not (Test-Path $MACOS_DISK)) {
    Write-Error "macOS disk not found at $MACOS_DISK"
    exit 1
}

$QemuArgs = @(
    "-m", "8192",
    "-cpu", "Penryn,vendor=GenuineIntel,+sse3,+sse4.2,+aes,+avx,+avx2,+xsave,+xsaveopt",
    "-machine", "q35",
    "-usb",
    "-device", "usb-tablet",
    "-global", "ICH9-LPC.disable_s3=1",
    "-drive", "if=pflash,format=raw,readonly=on,file=C:\Program Files\qemu\share\edk2-x86_64-code.fd",
    "-drive", "if=pflash,format=raw,file=C:\Program Files\qemu\share\edk2-x86_64-vars.fd",
    "-drive", "id=OpenCore,if=none,format=qcow2,file=$OC_IMAGE",
    "-device", "ide-hd,drive=OpenCore,unit=0",
    "-drive", "id=MacHDD,if=none,format=qcow2,file=$MACOS_DISK",
    "-device", "ide-hd,drive=MacHDD,unit=1",
    "-netdev", "user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::5900-:5900",
    "-device", "e1000,netdev=net0",
    "-vga", "std"
)

Write-Output "Starting macOS VM..."
& $QEMU @QemuArgs

Write-Output "VM exited."