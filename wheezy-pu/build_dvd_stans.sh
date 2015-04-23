#!/bin/sh

SOURCE="false"

# variant specific features 
VARIANT="Kollegium St. Fidelis "
cp variants/stans/stans.chroot config/hooks/ 
cp variants/stans/stans.list.chroot config/package-lists/

# common build
. ./functions.sh
init_build
configure
build_image

# cleanup
rm config/hooks/stans.chroot
rm config/package-lists/stans.list.chroot
