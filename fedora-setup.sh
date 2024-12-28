#!/usr/bin/env bash
set -euo pipefail

if [[ $(id -u) != "0" ]]; then
    echo 'Script must be run as root or with sudo!'
    exit 1
fi

# make sure radv_debug option is set in environment
echo -n "Setting RADV_DEBUG option... "
echo 'RADV_DEBUG=nocompute' > /etc/environment

# make sure amdgpu option is in modprobe file and update initrd
echo -n "Setting amdgpu module option... "
echo 'options amdgpu sg_display=0' > /etc/modprobe.d/options-amdgpu.conf
echo "OK, regenerating initrd (this may take a while)"
dracut --stdlog=4 --regenerate-all --force

# clear nomodeset from /etc/default/grub and update config
echo "Fixing up GRUB config..."
sed -i 's/nomodeset//g' /etc/default/grub
sed -i 's/amdgpu\.sg_display=0//g' /etc/default/grub
grub2-mkconfig -o /etc/grub2.cfg

# install segfaults governor
echo "Installing GPU governor... "
dnf install libdrm-devel cmake make g++ git
git clone https://gitlab.com/TuxThePenguin0/oberon-governor.git && cd oberon-governor
cmake . && make && make install
systemctl enable --now oberon-govenor.service

# that should do it
echo "Done! Rebooting system in 15 seconds, ctrl-C now to cancel..."
sleep 15 && systemctl reboot
