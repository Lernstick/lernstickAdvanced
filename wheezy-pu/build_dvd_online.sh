#!/bin/sh

SOURCE="false"

# variant specific features 
VARIANT="Online "
cp config/bootloaders/isolinux/xmlboot.config .
cp config/includes.binary/boot/grub/grub.cfg .
cp variants/online/grub.cfg config/includes.binary/boot/grub/
cp variants/online/online.list.chroot config/package-lists/
cp variants/online/xmlboot.config config/bootloaders/isolinux/
mv config/package-lists/offline.list.chroot .

# common build
. ./functions.sh
init_build
configure
build_image

# cleanup
cp grub.cfg config/includes.binary/boot/grub/
cp xmlboot.config config/bootloaders/isolinux/
mv offline.list.chroot config/package-lists/
rm config/package-lists/online.list.chroot
