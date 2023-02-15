# Arch RISC-V Scriptlet

Useful scripts for building and running Arch RISC-V Qcow image.

## Prerequisite

* arch-install-scripts
* git
* qemu-img
* qemu-system-riscv
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

