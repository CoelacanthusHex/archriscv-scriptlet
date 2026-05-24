# Arch RISC-V Scriptlet

Useful scripts for building and running Arch RISC-V Qcow image.

## Prerequisite

* arch-install-scripts
* parted
* git
* qemu-img
* qemu-system-riscv
* edk2-riscv64
* dosfstools
* riscv64-linux-gnu-gcc
* devtools-riscv64 ([AUR](https://aur.archlinux.org/packages/devtools-riscv64))

## Build Step

```bash
./mkrootfs
./mkimg
```

## Start QEMU

```bash
./startqemu.sh [qcow image file]
```

Set `FIRMWARE=uboot` to boot the same image through OpenSBI/U-Boot with `-bios` instead.
