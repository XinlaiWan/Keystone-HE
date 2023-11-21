#!/usr/bin/env bash

base_dir=$(cd $(dirname $0); cd ../; pwd -P)
num=$(head /dev/urandom | cksum | cut -c 1-4)

export HOST_PORT=$((3000+$num%3000));

echo "**** Running QEMU SSH on port ${HOST_PORT} ****";

export SMP=1;

while [ "$1" != "" ]; do
    if [ "$1" = "-debug" ];
    then
        echo "**** GDB port $((HOST_PORT + 1)) ****";
        DEBUG="-gdb tcp::$((HOST_PORT + 1)) -S -d in_asm -D debug.log";
    fi;
    if [ "$1" = "-smp" ];
    then
        SMP="$2";
        shift;
    fi;
    shift;
done;

${base_dir}/qemu/build/qemu-system-riscv64 \
  -cpu rv64 \
  -m 6G \
  -nographic \
  -machine virt,rom=${base_dir}/keystone/build/bootrom.build/bootrom.bin \
  -bios ${base_dir}/keystone/build/sm.build/platform/generic/firmware/fw_jump.elf \
  -kernel ${base_dir}/xvisor/build/vmm.bin -initrd ${base_dir}/xvisor/build/disk.img -append 'vmm.bootcmd="vfs mount initrd /;vfs run /boot.xscript;vfs cat /system/banner.txt"' \
  -drive file=${base_dir}/keystone/build/buildroot.build/images/rootfs.ext2,format=raw,id=hd0 \
  -device virtio-blk-device,drive=hd0 \
  -netdev user,id=net0,net=192.168.100.1/24,dhcpstart=192.168.100.128,hostfwd=tcp::${HOST_PORT}-:22 \
  -device virtio-net-device,netdev=net0 \
  -device virtio-rng-pci \
  -smp $SMP
