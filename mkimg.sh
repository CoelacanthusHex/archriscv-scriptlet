#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=1091
. /usr/share/makepkg/util.sh
colorize

toggle-systemd-firstboot() {
    msg2 "Toggle systemd-firstboot..."
    sudo rm ./qcow2/etc/{machine-id,localtime,hostname,shadow,locale.conf}
    sudo arch-chroot qcow2 mkdir -p /etc/systemd/system/systemd-firstboot.service.d
    sudo arch-chroot qcow2 cat << EOF | tee /etc/systemd/system/systemd-firstboot.service.d/install.conf
[Service]
ExecStart=
ExecStart=/usr/bin/systemd-firstboot --prompt --force

[Install]
WantedBy=sysinit.target
EOF
    sudo arch-chroot qcow2 systemctl enable systemd-firstboot.service
}

use-fixed-password() {
    msg2 "Using fixed password..."
    : # set in rootfs
}

msg "Building u-boot..."

git clone https://github.com/u-boot/u-boot.git
pushd u-boot
git checkout v2022.04
msg2 "Apply binutils 2.38 compitible patch"
git apply ../0001-riscv-fix-compitible-with-binutils-2.38.patch
msg2 "Apply compressed kernel patch"
git apply ../0002-riscv-fix-compressed-kernel-boot.patch
make \
    CROSS_COMPILE=riscv64-linux-gnu- \
    qemu-riscv64_smode_defconfig
make CROSS_COMPILE=riscv64-linux-gnu-
popd

msg "Building OpenSBI..."

git clone https://github.com/riscv-software-src/opensbi
pushd opensbi
git checkout v1.0
msg2 "Apply binutils 2.38 compitible patch"
git cherry-pick -n 5d53b55aa77ffeefd4012445dfa6ad3535e1ff2c

make \
    CROSS_COMPILE=riscv64-linux-gnu- \
    PLATFORM=generic \
    FW_PAYLOAD_PATH=../u-boot/u-boot.bin
popd

msg "Create image file..."
qemu-img create -f qcow2 "archriscv-$(date --rfc-3339=date).qcow2" 10G
sudo modprobe nbd max_part=16
sudo qemu-nbd -c /dev/nbd0 "archriscv-$(date --rfc-3339=date).qcow2"

sudo sfdisk /dev/nbd0 <<EOF
label: dos
label-id: 0x17527589
device: /dev/nbd0
unit: sectors

/dev/nbd0p1 : start=        2048, type=83, bootable
EOF

sudo mkfs.ext4 /dev/nbd0p1
sudo e2label /dev/nbd0p1 rootfs

mkdir -p qcow2
sudo mount /dev/nbd0p1 qcow2

msg "Install kernel package..."

sudo pacman \
    --root ./qcow2 \
    --config /usr/share/devtools/pacman-extra-riscv64.conf \
    --noconfirm \
    -S linux linux-firmware dracut dracut-hook

sudo arch-chroot qcow2 dracut --force --add "qemu qemu-net" --regenerate-all
sudo arch-chroot qcow2 mkdir -p boot/extlinux
sudo arch-chroot qcow2 cat << EOF | tee boot/extlinux/extlinux.conf
menu title Arch RISC-V QEMU Boot
timeout 100
default linux

label linux
    menu label Linux linux
    kernel /boot/vmlinuz-linux
    initrd /boot/initramfs-linux.img
    append earlyprintk rw root=/dev/vda1 rootwait rootfstype=ext4 LANG=en_US.UTF-8 console=ttyS0
EOF

msg "Clean up..."
msg2 "Clean up pacman package cache..."
yes y | sudo pacman \
    --sysroot ./rootfs \
    --sync --clean --clean

# https://github.com/CoelacanthusHex/archriscv-scriptlet/issues/1
toggle-systemd-firstboot
#use-fixed-password

msg2 "Unmount..."
sudo umount qcow2
sudo qemu-nbd -d /dev/nbd0
