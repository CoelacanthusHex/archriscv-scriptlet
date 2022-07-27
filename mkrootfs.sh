#!/usr/bin/bash
#
# SPDX-FileCopyrightText: 2022 Celeste Liu <coelacanthus@outlook.com>
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=1091
. /usr/share/makepkg/util.sh
colorize

msg "Building rootfs..."
mkdir -p ./rootfs
sudo chown root:root ./rootfs
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
sudo usermod --root (realpath ./rootfs) --password $(perl -e "print crypt('archriscv','yescrypt')") root

msg "Compressing rootfs..."
sudo bsdtar --create --zstd --verbose --xattrs --acls -f "archriscv-$(date --rfc-3339=date).tar.zst" -C rootfs/ .

msg "Clean up rootfs directory..."
sudo rm -rf ./rootfs
