# Hypervisor-Extended Keystone TEE

## Clone this repo with submodules

```
git clone --recursive https://github.com/XinlaiWan/hypervisor-extended-keystone.git
```
or
```
git submodule update --init --recursive
```
after cloning it.

## Building Keystone components

- Apply the patch on Xvisor

```
> cd keystone
> git apply ../patches/keystone.patch
```

- Follow 1.2.1.2. Start Without Docker in [this section](http://docs.keystone-enclave.org/en/v0.4/Getting-Started/Running-Keystone-with-QEMU.html) of the Keystone documentation.
  - Note: make sure to use the v0.4 documentation.

## Building Xvisor

- Apply the patch on Xvisor

```
> cd xvisor
> git apply ../patches/xvisor.patch
```

- Follow `xvisor/docs/riscv/riscv64-qemu.txt` to build Xvisor VMM and disk image.
  - Use `images/rootfs.img` as BusyBox 1.33.1 RAMDISK and `images/Image` as Linux kernel image. 

## Building QEMU

- Apply the patch on QEMU. 
  - This patch is adapted from `keystone/patches/qemu/qemu-rom.patch` for a newer QEMU version that can support Xvisor.

```
> cd qemu
> git apply ../patches/keystone-qemu.patch
```

- Build `qemu-system-riscv64` emulator

```
> mkdir build
> cd build
> ../configure --target-list=riscv64-softmmu
> make
```

## Boot native Xvisor on OpenSBI Firmware with Keystone SM

Run `./scripts/test-run-xvisor.sh`
