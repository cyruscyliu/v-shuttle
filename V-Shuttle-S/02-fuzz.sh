#!/bin/bash
# bash -x 02-fuzz.sh 0 uhci > log 2>&1 WORKS!!
TARGET=$1
ROUND=$2
# LLVM_PROFILE_FILE=profile-vshuttle-$TARGET-0 cpulimit -l 100 -- \
if [ $TARGET == 'ohci' ]; then
    bash -x 02-setup.sh ohci 4 $ROUND
    AFL_Fuzzing=1 \
    afl-fuzz -t 5000 -i $TARGET-in-$ROUND -o $TARGET-out-$ROUND -m none -f $TARGET-seed-$ROUND -- \
    ./qemu-5.1.0-$TARGET/x86_64-softmmu/qemu-system-x86_64 -L ./qemu-5.1.0-$TARGET/pc-bios \
    -device pci-ohci,id=ohci -device usb-tablet,bus=ohci.0,port=1,id=usbdev1 \
    -display none
elif [ $TARGET == 'ehci' ]; then
    bash -x 02-setup.sh ehci 12 $ROUND
    AFL_Fuzzing=1 \
    afl-fuzz -t 5000 -i $TARGET-in-$ROUND -o $TARGET-out-$ROUND -m none -f $TARGET-seed-$ROUND -- \
    ./qemu-5.1.0-$TARGET/x86_64-softmmu/qemu-system-x86_64 -L ./qemu-5.1.0-$TARGET/pc-bios \
    -display none -m 512M -machine q35 -nodefaults \
    -device ich9-usb-ehci1,bus=pcie.0,addr=1d.7,multifunction=on,id=ich9-ehci-1 \
    -device ich9-usb-uhci1,bus=pcie.0,addr=1d.0,multifunction=on,masterbus=ich9-ehci-1.0,firstport=0 \
    -device ich9-usb-uhci2,bus=pcie.0,addr=1d.1,multifunction=on,masterbus=ich9-ehci-1.0,firstport=2 \
    -device ich9-usb-uhci3,bus=pcie.0,addr=1d.2,multifunction=on,masterbus=ich9-ehci-1.0,firstport=4 \
    -drive if=none,id=usbcdrom,media=cdrom -device usb-tablet,bus=ich9-ehci-1.0,port=1,usb_version=1 \
    -device usb-storage,bus=ich9-ehci-1.0,port=2,drive=usbcdrom
elif [ $TARGET == 'uhci' ]; then
    bash -x 02-setup.sh uhci 6 $ROUND
    AFL_Fuzzing=1 \
    afl-fuzz -t 5000 -i $TARGET-in-$ROUND -o $TARGET-out-$ROUND -m none -f $TARGET-seed-$ROUND -- \
    ./qemu-5.1.0-$TARGET/x86_64-softmmu/qemu-system-x86_64 -L ./qemu-5.1.0-$TARGET/pc-bios \
    -machine q35 -nodefaults -device piix3-usb-uhci,id=uhci,addr=1d.0 \
    -drive id=drive0,if=none,file=null-co://,file.read-zeroes=on,format=raw \
    -device usb-tablet,bus=uhci.0,port=1 -display none
fi
