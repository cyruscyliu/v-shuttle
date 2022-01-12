#!/bin/bash -x
target=$1 # ohic/ehci/uhci

# download QEMU
QEMU_DIR=qemu-5.1.0-$target
rm -rf $QEMU_DIR
git clone --branch v5.1.0-vshuttle https://github.com/cyruscyliu/virtfuzz-qemu.git $QEMU_DIR --depth=1

# compile afl-seedpool
pushd afl-seedpool
make
make install
popd

# copy files
cp ./fuzz-seedpool.h $QEMU_DIR/include
cp ./hook-write.h $QEMU_DIR/include
cp ./03-clangcovdump.h $QEMU_DIR/include
patch $QEMU_DIR/softmmu/memory.c ./QEMU-patch/memory.patch

# patch QEMU
if [ $target == 'uhci'  ]; then
    patch $QEMU_DIR/hw/usb/hcd-uhci.c ./QEMU-patch/hcd-uhci.patch
elif [ $target == 'ohci'  ]; then
    patch $QEMU_DIR/hw/usb/hcd-ohci.c ./QEMU-patch/hcd-ohci.patch
elif [ $target == 'ehci'  ]; then
    patch $QEMU_DIR/hw/usb/hcd-ehci.c ./QEMU-patch/hcd-ehci.patch
fi

# compile QEMU
pushd $QEMU_DIR
CC=afl-clang CXX=afl-clang++ ./configure --disable-werror --disable-sanitizers --target-list="x86_64-softmmu"
# make CFLAGS="-fprofile-instr-generate -fcoverage-mapping" -j$(nproc) x86_64-softmmu/all
make CONFIG_FUZZ=y CFLAGS="-DCLANG_COV_DUMP -fprofile-instr-generate -fcoverage-mapping" -j$(nproc) x86_64-softmmu/all
popd
