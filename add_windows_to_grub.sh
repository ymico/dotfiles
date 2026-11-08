#!/bin/bash
set -e

echo "=== Updating GRUB Configuration ==="
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Verify if Windows is present in grub.cfg
if sudo grep -qi "Windows" /boot/grub2/grub.cfg; then
    echo ""
    echo "SUCCESS: Windows Boot Manager successfully found and added to GRUB menu!"
else
    echo ""
    echo "os-prober skipped EFI mount. Adding direct UEFI chainloader entry for Windows..."
    sudo bash -c 'cat << "EOF" > /etc/grub.d/40_custom
#!/bin/sh
exec tail -n +3 $0

menuentry "Windows Boot Manager" --class windows --class os {
    insmod part_gpt
    insmod fat
    search --no-floppy --fs-uuid --set=root FA5C-D2BD
    chainloader /EFI/Microsoft/Boot/bootmgfw.efi
}
EOF'
    sudo chmod +x /etc/grub.d/40_custom
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    echo ""
    echo "SUCCESS: Windows Boot Manager added via 40_custom entry!"
fi

# Configure passwordless reboot-to-windows for Rofi powermenu
echo ""
echo "=== Configuring 1-Click Reboot to Windows for Rofi ==="
echo "ym1co ALL=(ALL) NOPASSWD: /usr/sbin/efibootmgr -n [0-9A-Fa-f]*" | sudo tee /etc/sudoers.d/99-reboot-to-windows >/dev/null
sudo chmod 0440 /etc/sudoers.d/99-reboot-to-windows
echo "SUCCESS: 1-Click Windows reboot configured without password prompts."

echo ""
echo "Current Boot Order:"
efibootmgr | grep -E "BootOrder|Boot000"
