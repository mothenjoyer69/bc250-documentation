#!/usr/bin/env bash
set -euo pipefail

if [[ $(id -u) != "0" ]]; then
    echo 'Script must be run as root or with sudo!'
    exit 1
fi

# install patched mesa + block any updates from main repos
echo -n "Adding mesa copr... "
dnf copr enable danayer/mesa-git -y
dnf copr enable danayer/libdrm-git -y
dnf copr enable danayer/linux-firmware-git -y
dnf copr enable danayer/Vulkan-Git -y
dnf copr enable danayer/virglrenderer-git -y
# dnf copr enable @exotic-soc/bc250-mesa -y
dnf update --refresh   -y
dnf upgrade -y 

# make sure radv_debug option is set in environment
echo -n "Setting RADV_DEBUG option... "
echo 'RADV_DEBUG=nocompute' > /etc/environment

# install segfaults governor
echo "Installing GPU governor... "
dnf install libdrm-devel cmake make g++ git -y
git clone https://gitlab.com/mothenjoyer69/oberon-governor.git && cd oberon-governor
cmake . && make && make install
systemctl enable oberon-governor.service

# make sure amdgpu and nct6683 options are in the modprobe files and update initrd
echo -n "Setting amdgpu module option... "
echo 'options amdgpu sg_display=0' > /etc/modprobe.d/options-amdgpu.conf
echo -n "Setting nct6683 module option... "
echo 'nct6683' > /etc/modules-load.d/99-sensors.conf
echo 'options nct6683 force=true' > /etc/modprobe.d/options-sensors.conf
echo "OK, regenerating initrd (this may take a while)"
dracut --stdlog=4 --regenerate-all --force

# clear nomodeset from /etc/default/grub and update config
echo "Fixing up GRUB config..."
sed -i 's/nomodeset//g' /etc/default/grub
sed -i 's/amdgpu\.sg_display=0//g' /etc/default/grub
grub2-mkconfig -o /etc/grub2.cfg

# that should do it
echo "Done! Rebooting system in 15 seconds, ctrl-C now to cancel..."
sleep 15 && systemctl reboot

