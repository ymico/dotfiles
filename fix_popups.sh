#!/bin/bash
set -e

echo "=== 1. Отключение запроса пароля при переключении в Windows из Rofi ==="
echo "ym1co ALL=(ALL) NOPASSWD: /usr/sbin/efibootmgr -n [0-9A-Fa-f]*, /usr/bin/efibootmgr -n [0-9A-Fa-f]*" | sudo tee /etc/sudoers.d/99-reboot-to-windows >/dev/null
sudo chmod 0440 /etc/sudoers.d/99-reboot-to-windows
echo "ГОТОВО: Перезагрузка в Windows из Rofi теперь работает в 1 клик БЕЗ пароля."

echo ""
echo "=== 2. Добавление Windows в меню GRUB ==="
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
if ! sudo grep -qi "Windows" /boot/grub2/grub.cfg; then
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
fi
echo "ГОТОВО: Windows добавлена в меню GRUB."

echo ""
echo "=== 3. Установка Seahorse для отключения пароля связки ключей ==="
sudo dnf install -y seahorse
echo "ГОТОВО: Seahorse установлен."
