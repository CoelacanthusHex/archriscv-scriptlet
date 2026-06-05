#!/usr/bin/bash
#
# SPDX-FileCopyrightText: 2022 Celeste Liu <coelacanthus@outlook.com>
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=1091
. /usr/share/makepkg/util.sh
colorize

parse-args() {
    local OPTIND=1
    shift "$(( OPTIND-1 ))"
    file=${1:-archriscv-$(date --rfc-3339=date).qcow2}
}

parse-args "$@"

msg "Starting qemu"
if [[ $FIRMWARE == uboot ]]; then
    firmware_args=(-bios ./opensbi_fw_payload.bin)
else
    firmware_args=(
        -drive if=pflash,format=raw,unit=0,readonly=on,file=/usr/share/edk2/riscv64/RISCV_VIRT_CODE.fd
    )
fi
qemu-system-riscv64 \
    -nographic \
    -machine virt \
    -smp 8 \
    -m 4G \
    -netdev user,id=n0 -device virtio-net,netdev=n0 \
    "${firmware_args[@]}" \
    -device virtio-blk-device,drive=hd0 \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-device,rng=rng0 \
    -drive file="$file",format=qcow2,id=hd0,if=none \
    -monitor unix:/tmp/qemu-monitor,server,nowait
