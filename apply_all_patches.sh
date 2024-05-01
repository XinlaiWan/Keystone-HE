#!/bin/bash

# Keystone
cd keystone
git apply ../patches/keystone.patch
cd ..

# Xvisor
cd xvisor
git apply ../patches/xvisor.patch
cd ..

# musl toolchain
cd musl-riscv-toolchain
git apply ../patches/musltools.patch
cd ..

# Keystone benchmark main directory
cd keystone-bench
git apply ../patches/keystone-bench.patch

# Keystone benchmark submodules
# -----------------------------
cd beebs
git apply ../../patches/beebs.patch
cd ..

cd coremark
git apply ../../patches/coremark.patch
cd ..

cd iozone
git apply ../../patches/iozone.patch
cd ..

cd rv8-bench
git apply ../../patches/rv8-bench.patch
cd ../..
# -----------------------------
