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

- Follow [this section](https://docs.keystone-enclave.org/en/latest/Getting-Started/Running-Keystone-with-QEMU.html) of the Keystone documentation.
  - Generally we can type `make -j$(nproc)` to build all Keystone components.
  - Note: when encountering the dependency issue between `keystone-examples` and `opensbi`, 
    run `BUILDROOT_TARGET=keystone-examples-dirclean make -j$(nproc)` and `make -j$(nproc)` again.

## Building Xvisor

- Apply the patch on Xvisor

```
> cd xvisor
> git apply ../patches/xvisor.patch
```

- Follow `xvisor/docs/riscv/riscv64-qemu.txt` to build Xvisor VMM and disk image.
  - Generally we can go through the steps of 2, 3, 4, 5, 13.
  - In Step 4 and 5, add `CROSS_COMPILE=riscv64-unknown-linux-gnu-` in front of the `make` commands.
  - In Step 13, use `images/rootfs.img` as BusyBox 1.33.1 RAMDISK and `keystone/build-generic64/buildroot.build/images/Image` as Linux kernel image.
  - In Step 13, delete `-B 1024` in the last `genext2fs` command.

## Boot native Xvisor on OpenSBI Firmware with Keystone SM

- In the Keystone directory, use `make run` to start the modified Keystone boot flow in QEMU.
- In the Xvisor terminal, run:

```
> vdisk attach guest0/virtio-blk0 vda
> vdisk list
> guest kick guest0
> vserial bind guest0/uart0
```

- In the `guest0/uart0` terminal, run:

```
> linux_memory_size 0x80000000
> linux_cmdline root=/dev/vda ro console=ttyS0 nokaslr
> autoexec
```

- When the Linux booting has been started, follow the rest of [1.2.1.4.1. Launching Keystone in QEMU](https://docs.keystone-enclave.org/en/latest/Getting-Started/QEMU-Run-Tests.html) of the Keystone documentation to run the test enclaves.
