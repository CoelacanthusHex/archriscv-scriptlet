# Arch RISC-V Scriptlet

Useful scripts for building and running Arch RISC-V Qcow image.

## Prerequisite

* git
* qemu-system-riscv
* qemu-img
* riscv64-linux-gnu-gcc

## Build Step

```bash
./mkrootfs
./mkimg
```

## Start QEMU

```bash
./startqemu.sh [qcow image file]
```

