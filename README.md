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

- Apply the patch on Xvisor.

```
> cd keystone
> git apply ../patches/keystone.patch
```

- Follow [this section](https://docs.keystone-enclave.org/en/latest/Getting-Started/Running-Keystone-with-QEMU.html) of the Keystone documentation.
  - Generally we can type `make -j$(nproc)` to build all Keystone components.
  - Note: when encountering the dependency issue between `keystone-examples` and `opensbi`, 
    run `BUILDROOT_TARGET=keystone-examples-dirclean make -j$(nproc)` and `make -j$(nproc)` again.

## Create a rootfs image for Xvisor

- In the project root directory, run:

```
> mkdir rootfs; tar -xf keystone/build-generic64/buildroot.build/images/rootfs.tar -C rootfs
> cd rootfs; find ./ | cpio -o -H newc > ../rootfs.img; cd -; rm -rf rootfs
```

## Building Xvisor

- Apply the patch on Xvisor.

```
> cd xvisor
> git apply ../patches/xvisor.patch
```

- Follow `xvisor/docs/riscv/riscv64-qemu.txt` to build Xvisor VMM and disk image.
  - Generally we can go through the steps of 2, 3, 4, 5, 13.
  - In Step 4 and 5, add `CROSS_COMPILE=riscv64-unknown-linux-gnu-` in front of the `make` commands.
  - In Step 13, use `../rootfs.img` as rootfs image and `../keystone/build-generic64/buildroot.build/images/Image` as Linux kernel image.
  - In Step 13, delete `-B 1024` in the last `genext2fs` command.

## Boot native Xvisor on OpenSBI Firmware with Keystone SM

- In the Keystone directory, use `make run` to start the modified Keystone boot flow in QEMU.
- In the initialized Xvisor terminal, run:

```
> vdisk attach guest0/virtio-blk0 vda
```

Then, run `vdisk list` and we should see:

```
--------------------------------------------------------------------------------
 Name                           Block Size        Attached Block Device         
--------------------------------------------------------------------------------
 guest0/virtio-blk0             512               vda                           
--------------------------------------------------------------------------------
```

After that, run:

```
> guest kick guest0
> vserial bind guest0/uart0
```

- Next, in the initialized `guest0/uart0` terminal, run:

```
> linux_memory_size 0x80000000
> linux_cmdline root=/dev/vda ro console=ttyS0 nokaslr
> autoexec
```

- When the Linux booting has been started, follow the rest of [1.2.1.4.1. Launching Keystone in QEMU](https://docs.keystone-enclave.org/en/latest/Getting-Started/QEMU-Run-Tests.html) in the Keystone documentation to run the test enclaves.

## Boot two Xvisor guests

- Device trees used in Xvisor:
  - Replace `virt64-guest.dts` and `virt64.dts` with `virt64-guest_two_guests.dts` and `virt64_two_guests.dts`.
  - Do not modify the DTB name in the disk.

- Run Keystone:
  - Use `QEMU_FLAGS_TWO_GUESTS` instead of `QEMU_FLAGS` in `keystone/mkutils/plat/generic/run.mk`

- In Xvisor:

```
> vdisk attach guest0/virtio-blk0 vda
> vdisk attach guest1/virtio-blk1 vdb
> guest kick guest0
> guest kick guest1
```

- Bind terminal:

```
vserial bind guest0/uart0
```
or
```
vserial bind guest1/uart0
```
and switch between them by Esc-x-q

- Linux boot

For guest0:
```
> linux_memory_size 0x80000000
> linux_cmdline root=/dev/vda ro console=ttyS0 nokaslr
> autoexec
```

For guest1:
```
> linux_memory_size 0x80000000
> linux_cmdline root=/dev/vdb ro console=ttyS0 nokaslr
> autoexec
```
