#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=1091
. /usr/share/makepkg/util.sh
colorize

msg "Building rootfs..."
mkdir -p ./rootfs
sudo pacstrap \
    -C /usr/share/devtools/pacman-extra-riscv64.conf \
    -M \
    ./rootfs \
    base

msg "Clean up pacman package cache..."
yes y | sudo pacman \
    --sysroot ./rootfs \
    --sync --clean --clean

msg "Set root password (Default: archriscv)..."
usermod --root ./rootfs --password archriscv root

msg "Compressing rootfs..."
sudo bsdtar --create --zstd --verbose --xattrs --acls -f "archriscv-$(date --rfc-3339=date).tar.zst" -C rootfs/ .
