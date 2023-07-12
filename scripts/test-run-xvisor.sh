#!/usr/bin/env bash
base_dir=$(cd $(dirname $0); cd ../; pwd -P)

${base_dir}/qemu/build/qemu-system-riscv64 \
  -m 2G \
  -nographic \
  -machine virt,rom=${base_dir}/keystone/build/bootrom.build/bootrom.bin \
  -bios ${base_dir}/keystone/build/sm.build/platform/generic/firmware/fw_jump.elf \
  -kernel  ${base_dir}/xvisor/build/vmm.bin -initrd ${base_dir}/xvisor/build/disk.img -append 'vmm.bootcmd="vfs mount initrd /;vfs run /boot.xscript;vfs cat /system/banner.txt"'
