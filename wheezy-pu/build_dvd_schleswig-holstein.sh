#!/bin/sh

SOURCE="false"

# variant specific features 
VARIANT="1 Schleswig-Holstein - "
cp variants/schleswig-holstein/inittab config/includes.chroot/etc/
mv config/package-lists/terminals.list.chroot .

# common build
. ./functions.sh
init_build
configure
build_image

# cleanup
rm config/includes.chroot/etc/inittab
mv terminals.list.chroot config/package-lists/
