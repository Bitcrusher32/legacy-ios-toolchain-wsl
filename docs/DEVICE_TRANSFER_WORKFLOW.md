# Device Transfer Workflow

This project currently uses a split host/device workflow.

WSL remains the build environment.

Windows PowerShell + PuTTY tooling is the known-good transfer/control bridge.

PuTTY is the known-good interactive root shell on the iPhone.

## Current known-good chain

    WSL build output
    -> /mnt/c/iPhone4sPush/
    -> Windows PowerShell pscp.exe
    -> iPhone /var/root/
    -> PuTTY root shell
    -> dpkg install/remove/checks

## Why not WSL SSH/SCP?

WSL SSH/SCP was unreliable against the iPhone on the Windows Mobile Hotspot subnet.

PuTTY from Windows worked reliably.

Until WSL routing/NAT behavior is debugged separately, use Windows-side PuTTY tools for device transfer/control.

## Known iPhone IP during V1.24/V1.25 tests

    <IPHONE_IP>

Do not hardcode this permanently. Confirm the current iPhone IP before each session.

## Build package in WSL

Example for NoOpTweak:

    cd ~/legacy-ios-toolchain-wsl/examples/noop-tweak
    PATH="$THEOS/toolchain/linux/iphone/bin:$PATH" make clean
    PATH="$THEOS/toolchain/linux/iphone/bin:$PATH" make package messages=yes

Copy to Windows bridge folder:

    mkdir -p /mnt/c/iPhone4sPush
    cp packages/com.bitcrusher32.nooptweak_0.0.1-1+debug_iphoneos-arm.deb /mnt/c/iPhone4sPush/

## Transfer from Windows PowerShell

Run from Windows PowerShell, not WSL and not the iPhone shell:

    pscp.exe C:\iPhone4sPush\com.bitcrusher32.nooptweak_0.0.1-1+debug_iphoneos-arm.deb root@<IPHONE_IP>:/var/root/

If PuTTY is not in PATH:

    & "C:\Program Files\PuTTY\pscp.exe" C:\iPhone4sPush\com.bitcrusher32.nooptweak_0.0.1-1+debug_iphoneos-arm.deb root@<IPHONE_IP>:/var/root/

## Control from PuTTY

Use PuTTY to open an interactive root shell:

    root@<IPHONE_IP>

Then run dpkg commands on-device.

## Common mistakes to avoid

- Do not run `plink.exe` or `pscp.exe` inside the iPhone shell.
- Do not use placeholder IPs like `<IPHONE_IP>` literally.
- Do not assume WSL SSH/SCP works just because PuTTY works.
- Do not install packages before inspecting them on the host.
- Do not leave test packages installed unless deliberately proceeding to a runtime test.

## Hotspot note

If the iPhone shows a `169.254.x.x` address, DHCP failed. Stop package testing and fix the Windows hotspot/SharedAccess state first.

A normal Windows hotspot IP should look like:

    <IPHONE_IP>
