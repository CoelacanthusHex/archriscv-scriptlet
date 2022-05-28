#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=1091
. /usr/share/makepkg/util.sh
colorize

msg "Starting qemu"
qemu-system-riscv64 \
    -nographic \
    -machine virt \
    -smp 8 \
    -m 4G \
    -bios ./opensbi/build/platform/generic/firmware/fw_payload.bin \
    -device virtio-blk-device,drive=hd0 \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-device,rng=rng0 \
    -drive file=archriscv-$(date --rfc-3339=date).qcow2,format=qcow2,id=hd0 \
    -monitor unix:/tmp/qemu-monitor,server,nowait
